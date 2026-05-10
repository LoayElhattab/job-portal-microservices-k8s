const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
});

const connectWithRetry = async (retries = 10, delay = 3000) => {
  for (let i = 0; i < retries; i++) {
    try {
      await pool.query('SELECT 1');
      console.log('Successfully connected to PostgreSQL (Application DB)');
      await runMigrations();
      return;
    } catch (err) {
      console.error(`Database connection failed. Retrying in ${delay / 1000}s... (${i + 1}/${retries})`);
      await new Promise(res => setTimeout(res, delay));
    }
  }
  console.error('Failed to connect to the database after maximum retries. Exiting...');
  process.exit(1);
};

const runMigrations = async () => {
  const createTableQuery = `
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";

    CREATE TABLE IF NOT EXISTS applications (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      job_id UUID NOT NULL,
      seeker_id UUID NOT NULL,
      employer_id UUID NOT NULL,
      status VARCHAR(50) DEFAULT 'pending',
      cover_letter TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(job_id, seeker_id)
    );
  `;
  try {
    await pool.query(createTableQuery);
    console.log('Application table migration complete.');
  } catch (err) {
    console.error('Migration failed:', err);
  }
};

module.exports = { pool, connectWithRetry };
