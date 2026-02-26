class UserProfile {
  final String userId;
  final String email;
  final String fullName;
  final String phone;
  final String address;
  final String createdAt;

  const UserProfile({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: (json['userId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}
