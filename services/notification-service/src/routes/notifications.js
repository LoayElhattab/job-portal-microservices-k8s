const express = require('express');
const { pool } = require('../db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);


router.get('/', async (req, res, next) => {
  const userId = req.user.userId;

  try {
    const query = `
      SELECT * FROM notifications
      WHERE user_id = $1
      ORDER BY created_at DESC;
    `;
    const result = await pool.query(query, [userId]);

    res.status(200).json({ success: true, data: result.rows });
  } catch (error) {
    next(error);
  }
});

router.patch('/:id/read', async (req, res, next) => {
  const notificationId = req.params.id;
  const userId = req.user.userId;

  try {
    const updateQuery = `
      UPDATE notifications
      SET read = true
      WHERE id = $1 AND user_id = $2
      RETURNING *;
    `;
    const result = await pool.query(updateQuery, [notificationId, userId]);

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Notification not found' }
      });
    }

    res.status(200).json({ success: true, data: result.rows[0] });
  } catch (error) {
    next(error);
  }
});

module.exports = router;