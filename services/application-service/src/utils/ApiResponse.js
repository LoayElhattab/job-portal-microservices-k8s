class ApiResponse {
  constructor(data, meta = null) {
    this.success = true;
    this.data = data;
    if (meta) {
      this.meta = meta;
    }
  }
}

module.exports = { ApiResponse };
