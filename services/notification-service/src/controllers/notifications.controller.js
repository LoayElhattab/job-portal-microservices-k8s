const notificationService = require('../services/notifications.service');
const ApiResponse = require('../utils/ApiResponse');

const list = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { page = 1, limit = 10 } = req.query;

    const { notifications, total } = await notificationService.getNotificationsByUser(
      userId,
      parseInt(page),
      parseInt(limit)
    );

    res.status(200).json(ApiResponse.paginated(notifications, page, limit, total));
  } catch (error) {
    next(error);
  }
};

module.exports = {
  list
};
