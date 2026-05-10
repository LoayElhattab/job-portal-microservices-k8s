class ApiResponse {
  constructor(data, meta = null) {
    this.success = true;
    this.data = data;
    if (meta) {
      this.meta = meta;
    }
  }

  static success(data, meta = null) {
    return new ApiResponse(data, meta);
  }

  static paginated(data, page, limit, total) {
    const meta = {
      page: parseInt(page),
      limit: parseInt(limit),
      total: parseInt(total)
    };
    return new ApiResponse(data, meta);
  }
}

module.exports = ApiResponse;
