const express = require('express');
const router = express.Router();
const notificationsController = require('../controllers/notifications.controller');
const { authenticate } = require('../middleware/auth');

router.get('/', authenticate, notificationsController.list);

module.exports = router;
