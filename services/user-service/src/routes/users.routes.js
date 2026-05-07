const express = require('express');
const auth = require('../middleware/auth');
const { register, login, getProfile } = require('../controllers/users.controller');

const router = express.Router();

router.post('/register', register);
router.post('/login',    login);
router.get('/profile',   auth, getProfile);

module.exports = router;
