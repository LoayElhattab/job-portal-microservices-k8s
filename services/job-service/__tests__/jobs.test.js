const request = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../src/index');
const { pool } = require('../src/db');

// Mock the DB pool
jest.mock('../src/db', () => ({
  pool: {
    query: jest.fn(),
  },
  connectWithRetry: jest.fn(),
}));

const JWT_SECRET = 'test-secret';
process.env.JWT_SECRET = JWT_SECRET;

// Helpers
const generateToken = (payload) => jwt.sign(payload, JWT_SECRET);

const employerToken = generateToken({ userId: 'e7c6b9a1-1234-4567-890a-bcdef1234567', email: 'employer@test.com', role: 'employer' });
const seekerToken = generateToken({ userId: 's7c6b9a1-1234-4567-890a-bcdef1234567', email: 'seeker@test.com', role: 'seeker' });
const otherEmployerToken = generateToken({ userId: 'e9999999-1234-4567-890a-bcdef1234567', email: 'other@test.com', role: 'employer' });

describe('Job Service API', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /health', () => {
    it('should return 200 and status ok', async () => {
      const res = await request(app).get('/health');
      expect(res.status).toBe(200);
      expect(res.body).toEqual({ status: 'ok' });
    });
  });

  describe('POST /api/v1/jobs', () => {
    const validJob = {
      title: 'Software Engineer',
      company: 'Tech Corp',
      location: 'Remote',
      description: 'Build cool stuff',
      salary: '100k-150k'
    };

    it('should create a job successfully for employer', async () => {
      pool.query.mockResolvedValueOnce({ rows: [{ id: 'uuid-1', ...validJob, employer_id: 'e7c6b9a1-1234-4567-890a-bcdef1234567' }] });

      const res = await request(app)
        .post('/api/v1/jobs')
        .set('Authorization', `Bearer ${employerToken}`)
        .send(validJob);

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.job.title).toBe(validJob.title);
      expect(pool.query).toHaveBeenCalledWith(
        expect.stringContaining('INSERT INTO jobs'),
        expect.arrayContaining([validJob.title, validJob.company])
      );
    });

    it('should return 400 if required fields are missing', async () => {
      const res = await request(app)
        .post('/api/v1/jobs')
        .set('Authorization', `Bearer ${employerToken}`)
        .send({ title: 'Missing fields' });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
    });

    it('should return 401 if unauthorized', async () => {
      const res = await request(app)
        .post('/api/v1/jobs')
        .send(validJob);

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
    });

    it('should return 403 if user is a seeker', async () => {
      const res = await request(app)
        .post('/api/v1/jobs')
        .set('Authorization', `Bearer ${seekerToken}`)
        .send(validJob);

      expect(res.status).toBe(403);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('FORBIDDEN');
    });
  });

  describe('GET /api/v1/jobs', () => {
    it('should return paginated list of jobs', async () => {
      pool.query
        .mockResolvedValueOnce({ rows: [{ count: '10' }] }) // count query
        .mockResolvedValueOnce({ rows: [{ id: '1', title: 'Job 1' }, { id: '2', title: 'Job 2' }] }); // select query

      const res = await request(app).get('/api/v1/jobs?page=1&limit=2');

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveLength(2);
      expect(res.body.meta).toEqual({
        total: 10,
        page: 1,
        limit: 2,
        pages: 5
      });
    });

    it('should support search and location filters', async () => {
      pool.query
        .mockResolvedValueOnce({ rows: [{ count: '1' }] })
        .mockResolvedValueOnce({ rows: [{ id: '1', title: 'Dev' }] });

      const res = await request(app).get('/api/v1/jobs?search=dev&location=london');

      expect(res.status).toBe(200);
      expect(pool.query).toHaveBeenCalledWith(
        expect.stringContaining('COUNT(*)'),
        expect.arrayContaining(['%dev%', '%london%'])
      );
    });

    it('should return empty list if no jobs found', async () => {
      pool.query
        .mockResolvedValueOnce({ rows: [{ count: '0' }] })
        .mockResolvedValueOnce({ rows: [] });

      const res = await request(app).get('/api/v1/jobs');

      expect(res.status).toBe(200);
      expect(res.body.data).toEqual([]);
      expect(res.body.meta.total).toBe(0);
    });
  });

  describe('GET /api/v1/jobs/:id', () => {
    it('should return 200 for existing active job', async () => {
      pool.query.mockResolvedValueOnce({ rows: [{ id: 'uuid-1', title: 'Job 1', status: 'active' }] });

      const res = await request(app).get('/api/v1/jobs/uuid-1');

      expect(res.status).toBe(200);
      expect(res.body.data.job.id).toBe('uuid-1');
    });

    it('should return 404 for non-existent job', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const res = await request(app).get('/api/v1/jobs/non-existent');

      expect(res.status).toBe(404);
      expect(res.body.error.code).toBe('JOB_NOT_FOUND');
    });
  });

  describe('PATCH /api/v1/jobs/:id', () => {
    const updateData = { title: 'Updated Title' };

    it('should update job successfully if owner', async () => {
      // First call is getJobById
      pool.query.mockResolvedValueOnce({ rows: [{ id: 'uuid-1', employer_id: 'e7c6b9a1-1234-4567-890a-bcdef1234567' }] });
      // Second call is update
      pool.query.mockResolvedValueOnce({ rows: [{ id: 'uuid-1', title: 'Updated Title' }] });

      const res = await request(app)
        .patch('/api/v1/jobs/uuid-1')
        .set('Authorization', `Bearer ${employerToken}`)
        .send(updateData);

      expect(res.status).toBe(200);
      expect(res.body.data.job.title).toBe('Updated Title');
    });

    it('should return 403 if not owner', async () => {
      pool.query.mockResolvedValueOnce({ rows: [{ id: 'uuid-1', employer_id: 'e7c6b9a1-1234-4567-890a-bcdef1234567' }] });

      const res = await request(app)
        .patch('/api/v1/jobs/uuid-1')
        .set('Authorization', `Bearer ${otherEmployerToken}`)
        .send(updateData);

      expect(res.status).toBe(403);
    });

    it('should return 404 for non-existent job', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .patch('/api/v1/jobs/non-existent')
        .set('Authorization', `Bearer ${employerToken}`)
        .send(updateData);

      expect(res.status).toBe(404);
    });
  });

  describe('DELETE /api/v1/jobs/:id', () => {
    it('should perform soft delete successfully if owner', async () => {
      pool.query.mockResolvedValueOnce({ rows: [{ id: 'uuid-1', employer_id: 'e7c6b9a1-1234-4567-890a-bcdef1234567' }] });
      pool.query.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .delete('/api/v1/jobs/uuid-1')
        .set('Authorization', `Bearer ${employerToken}`);

      expect(res.status).toBe(200);
      expect(res.body.data.deleted).toBe(true);
      expect(pool.query).toHaveBeenCalledWith(
        expect.stringContaining("UPDATE jobs SET status = 'closed'"),
        expect.any(Array)
      );
    });

    it('should return 403 if not owner', async () => {
      pool.query.mockResolvedValueOnce({ rows: [{ id: 'uuid-1', employer_id: 'e7c6b9a1-1234-4567-890a-bcdef1234567' }] });

      const res = await request(app)
        .delete('/api/v1/jobs/uuid-1')
        .set('Authorization', `Bearer ${otherEmployerToken}`);

      expect(res.status).toBe(403);
    });

    it('should return 404 for non-existent job', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const res = await request(app)
        .delete('/api/v1/jobs/non-existent')
        .set('Authorization', `Bearer ${employerToken}`);

      expect(res.status).toBe(404);
    });
  });
});
