const { pool } = require('../db');

const getNotificationsByUser = async (userId, page = 1, limit = 10) => {
  const offset = (page - 1) * limit;

  const countQuery = 'SELECT COUNT(*) FROM notifications WHERE userId = $1';
  const dataQuery = `
    SELECT * FROM notifications 
    WHERE userId = $1 
    ORDER BY createdAt DESC 
    LIMIT $2 OFFSET $3
  `;

  try {
    const totalResult = await pool.query(countQuery, [userId]);
    const total = parseInt(totalResult.rows[0].count);

    const result = await pool.query(dataQuery, [userId, limit, offset]);

    return {
      notifications: result.rows,
      page,
      limit,
      total
    };
  } catch (error) {
    console.error('Database Error in getNotificationsByUser:', error);
    throw error;
  }
};

const markAsRead = async (notificationId, userId) => {
  const query = 'UPDATE notifications SET isRead = true WHERE id = $1 AND userId = $2 RETURNING *';
  const result = await pool.query(query, [notificationId, userId]);
  return result.rows[0];
};

module.exports = {
  getNotificationsByUser,
  markAsRead
};
