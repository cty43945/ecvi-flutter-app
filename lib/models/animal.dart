/// Represents an individual animal or group entry on a certificate.
///
/// At minimum, each animal must have some form of [identifier] (ear tag,
/// microchip, RFID, etc.).  Additional data like [species], [breed],
/// [sex], [age], and [color] can be recorded when available.  These
/// fields correspond to the elements defined in the eCVI schema for each
/// animal entry.
class Animal {
  Animal({
    required this.identifier,
    this.species,
    this.breed,
    this.sex,
    this.age,
    this.color,
    this.tests,
  });

  /// Unique identification of the animal (RFID tag, tattoo, microchip, etc.).
  final String identifier;

  /// Species of the animal (e.g. "Bovine", "Equine").
  final String? species;

  /// Breed (can be a specific breed or a generic class like "dairy" or
  /// "beef").
  final String? breed;

  /// Sex of the animal (e.g. "M", "F", "G" for gelding, etc.).
  final String? sex;

  /// Age of the animal.  Could be formatted as a string like "2 years",
  /// or stored as a number of months/years – left flexible for now.
  final String? age;

  /// Color or markings (optional description).
  final String? color;

  /// Health tests or vaccination records.  The schema allows attaching
  /// test results and dates; we store them as a simple list of strings for now.
  final List<String>? tests;

  /// Converts to a map for SQLite storage.
  Map<String, dynamic> toMap(String certificateId) {
    return {
      'certificate_id': certificateId,
      'identifier': identifier,
      'species': species,
      'breed': breed,
      'sex': sex,
      'age': age,
      'color': color,
      'tests': tests?.join('\n'),
    };
  }
}