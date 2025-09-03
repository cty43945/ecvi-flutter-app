import 'address.dart';

/// Represents a party on the certificate (consignor or consignee).
///
/// Both consignor and consignee have similar data: a primary contact name,
/// optional business/farm name, a phone number, email, and a physical
/// [address].  Note that mailing addresses (P.O. boxes) may not be valid
/// for the origin/destination in some states.
class Contact {
  Contact({
    required this.name,
    required this.address,
    this.businessName,
    this.phone,
    this.email,
  });

  final String name;
  final Address address;
  final String? businessName;
  final String? phone;
  final String? email;
}