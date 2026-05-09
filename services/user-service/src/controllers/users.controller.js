const UsersService = require('../services/users.service');
const ApiResponse = require('../utils/ApiResponse');
const ApiError = require('../utils/ApiError');

async function register(req, res, next) {
  try {
    const { name, email, password, role } = req.body;

    if (!name || !email || !password || !role) {
      return res.status(400).json(ApiError.validationError('name, email, password and role are required'));
    }

    if (!['seeker', 'employer'].includes(role)) {
      return res.status(400).json(ApiError.validationError('role must be seeker or employer'));
    }

    const data = await UsersService.register({ name, email, password, role });
    res.status(201).json(ApiResponse.success(data));
  } catch (err) {
    next(err);
  }
}

async function login(req, res, next) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json(ApiError.validationError('email and password are required'));
    }

    const data = await UsersService.login({ email, password });
    res.status(200).json(ApiResponse.success(data));
  } catch (err) {
    next(err);
  }
}

async function getProfile(req, res, next) {
  try {
    const data = await UsersService.getProfile(req.user.userId);
    res.status(200).json(ApiResponse.success(data));
  } catch (err) {
    next(err);
  }
}

module.exports = { register, login, getProfile };
