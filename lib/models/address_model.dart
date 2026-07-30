import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;

  final String fullName;

  final String phone;

  final String addressLine1;

  final String addressLine2;

  final String city;

  final String state;

  final String pincode;

  final String country;

  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.isDefault,
  });

  factory AddressModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return AddressModel(
      id: id,
      fullName: map["fullName"] ?? "",
      phone: map["phone"] ?? "",
      addressLine1: map["addressLine1"] ?? "",
      addressLine2: map["addressLine2"] ?? "",
      city: map["city"] ?? "",
      state: map["state"] ?? "",
      pincode: map["pincode"] ?? "",
      country: map["country"] ?? "India",
      isDefault: map["isDefault"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "fullName": fullName,
      "phone": phone,
      "addressLine1": addressLine1,
      "addressLine2": addressLine2,
      "city": city,
      "state": state,
      "pincode": pincode,
      "country": country,
      "isDefault": isDefault,
      "updatedAt": Timestamp.now(),
    };
  }

  String get fullAddress {
    return [
      addressLine1,
      addressLine2,
      city,
      state,
      pincode,
      country,
    ].where((e) => e.trim().isNotEmpty).join(", ");
  }
}