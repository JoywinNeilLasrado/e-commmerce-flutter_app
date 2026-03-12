class User {
  final int id;
  final String name;
  final String email;
  final DateTime? createdAt;
  final List<Address> addresses;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.addresses = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      addresses: (json['addresses'] as List? ?? [])
          .map((a) => Address.fromJson(a))
          .toList(),
    );
  }
}

class Address {
  final int id;
  final String? label;
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;
  final bool isDefault;

  Address({
    required this.id,
    this.label,
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      label: json['label'],
      fullName: json['full_name'],
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
      phone: json['phone'],
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }
}
