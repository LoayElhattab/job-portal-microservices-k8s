class Application {
  final String id;
  final String? jobId;
  final String seekerId;
  final String? employerId;
  final String status;
  final String? coverLetter;
  final DateTime? createdAt;

  Application({
    required this.id,
    this.jobId,
    required this.seekerId,
    this.employerId,
    required this.status,
    this.coverLetter,
    this.createdAt,
  });
}
