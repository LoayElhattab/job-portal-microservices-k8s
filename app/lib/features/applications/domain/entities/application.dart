class Application {
  final int id;
  final int jobId;
  final int seekerId;
  final int employerId;
  final String status;
  final String? coverLetter;
  final DateTime createdAt;

  Application({
    required this.id,
    required this.jobId,
    required this.seekerId,
    required this.employerId,
    required this.status,
    this.coverLetter,
    required this.createdAt,
  });
}
