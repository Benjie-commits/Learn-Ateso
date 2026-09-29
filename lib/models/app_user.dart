class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isGuest,
  });

  final String id;
  final String name;
  final String email;
  final bool isGuest;

  AppUser copyWith({String? name, String? email, bool? isGuest}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      isGuest: map['isGuest'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'isGuest': isGuest};
  }
}
