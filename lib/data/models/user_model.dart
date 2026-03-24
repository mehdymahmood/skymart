class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final List<AddressModel> addresses;
  final int orderCount;
  final int wishlistCount;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    this.addresses = const [],
    this.orderCount = 0,
    this.wishlistCount = 0,
    this.isAdmin = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'addresses': addresses.map((a) => a.toJson()).toList(),
        'orderCount': orderCount,
        'wishlistCount': wishlistCount,
        'isAdmin': isAdmin,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        avatar: json['avatar'],
        addresses: (json['addresses'] as List? ?? [])
            .map((a) => AddressModel.fromJson(a))
            .toList(),
        orderCount: json['orderCount'] ?? 0,
        wishlistCount: json['wishlistCount'] ?? 0,
        isAdmin: json['isAdmin'] ?? false,
      );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    List<AddressModel>? addresses,
    int? orderCount,
    int? wishlistCount,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      addresses: addresses ?? this.addresses,
      orderCount: orderCount ?? this.orderCount,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class AddressModel {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String district;
  final String postalCode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.district,
    required this.postalCode,
    this.isDefault = false,
  });

  String get fullAddress => '$address, $city, $district - $postalCode';

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'district': district,
        'postalCode': postalCode,
        'isDefault': isDefault,
      };

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] ?? '',
        label: json['label'] ?? '',
        fullName: json['fullName'] ?? '',
        phone: json['phone'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        district: json['district'] ?? '',
        postalCode: json['postalCode'] ?? '',
        isDefault: json['isDefault'] ?? false,
      );

  AddressModel copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? district,
    String? postalCode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
