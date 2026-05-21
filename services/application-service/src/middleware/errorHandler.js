const { ApiError } = require('../utils/ApiError');

const errorHandler = (err, req, res, next) => {

  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      success: false,
      error: { code: err.code, message: err.message }
    });
  }

  if (err.code === '23505') {
    return res.status(409).json({
      success: false,
      error: { code: 'ALREADY_APPLIED', message: 'You have already applied for this job.' }
    });
  }

  res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_SERVER_ERROR',
      message: 'Something went wrong on the server.'
    }
  });
};

module.exports = { errorHandler };