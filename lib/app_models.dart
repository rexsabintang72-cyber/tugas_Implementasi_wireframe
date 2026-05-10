class NoteItem {
  const NoteItem({
    required this.title,
    required this.content,
    required this.category,
    required this.updatedAt,
  });

  final String title;
  final String content;
  final String category;
  final DateTime updatedAt;

  NoteItem copyWith({
    String? title,
    String? content,
    String? category,
    DateTime? updatedAt,
  }) {
    return NoteItem(
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'Prioritas',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class UserProfile {
  const UserProfile({required this.name, required this.email});

  final String name;
  final String email;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final letters = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return letters.isEmpty ? 'U' : letters;
  }
}

class UserAccount {
  const UserAccount({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  UserProfile toProfile() => UserProfile(name: name, email: email);

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'password': password};
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }
}

class AuthSessionResult {
  const AuthSessionResult({
    required this.account,
    required this.profile,
    required this.message,
  });

  final UserAccount account;
  final UserProfile profile;
  final String message;
}

class PersistedAppState {
  const PersistedAppState({
    required this.accounts,
    required this.notesByAccount,
    this.currentAccountEmail,
  });

  final List<UserAccount> accounts;
  final Map<String, List<NoteItem>> notesByAccount;
  final String? currentAccountEmail;
}
