class User {
  final String id;
  final String fullName;
  final String email;
  final String passwordHash;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
    );
  }
}
