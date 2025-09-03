/// Simple data class representing a physical address.
class Address {
  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'US',
  });

  /// Street address (e.g. "123 Main St.").
  final String street;

  /// City of the address.
  final String city;

  /// State or province code (two letter US state for this project).
  final String state;

  /// Postal/ZIP code.
  final String postalCode;

  /// Country code (defaults to "US").
  final String country;
}