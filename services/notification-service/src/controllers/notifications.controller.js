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

const markAsRead = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const notification = await notificationService.markAsRead(id, userId);

    if (!notification) {
      return res.status(404).json(ApiResponse.error('Notification not found', 404));
    }

    res.status(200).json(ApiResponse.success(notification));
  } catch (error) {
    next(error);
  }
};

module.exports = {
  list,
  markAsRead
};
