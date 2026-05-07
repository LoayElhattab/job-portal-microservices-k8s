const { pool } = require('../db');

async function createJob({ employerId, title, company, location, description, salary }) {
  const result = await pool.query(
    `INSERT INTO jobs (employer_id, title, company, location, description, salary)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [employerId, title, company, location, description, salary]
  );
  return { job: result.rows[0] };
}

async function getJobs({ search, location, page, limit }) {
  const offset = (page - 1) * limit;
  const conditions = [`status = 'active'`];
  const values = [];

  if (search) {
    values.push(`%${search}%`);
    conditions.push(`(title ILIKE $${values.length} OR company ILIKE $${values.length} OR description ILIKE $${values.length})`);
  }

  if (location) {
    values.push(`%${location}%`);
    conditions.push(`location ILIKE $${values.length}`);
  }

  const where = conditions.join(' AND ');

  const countResult = await pool.query(`SELECT COUNT(*) FROM jobs WHERE ${where}`, values);
  const total = parseInt(countResult.rows[0].count);

  values.push(limit, offset);
  const result = await pool.query(
    `SELECT * FROM jobs WHERE ${where} ORDER BY created_at DESC LIMIT $${values.length - 1} OFFSET $${values.length}`,
    values
  );

  return {
    jobs: result.rows,
    meta: { total, page, limit, pages: Math.ceil(total / limit) },
  };
}

async function getJobById(id) {
  const result = await pool.query('SELECT * FROM jobs WHERE id = $1', [id]);

  if (result.rows.length === 0) {
    const err = new Error('Job not found');
    err.code = 'JOB_NOT_FOUND';
    err.status = 404;
    throw err;
  }

  return { job: result.rows[0] };
}

async function updateJob({ id, employerId, fields }) {
  const { job } = await getJobById(id);

  if (job.employer_id !== employerId) {
    const err = new Error('You do not have permission to perform this action');
    err.code = 'FORBIDDEN';
    err.status = 403;
    throw err;
  }

  const allowed = ['title', 'company', 'location', 'description', 'salary'];
  const updates = [];
  const values = [];

  for (const key of allowed) {
    if (fields[key] !== undefined) {
      values.push(fields[key]);
      updates.push(`${key} = $${values.length}`);
    }
  }

  if (updates.length === 0) {
    return { job };
  }

  values.push(new Date(), id);
  const result = await pool.query(
    `UPDATE jobs SET ${updates.join(', ')}, updated_at = $${values.length - 1} WHERE id = $${values.length} RETURNING *`,
    values
  );

  return { job: result.rows[0] };
}

async function deleteJob({ id, employerId }) {
  const { job } = await getJobById(id);

  if (job.employer_id !== employerId) {
    const err = new Error('You do not have permission to perform this action');
    err.code = 'FORBIDDEN';
    err.status = 403;
    throw err;
  }

  await pool.query(`UPDATE jobs SET status = 'closed', updated_at = $1 WHERE id = $2`, [new Date(), id]);
  return { deleted: true };
}

module.exports = { createJob, getJobs, getJobById, updateJob, deleteJob };
