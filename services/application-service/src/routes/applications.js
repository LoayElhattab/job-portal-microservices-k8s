const express = require('express');
const { pool } = require('../db');
const { publishEvent } = require('../rabbitmq/publisher');
const { authenticate, requireRole } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);


router.post('/', requireRole('seeker'), async (req, res, next) => {
  const { jobId, employerId, coverLetter } = req.body;
  const seekerId = req.user.userId;

  try {
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

    res.status(201).json({ success: true, data: newApplication });
  } catch (error) {
    next(error);
  }
});


router.get('/', async (req, res, next) => {
  const { userId, role } = req.user;

  try {
    let query, values;

    if (role === 'employer') {
      query = `SELECT * FROM applications WHERE employer_id = $1 ORDER BY created_at DESC;`;
      values = [userId];
    } else {
      query = `SELECT * FROM applications WHERE seeker_id = $1 ORDER BY created_at DESC;`;
      values = [userId];
    }

    const result = await pool.query(query, values);

    res.status(200).json({ success: true, data: result.rows });
  } catch (error) {
    next(error);
  }
});


router.patch('/:id/status', requireRole('employer'), async (req, res, next) => {
  const applicationId = req.params.id;
  const { status } = req.body;
  const employerId = req.user.userId;

  try {
    const updateQuery = `
      UPDATE applications
      SET status = $1
      WHERE id = $2 AND employer_id = $3
      RETURNING id, seeker_id, status;
    `;

    const result = await pool.query(updateQuery, [status, applicationId, employerId]);

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Application not found or unauthorized' }
      });
    }

    const updatedApp = result.rows[0];

    await publishEvent('application.status_changed', {
      applicationId: updatedApp.id,
      seekerId: updatedApp.seeker_id,
      newStatus: updatedApp.status,
    });

    res.status(200).json({ success: true, data: updatedApp });
  } catch (error) {
    next(error);
  }
});

module.exports = router;