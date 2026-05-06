const errorHandler = (err, req, res, next) => {
  console.error('🔥 Error:', err.message);

  if (err.code === '23505') {
    return res.status(400).json({
      success: false,
      error: { code: 'DUPLICATE_ENTRY', message: 'You have already applied for this job.' }
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