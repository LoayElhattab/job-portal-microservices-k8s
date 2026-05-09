class ApiResponse {
  static success(data, meta = null) {
    const response = { success: true, data };
    if (meta) response.meta = meta;
    return response;
  }
}

module.exports = ApiResponse;
