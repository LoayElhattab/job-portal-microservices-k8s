class ApiError {
  static error(code, message) {
    return { success: false, error: { code, message } };
  }

  static validationError(message) {
    return ApiError.error('VALIDATION_ERROR', message);
  }

  static invalidToken() {
    return ApiError.error('INVALID_TOKEN', 'Token is invalid or expired');
  }

  static notFound(resource = 'Job') {
    return ApiError.error('JOB_NOT_FOUND', `${resource} not found`);
  }

  static forbidden() {
    return ApiError.error('FORBIDDEN', 'You do not have permission to perform this action');
  }

  static internal() {
    return ApiError.error('INTERNAL_ERROR', 'An unexpected error occurred');
  }
}

module.exports = ApiError;