const request = require('supertest');
const jwt = require('jsonwebtoken');

// Set test secret before importing app
process.env.JWT_SECRET = 'test-secret';
const app = require('../src/index');

// Mocking DB and RabbitMQ
jest.mock('../src/db', () => ({
  pool: {
    query: jest.fn(),
  },
}));

jest.mock('../rabbitmq/publisher', () => ({
  connectRabbitMQ: jest.fn().mockResolvedValue(null),
  publishEvent: jest.fn().mockResolvedValue(null),
}));

const { pool } = require('../src/db');
const { publishEvent } = require('../rabbitmq/publisher');

const generateToken = (userId, email, role) => {
  return jwt.sign({ userId, email, role }, process.env.JWT_SECRET);
};

describe('Application Service API Tests', () => {
  const seekerId = '123e4567-e89b-12d3-a456-426614174000';
  const employerId = '223e4567-e89b-12d3-a456-426614174000';
  const otherEmployerId = '323e4567-e89b-12d3-a456-426614174000';
  const jobId = '423e4567-e89b-12d3-a456-426614174000';
  const applicationId = '523e4567-e89b-12d3-a456-426614174000';

  const seekerToken = generateToken(seekerId, 'seeker@example.com', 'seeker');
  const employerToken = generateToken(employerId, 'employer@example.com', 'employer');
  const otherEmployerToken = generateToken(otherEmployerId, 'other@example.com', 'employer');

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /health', () => {
    it('should return 200 and status ok', async () => {
      const res = await request(app).get('/health');
      expect(res.statusCode).toEqual(200);
      expect(res.body).toEqual({ status: 'ok' });
    });
  });

  describe('POST /api/v1/applications', () => {
    const validPayload = { jobId, employerId, coverLetter: 'I am interested' };

    it('should successfully apply (201) and publish event', async () => {
      const mockApp = { 
        id: applicationId, 
        job_id: validPayload.jobId, 
        employer_id: validPayload.employerId, 
        seeker_id: seekerId, 
        status: 'pending' 
      };
      pool.query.mockResolvedValueOnce({ rows: [mockApp] });

      const res = await request(app)
        .post('/api/v1/applications')
        .set('Authorization', `Bearer ${seekerToken}`)
        .send(validPayload);

      expect(res.statusCode).toEqual(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toMatchObject({ id: applicationId, job_id: jobId });
      expect(publishEvent).toHaveBeenCalledWith('application.submitted', expect.any(Object));
    });

    it('should return 400 if jobId is missing', async () => {
      const res = await request(app)
        .post('/api/v1/applications')
        .set('Authorization', `Bearer ${seekerToken}`)
        .send({ coverLetter: 'Missing jobId' });

      expect(res.statusCode).toEqual(400);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('BAD_REQUEST');
    });

    it('should return 401 if no token is provided', async () => {
      const res = await request(app).post('/api/v1/applications').send(validPayload);
      expect(res.statusCode).toEqual(401);
    });

    it('should return 403 if an employer tries to apply', async () => {
      const res = await request(app)
        .post('/api/v1/applications')
        .set('Authorization', `Bearer ${employerToken}`)
        .send(validPayload);

      expect(res.statusCode).toEqual(403);
      expect(res.body.error.code).toBe('FORBIDDEN');
    });

    it('should return 409 if application is duplicate', async () => {
      // Mock Postgres unique constraint violation
      const error = new Error('Duplicate entry');
      error.code = '23505';
      pool.query.mockRejectedValueOnce(error);

      const res = await request(app)
        .post('/api/v1/applications')
        .set('Authorization', `Bearer ${seekerToken}`)
        .send(validPayload);

      expect(res.statusCode).toEqual(409);
      expect(res.body.error.code).toBe('ALREADY_APPLIED');
    });
  });

  describe('GET /api/v1/applications', () => {
    it('should allow seeker to see their own applications', async () => {
      const mockApps = [{ id: applicationId, seeker_id: seekerId, job_id: jobId }];
      pool.query.mockResolvedValueOnce({ rows: mockApps });

      const res = await request(app)
        .get('/api/v1/applications')
        .set('Authorization', `Bearer ${seekerToken}`);

      expect(res.statusCode).toEqual(200);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data[0].seeker_id).toBe(seekerId);
    });

    it('should allow employer to see applications for their jobs', async () => {
      const mockApps = [{ id: applicationId, employer_id: employerId, job_id: jobId }];
      pool.query.mockResolvedValueOnce({ rows: mockApps });

      const res = await request(app)
        .get('/api/v1/applications')
        .set('Authorization', `Bearer ${employerToken}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body.data[0].employer_id).toBe(employerId);
    });

    it('should return 401 if unauthorized', async () => {
      const res = await request(app).get('/api/v1/applications');
      expect(res.statusCode).toEqual(401);
    });

    it('should return 200 and empty list if no applications found', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .get('/api/v1/applications')
        .set('Authorization', `Bearer ${seekerToken}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body.data).toEqual([]);
    });
  });

  describe('PATCH /api/v1/applications/:id/status', () => {
    const updatePayload = { status: 'accepted' };

    it('should successfully update status (200) and publish event if owner', async () => {
      const mockUpdated = { id: applicationId, seeker_id: seekerId, status: 'accepted' };
      pool.query.mockResolvedValueOnce({ rowCount: 1, rows: [mockUpdated] });

      const res = await request(app)
        .patch(`/api/v1/applications/${applicationId}/status`)
        .set('Authorization', `Bearer ${employerToken}`)
        .send(updatePayload);

      expect(res.statusCode).toEqual(200);
      expect(res.body.data.status).toBe('accepted');
      expect(publishEvent).toHaveBeenCalledWith('application.status_changed', expect.any(Object));
    });

    it('should return 403 if seeker attempts update', async () => {
      const res = await request(app)
        .patch(`/api/v1/applications/${applicationId}/status`)
        .set('Authorization', `Bearer ${seekerToken}`)
        .send(updatePayload);

      expect(res.statusCode).toEqual(403);
    });

    it('should return 404 if application not found or not owner', async () => {
      pool.query.mockResolvedValueOnce({ rowCount: 0, rows: [] });

      const res = await request(app)
        .patch(`/api/v1/applications/${applicationId}/status`)
        .set('Authorization', `Bearer ${otherEmployerToken}`)
        .send(updatePayload);

      expect(res.statusCode).toEqual(404);
      expect(res.body.error.code).toBe('NOT_FOUND');
    });

    it('should return 401 if unauthorized', async () => {
      const res = await request(app).patch(`/api/v1/applications/${applicationId}/status`).send(updatePayload);
      expect(res.statusCode).toEqual(401);
    });
  });
});
