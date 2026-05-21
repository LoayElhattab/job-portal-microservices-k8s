class ApiError {
  static error(code, message) {
    return { success: false, error: { code, message } };
  }

  static validationError(message) {
    return ApiError.error('VALIDATION_ERROR', message);
  }

  static emailExists() {
    return ApiError.error('EMAIL_EXISTS', 'Email is already registered');
  }

  static invalidCredentials() {
    return ApiError.error('INVALID_CREDENTIALS', 'Invalid email or password');
  }

  static invalidToken() {
    return ApiError.error('INVALID_TOKEN', 'Token is invalid or expired');
  }

  static notFound(resource = 'Resource') {
    return ApiError.error('NOT_FOUND', `${resource} not found`);
  }

  static forbidden() {
    return ApiError.error('FORBIDDEN', 'You do not have permission to perform this action');
  }

  static internal() {
    return ApiError.error('INTERNAL_ERROR', 'An unexpected error occurred');
  }
}

module.exports = ApiError;
