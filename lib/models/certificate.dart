import 'address.dart';
import 'animal.dart';
import 'contact.dart';
import 'veterinarian.dart';

/// Represents a Certificate of Veterinary Inspection.
///
/// This model is a direct analogue to the eCVI XML schema’s root data
/// structure.  Each certificate has a unique [id], identifies the
/// veterinarian who issued it, the consignor and consignee, origin and
/// destination addresses, a list of [Animal] entries, and additional
/// metadata.  The [signaturePath] stores the file path to the veterinarian’s
/// handwritten signature image captured during certificate creation.
class Certificate {
  Certificate({
    required this.id,
    required this.veterinarian,
    required this.consignor,
    required this.consignee,
    required this.origin,
    required this.destination,
    required this.movementPurpose,
    required this.dateOfIssue,
    this.statements = const <String>[],
    this.animals = const <Animal>[],
    this.signaturePath,
  });

  /// Unique identifier for the certificate (StateCode–VetID–Timestamp).
  final String id;

  /// The veterinarian issuing this certificate.
  final Veterinarian veterinarian;

  /// The party sending the animals.
  final Contact consignor;

  /// The party receiving the animals.
  final Contact consignee;

  /// Physical origin address of the animals (may match consignor).
  final Address origin;

  /// Physical destination address of the animals (may match consignee).
  final Address destination;

  /// Purpose of movement (e.g. Sale, Exhibition, etc.).
  final String movementPurpose;

  /// Date/time the certificate was issued.
  final DateTime dateOfIssue;

  /// Additional statements or declarations included on the certificate.
  final List<String> statements;

  /// List of animals covered by this certificate.
  final List<Animal> animals;

  /// Path to the veterinarian's signature image (PNG file on disk), if
  /// captured.  May be null if signature has not yet been captured.
  final String? signaturePath;

  /// Converts this Certificate into a map that can be stored in a SQLite
  /// database.  See [DbHelper] for how this is used.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vet_license': veterinarian.licenseNumber,
      'vet_state': veterinarian.licenseState,
      'vet_first_name': veterinarian.firstName,
      'vet_last_name': veterinarian.lastName,
      'vet_accreditation': veterinarian.accreditationNumber,
      'consignor_name': consignor.name,
      'consignor_business': consignor.businessName,
      'consignor_phone': consignor.phone,
      'consignor_email': consignor.email,
      'origin_street': origin.street,
      'origin_city': origin.city,
      'origin_state': origin.state,
      'origin_postal_code': origin.postalCode,
      'consignee_name': consignee.name,
      'consignee_business': consignee.businessName,
      'consignee_phone': consignee.phone,
      'consignee_email': consignee.email,
      'destination_street': destination.street,
      'destination_city': destination.city,
      'destination_state': destination.state,
      'destination_postal_code': destination.postalCode,
      'movement_purpose': movementPurpose,
      'date_of_issue': dateOfIssue.toIso8601String(),
      'statements': statements.join('\n'),
      'signature_path': signaturePath,
    };
  }
}