class Contact {
  final int? contactId;
  final String name;
  final String email;
  final String message;

  Contact({
    this.contactId,
    required this.name,
    required this.email,
    required this.message,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      contactId: json['contact_id'],
      name: json['name'],
      email: json['email'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact_id': contactId,
      'name': name,
      'email': email,
      'message': message,
    };
  }
}
