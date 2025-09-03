import 'address.dart';

/// Data class representing an accredited veterinarian.
///
/// At minimum, the veterinarian must provide a name, license number and
/// issuing state.  Accreditation numbers (for USDA accredited vets) can be
/// recorded but are optional.  The [address] field may hold the vet's
/// clinic or mailing address.
class Veterinarian {
  Veterinarian({
    required this.firstName,
    required this.lastName,
    required this.licenseNumber,
    required this.licenseState,
    this.businessName,
    this.accreditationNumber,
    this.address,
    this.phone,
    this.email,
  });

  final String firstName;
  final String lastName;
  final String licenseNumber;
  final String licenseState;
  final String? businessName;
  final String? accreditationNumber;
  final Address? address;
  final String? phone;
  final String? email;

  /// Returns a full name string (first + last).
  String get fullName => '$firstName $lastName';
}