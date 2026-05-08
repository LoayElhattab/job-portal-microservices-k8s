const request = require('supertest');
const jwt = require('jsonwebtoken');

// Mock bcryptjs
jest.mock('bcryptjs', () => ({
  hash: async (pw) => 'hashed_' + pw,
  compare: async (pw, hash) => hash === 'hashed_' + pw
}));

// Mock DB
const mockPool = {
  query: jest.fn(),
  connect: jest.fn()
};
jest.mock('../src/db', () => ({
  pool: mockPool,
  connectWithRetry: jest.fn().mockResolvedValue()
}));

// Set JWT_SECRET and NODE_ENV before requiring the app
process.env.JWT_SECRET = 'test-secret';
process.env.NODE_ENV = 'test';

const app = require('../src/index');

describe('User Service API', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  const generateTestToken = (payload) => {
    return jwt.sign(payload, 'test-secret', { expiresIn: '1h' });
  };

  describe('GET /health', () => {
    it('should return 200 { status: "ok" }', async () => {
      const res = await request(app).get('/health');
      expect(res.status).toBe(200);
      expect(res.body).toEqual({ status: 'ok' });
    });
  });

  describe('POST /api/v1/users/register', () => {
    const validUser = {
      name: 'John Doe',
      email: 'john@example.com',
      password: 'password123',
      role: 'seeker'
    };

    it('should register a user successfully', async () => {
      // Mock existing user check: none found
      mockPool.query.mockResolvedValueOnce({ rows: [] });
      // Mock insertion
      const insertedUser = {
        id: 'uuid-123',
        name: validUser.name,
        email: validUser.email,
        role: validUser.role,
        created_at: new Date().toISOString()
      };
      mockPool.query.mockResolvedValueOnce({ rows: [insertedUser] });

      const res = await request(app)
        .post('/api/v1/users/register')
        .send(validUser);

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user).toEqual(insertedUser);
      expect(res.body.data.token).toBeDefined();
      
      // Verify query calls
      expect(mockPool.query).toHaveBeenCalledWith(
        expect.stringContaining('SELECT id FROM users'),
        [validUser.email]
      );
    });

    it('should return 400 if required fields are missing', async () => {
      const res = await request(app)
        .post('/api/v1/users/register')
        .send({ name: 'John' }); // missing fields

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
    });

    it('should return 400 for invalid role', async () => {
      const res = await request(app)
        .post('/api/v1/users/register')
        .send({ ...validUser, role: 'admin' });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
    });

    it('should return 409 if email exists', async () => {
      mockPool.query.mockResolvedValueOnce({ rows: [{ id: 'existing-id' }] });

      const res = await request(app)
        .post('/api/v1/users/register')
        .send(validUser);

      expect(res.status).toBe(409);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('EMAIL_EXISTS');
    });
  });

  describe('POST /api/v1/users/login', () => {
    const loginData = {
      email: 'john@example.com',
      password: 'password123'
    };

    it('should login successfully', async () => {
      const dbUser = {
        id: 'uuid-123',
        name: 'John Doe',
        email: loginData.email,
        password: 'hashed_password123',
        role: 'seeker',
        created_at: new Date().toISOString()
      };
      mockPool.query.mockResolvedValueOnce({ rows: [dbUser] });

      const res = await request(app)
        .post('/api/v1/users/login')
        .send(loginData);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user.email).toBe(loginData.email);
      expect(res.body.data.token).toBeDefined();
    });

    it('should return 401 for invalid credentials', async () => {
      mockPool.query.mockResolvedValueOnce({ rows: [] }); // User not found

      const res = await request(app)
        .post('/api/v1/users/login')
        .send(loginData);

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('INVALID_CREDENTIALS');
    });

    it('should return 400 if email or password missing', async () => {
      const res = await request(app)
        .post('/api/v1/users/login')
        .send({ email: 'test@test.com' });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
    });
  });

  describe('GET /api/v1/users/profile', () => {
    const userId = 'uuid-123';
    const token = generateTestToken({ userId, email: 'john@example.com', role: 'seeker' });

    it('should return profile for authenticated user', async () => {
      const profileData = {
        id: userId,
        name: 'John Doe',
        email: 'john@example.com',
        role: 'seeker',
        created_at: new Date().toISOString()
      };
      mockPool.query.mockResolvedValueOnce({ rows: [profileData] });

      const res = await request(app)
        .get('/api/v1/users/profile')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user).toEqual(profileData);
    });

    it('should return 401 if no token provided', async () => {
      const res = await request(app).get('/api/v1/users/profile');

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('INVALID_TOKEN');
    });

    it('should return 401 for invalid token', async () => {
      const res = await request(app)
        .get('/api/v1/users/profile')
        .set('Authorization', 'Bearer invalid-token');

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('INVALID_TOKEN');
    });
  });
});
