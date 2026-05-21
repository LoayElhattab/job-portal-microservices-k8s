const request = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../src/index');
const { pool } = require('../src/db');

// Mocking the database and consumer
jest.mock('../src/db', () => ({
  pool: {
    query: jest.fn(),
  },
  connectWithRetry: jest.fn(),
}));

jest.mock('../rabbitmq/consumer', () => ({
  startConsumer: jest.fn(),
}));

const JWT_SECRET = 'test-secret';
process.env.JWT_SECRET = JWT_SECRET;

const generateToken = (payload) => {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '1h' });
};

describe('Notification Service API Tests', () => {
  const mockUserId = '123e4567-e89b-12d3-a456-426614174000';
  const mockSeekerToken = generateToken({ userId: mockUserId, email: 'seeker@example.com', role: 'seeker' });
  const mockEmployerToken = generateToken({ userId: mockUserId, email: 'employer@example.com', role: 'employer' });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /api/v1/notifications', () => {
    it('should retrieve notifications for an authenticated seeker', async () => {
      const mockNotifications = [
        { id: '1', userId: mockUserId, type: 'application.submitted', message: 'New application submitted' }
      ];
      
      pool.query
        .mockResolvedValueOnce({ rows: [{ count: '1' }] }) // Count query
        .mockResolvedValueOnce({ rows: mockNotifications }); // Data query

      const response = await request(app)
        .get('/api/v1/notifications')
        .set('Authorization', `Bearer ${mockSeekerToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(mockNotifications);
      expect(response.body.meta).toEqual({
        page: 1,
        limit: 10,
        total: 1
      });
    });

    it('should retrieve notifications for an authenticated employer', async () => {
      const mockNotifications = [
        { id: '2', userId: mockUserId, type: 'application.submitted', message: 'New application received' }
      ];
      
      pool.query
        .mockResolvedValueOnce({ rows: [{ count: '1' }] }) // Count query
        .mockResolvedValueOnce({ rows: mockNotifications }); // Data query

      const response = await request(app)
        .get('/api/v1/notifications')
        .set('Authorization', `Bearer ${mockEmployerToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(mockNotifications);
    });

    it('should handle pagination correctly', async () => {
      const mockNotifications = [
        { id: '3', userId: mockUserId, type: 'status_changed', message: 'Status updated' }
      ];
      
      pool.query
        .mockResolvedValueOnce({ rows: [{ count: '15' }] }) // Total count
        .mockResolvedValueOnce({ rows: mockNotifications }); // Page 2 data

      const response = await request(app)
        .get('/api/v1/notifications?page=2&limit=5')
        .set('Authorization', `Bearer ${mockSeekerToken}`);

      expect(response.status).toBe(200);
      expect(response.body.meta).toEqual({
        page: 2,
        limit: 5,
        total: 15
      });
    });

    it('should return empty list when no notifications exist', async () => {
      pool.query
        .mockResolvedValueOnce({ rows: [{ count: '0' }] })
        .mockResolvedValueOnce({ rows: [] });

      const response = await request(app)
        .get('/api/v1/notifications')
        .set('Authorization', `Bearer ${mockSeekerToken}`);

      expect(response.status).toBe(200);
      expect(response.body.data).toEqual([]);
      expect(response.body.meta.total).toBe(0);
    });

    it('should return 401 with INVALID_TOKEN if no token is provided', async () => {
      const response = await request(app).get('/api/v1/notifications');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
      expect(response.body.error.code).toBe('INVALID_TOKEN');
    });

    it('should return 401 with INVALID_TOKEN if token is invalid', async () => {
      const response = await request(app)
        .get('/api/v1/notifications')
        .set('Authorization', 'Bearer invalid-token');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
      expect(response.body.error.code).toBe('INVALID_TOKEN');
    });
  });

  describe('GET /health', () => {
    it('should return 200 { status: "ok" }', async () => {
      const response = await request(app).get('/health');

      expect(response.status).toBe(200);
      expect(response.body).toEqual({ status: 'ok' });
    });
  });
});
