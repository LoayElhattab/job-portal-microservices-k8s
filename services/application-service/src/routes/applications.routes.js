const express = require('express');
const { authenticate, requireRole } = require('../middleware/auth');
const applicationsController = require('../controllers/applications.controller');

const router = express.Router();

router.use(authenticate);

router.post('/', requireRole('seeker'), applicationsController.applyForJob);
router.get('/', applicationsController.getApplications);
router.patch('/:id/status', requireRole('employer'), applicationsController.updateApplicationStatus);

module.exports = router;
