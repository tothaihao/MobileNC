class User {
  final String id;
  final String userName;
  final String email;
  final String? avatar;
  final String? role;

  User({
    required this.id,
    required this.userName,
    required this.email,
    this.avatar,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'avatar': avatar,
      'role': role,
    };
  }
}
