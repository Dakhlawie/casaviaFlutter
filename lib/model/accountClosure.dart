class AccountClosure {
  int? accountId;
  String username;
  String email;
  String message;

  AccountClosure({
    this.accountId,
    required this.username,
    required this.email,
    required this.message,
  });

  factory AccountClosure.fromJson(Map<String, dynamic> json) {
    return AccountClosure(
      accountId: json['account_id'],
      username: json['username'],
      email: json['email'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        'username': username,
        'email': email,
        'message': message,
      };
}
