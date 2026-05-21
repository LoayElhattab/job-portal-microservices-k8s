const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.NOTIFICATION_SERVICE_DB,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
});

const connectWithRetry = async (retries = 10, delay = 3000) => {
  for (let i = 0; i < retries; i++) {
    try {
      await pool.query('SELECT 1');
      console.log('✅ Successfully connected to PostgreSQL (Notification DB)');
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
    CREATE TABLE IF NOT EXISTS notifications (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      userId UUID NOT NULL,
      type VARCHAR(50) NOT NULL,
      message TEXT NOT NULL,
      relatedId UUID,
      isRead BOOLEAN DEFAULT false,
      createdAt TIMESTAMPTZ DEFAULT NOW()
    );
  `;
  try {
    // Ensure pgcrypto extension is available if needed for gen_random_uuid in older PG versions, 
    // but in PG 13+ it's built-in.
    await pool.query(createTableQuery);
    console.log('Notifications table migration complete.');
  } catch (err) {
    console.error('Migration failed:', err);
  }
};

module.exports = { pool, connectWithRetry };