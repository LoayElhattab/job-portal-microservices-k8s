class ApiResponse {
  constructor(statusCode, data, message = 'Success', meta = null) {
    this.statusCode = statusCode;
    this.success = true;
    this.data = data;
    this.message = message;
    if (meta) {
      this.meta = meta;
    }
  }

  static success(data, message = 'Success', meta = null) {
    return new ApiResponse(200, data, message, meta);
  }

  static paginated(data, page, limit, total, message = 'Success') {
    const meta = {
      page: parseInt(page),
      limit: parseInt(limit),
      total: parseInt(total)
    };
    return new ApiResponse(200, data, message, meta);
  }
}

module.exports = ApiResponse;
