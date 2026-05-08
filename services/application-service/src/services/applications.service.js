const { pool } = require('../db');
const { publishEvent } = require('../../rabbitmq/publisher');
const { ApiError } = require('../utils/ApiError');

const applyForJob = async (jobId, seekerId, employerId, coverLetter) => {
  const insertQuery = `
    INSERT INTO applications (job_id, seeker_id, employer_id, cover_letter, status)
    VALUES ($1, $2, $3, $4, 'pending')
    RETURNING id, job_id, seeker_id, employer_id, status, created_at;
  `;

  const result = await pool.query(insertQuery, [jobId, seekerId, employerId, coverLetter]);
  const newApplication = result.rows[0];

  await publishEvent('application.submitted', {
    applicationId: newApplication.id,
    jobId: newApplication.job_id,
    seekerId: newApplication.seeker_id,
    employerId: newApplication.employer_id,
  });

  return newApplication;
};

const getApplications = async (userId, role) => {
  let query, values;

  if (role === 'employer') {
    query = `SELECT * FROM applications WHERE employer_id = $1 ORDER BY created_at DESC;`;
    values = [userId];
  } else {
    query = `SELECT * FROM applications WHERE seeker_id = $1 ORDER BY created_at DESC;`;
    values = [userId];
  }

  const result = await pool.query(query, values);
  return result.rows;
};

const updateApplicationStatus = async (applicationId, employerId, status) => {
  const updateQuery = `
    UPDATE applications
    SET status = $1
    WHERE id = $2 AND employer_id = $3
    RETURNING id, seeker_id, status;
  `;

  const result = await pool.query(updateQuery, [status, applicationId, employerId]);

  if (result.rowCount === 0) {
    throw new ApiError(404, 'NOT_FOUND', 'Application not found or unauthorized');
  }

  const updatedApp = result.rows[0];

  await publishEvent('application.status_changed', {
    applicationId: updatedApp.id,
    seekerId: updatedApp.seeker_id,
    newStatus: updatedApp.status,
  });

  return updatedApp;
};

module.exports = {
  applyForJob,
  getApplications,
  updateApplicationStatus
};
