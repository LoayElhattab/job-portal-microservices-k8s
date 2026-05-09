const jwt = require('jsonwebtoken');
const ApiError = require('../utils/ApiError');

function auth(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json(ApiError.invalidToken());
  }

  const token = header.split(' ')[1];
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = { userId: payload.userId, email: payload.email, role: payload.role };
    next();
  } catch {
    res.status(401).json(ApiError.invalidToken());
  }
}

module.exports = auth;
