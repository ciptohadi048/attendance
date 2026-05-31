/// Role-based access control. Stored as a string in Firestore (`role` field)
/// and used by the router to decide whether to show the employee or admin shell.
enum UserRole {
  employee,
  admin;

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.employee,
    );
  }
}

/// Pure domain entity representing an authenticated user.
class AppUser {
  const AppUser({
    required this.uid,
    required this.nik,
    required this.name,
    required this.email,
    this.role = UserRole.employee,
    this.department,
    this.position,
    this.photoUrl,
    this.phoneNumber,
  });

  final String uid;
  final String nik;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final String? position;
  final String? photoUrl;
  final String? phoneNumber;

  bool get isAdmin => role == UserRole.admin;

  /// First-name initials for avatar fallbacks.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  AppUser copyWith({
    String? name,
    UserRole? role,
    String? department,
    String? position,
    String? photoUrl,
    String? phoneNumber,
  }) {
    return AppUser(
      uid: uid,
      nik: nik,
      name: name ?? this.name,
      email: email,
      role: role ?? this.role,
      department: department ?? this.department,
      position: position ?? this.position,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.uid == uid &&
      other.role == role &&
      other.name == name;

  @override
  int get hashCode => Object.hash(uid, role, name);
}
