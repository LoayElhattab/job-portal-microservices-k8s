const ApiError = require('../utils/ApiError');

function errorHandler(err, req, res, next) {
  console.error(err);
  const status = err.status || 500;
  res.status(status).json(ApiError.error(err.code || 'INTERNAL_ERROR', err.message || 'An unexpected error occurred'));
}

module.exports = errorHandler;
