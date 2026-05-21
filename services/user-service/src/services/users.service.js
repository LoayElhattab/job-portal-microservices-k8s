const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { pool } = require('../db');

function generateToken(user) {
  return jwt.sign(
    { userId: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
  );
}

async function register({ name, email, password, role }) {
  const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
  if (existing.rows.length > 0) {
    const err = new Error('Email is already registered');
    err.code = 'EMAIL_EXISTS';
    err.status = 409;
    throw err;
  }

  const hashed = await bcrypt.hash(password, 12);
  const result = await pool.query(
    `INSERT INTO users (name, email, password, role)
     VALUES ($1, $2, $3, $4)
     RETURNING id, name, email, role, created_at`,
    [name, email, hashed, role]
  );

  const user = result.rows[0];
  const token = generateToken(user);
  return { user, token };
}

async function login({ email, password }) {
  const result = await pool.query(
    'SELECT id, name, email, password, role, created_at FROM users WHERE email = $1',
    [email]
  );

  const user = result.rows[0];
  if (!user || !(await bcrypt.compare(password, user.password))) {
    const err = new Error('Invalid email or password');
    err.code = 'INVALID_CREDENTIALS';
    err.status = 401;
    throw err;
  }

  const token = generateToken(user);
  const { password: _, ...safeUser } = user;
  return { user: safeUser, token };
}

async function getProfile(userId) {
  const result = await pool.query(
    'SELECT id, name, email, role, bio, skills, created_at, updated_at FROM users WHERE id = $1',
    [userId]
  );

  if (result.rows.length === 0) {
    const err = new Error('User not found');
    err.code = 'NOT_FOUND';
    err.status = 404;
    throw err;
  }

  return { user: result.rows[0] };
}

async function updateProfile(userId, { name, bio, skills }) {
  const allowed = ['name', 'bio', 'skills'];
  const updates = [];
  const values = [];

  for (const key of allowed) {
    if (key === 'name' && name !== undefined) {
      values.push(name);
      updates.push(`name = $${values.length}`);
    }
    if (key === 'bio' && bio !== undefined) {
      values.push(bio);
      updates.push(`bio = $${values.length}`);
    }
    if (key === 'skills' && skills !== undefined) {
      values.push(skills);
      updates.push(`skills = $${values.length}`);
    }
  }

  if (updates.length === 0) {
    const profile = await getProfile(userId);
    return profile.user;
  }

  values.push(new Date(), userId);
  const result = await pool.query(
    `UPDATE users SET ${updates.join(', ')}, updated_at = $${values.length - 1} WHERE id = $${values.length} RETURNING id, name, email, role, bio, skills, created_at, updated_at`,
    values
  );

  return result.rows[0];
}

module.exports = { register, login, getProfile, updateProfile };
