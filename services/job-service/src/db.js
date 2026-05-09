const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

const MIGRATION = `
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

  CREATE TABLE IF NOT EXISTS jobs (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employer_id UUID NOT NULL,
    title       VARCHAR(255) NOT NULL,
    company     VARCHAR(255) NOT NULL,
    location    VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    salary      VARCHAR(100),
    status      VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed')),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
  );
`;

async function connectWithRetry(retries = 10, delay = 3000) {
  for (let i = 1; i <= retries; i++) {
    try {
      const client = await pool.connect();
      await client.query(MIGRATION);
      client.release();
      console.log('Database connected and migrated');
      return;
    } catch (err) {
      console.error(`DB connection attempt ${i}/${retries} failed:`, err.message);
      if (i === retries) throw err;
      await new Promise((res) => setTimeout(res, delay));
    }
  }
}

module.exports = { pool, connectWithRetry };
