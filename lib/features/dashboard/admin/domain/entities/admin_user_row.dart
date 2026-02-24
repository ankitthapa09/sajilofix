class AdminUserRow {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? profilePhoto;
  final String? department;
  final String status;
  final String? joinedDate;
  final String? lastActive;
  final String? activity;

  const AdminUserRow({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    this.profilePhoto,
    this.department,
    this.joinedDate,
    this.lastActive,
    this.activity,
  });

  factory AdminUserRow.fromJson(Map<String, dynamic> json) {
    return AdminUserRow(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      profilePhoto: json['profilePhoto']?.toString(),
      department: json['department']?.toString(),
      status: (json['status'] ?? 'active').toString(),
      joinedDate: json['joinedDate']?.toString(),
      lastActive: json['lastActive']?.toString(),
      activity: json['activity']?.toString(),
    );
  }
}
