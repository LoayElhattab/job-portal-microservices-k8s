const ApiError = require('../utils/ApiError');

const errorHandler = (err, req, res, next) => {
  console.error('Error:', err.message || err);

  const statusCode = err.statusCode || 500;
  const code = err.code || 'INTERNAL_SERVER_ERROR';
  const message = err.message || 'Something went wrong on the server.';

  res.status(statusCode).json({
    success: false,
    error: {
      code,
      message
    }
  });
};

module.exports = { errorHandler };