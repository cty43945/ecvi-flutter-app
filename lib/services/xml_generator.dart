import 'package:xml/xml.dart' as xml;

import '../models/animal.dart';
import '../models/certificate.dart';
import '../models/contact.dart';
import '../models/address.dart';
import '../models/veterinarian.dart';

/// Generates an eCVI XML document according to the USAHA/AAVLD eCVI v2 schema
/// (schema version 3.1) with namespace http://www.usaha.org/xmlns/ecvi2.
class XmlGenerator {
  static const String xmlSchemaVersion = '3.1';

  /// Creates a string containing XML for the provided [certificate].
  static String generateEcviXml(Certificate certificate) {
    final builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('eCVI', nest: () {
      builder.attribute('xmlns', 'http://www.usaha.org/xmlns/ecvi2');
      builder.attribute('XMLSchemaVersion', xmlSchemaVersion);
      builder.attribute('CviNumber', certificate.id);
      final issueDate = _fmtDate(certificate.dateOfIssue);
      builder.attribute('IssueDate', issueDate);
      final expiration = _fmtDate(certificate.expirationDate);
      builder.attribute('ExpirationDate', expiration);

      // Veterinarian
      builder.element('Veterinarian', nest: () {
        _buildVeterinarian(builder, certificate.veterinarian);
      });

      // MovementPurposes
      builder.element('MovementPurposes', nest: () {
        if (certificate.movementPurpose.isNotEmpty) {
          builder.element('MovementPurpose', nest: certificate.movementPurpose);
        }
      });

      // Origin & Destination
      builder.element('Origin', nest: () {
        _buildUSAddress(builder, certificate.origin);
      });
      builder.element('Destination', nest: () {
        _buildUSAddress(builder, certificate.destination);
      });

      // Consignor/Consignee
      builder.element('Consignor', nest: () {
        _buildContact(builder, certificate.consignor);
      });
      builder.element('Consignee', nest: () {
        _buildContact(builder, certificate.consignee);
      });

      // Animals directly under eCVI
      final inspectionDate = issueDate;
      for (final animal in certificate.animals) {
        _buildAnimal(builder, animal, inspectionDate);
      }

      if (certificate.statements.isNotEmpty) {
        builder.element('Statements', nest: certificate.statements.join('\n'));
      }
    });
    final document = builder.buildDocument();
    return document.toXmlString(pretty: true);
  }

  static void _buildVeterinarian(xml.XmlBuilder builder, Veterinarian vet) {
    builder.element('Person', nest: () {
      builder.element('NameParts', nest: () {
        if (vet.businessName != null && vet.businessName!.isNotEmpty) {
          builder.element('BusinessName', nest: vet.businessName);
        }
        builder.element('FirstName', nest: vet.firstName);
        builder.element('LastName', nest: vet.lastName);
      });
      if (vet.phone != null && vet.phone!.trim().isNotEmpty) {
        builder.element('Phone', nest: () {
          builder.attribute('Number', _digitsOnly(vet.phone!));
        });
      }
      if (vet.email != null && vet.email!.trim().isNotEmpty) {
        builder.element('Email', nest: () {
          builder.attribute('Address', vet.email!.trim());
        });
      }
    });
    if (vet.address != null) {
      builder.element('Address', nest: () {
        _buildInternationalAddress(builder, vet.address!);
      });
    }
    if (vet.licenseState.isNotEmpty) builder.attribute('LicenseState', vet.licenseState);
    if (vet.licenseNumber.isNotEmpty) builder.attribute('LicenseNumber', vet.licenseNumber);
    if (vet.accreditationNumber != null && vet.accreditationNumber!.isNotEmpty) {
      builder.attribute('NationalAccreditationNumber', vet.accreditationNumber);
    }
  }

  static void _buildContact(xml.XmlBuilder builder, Contact contact) {
    builder.element('Address', nest: () {
      _buildInternationalAddress(builder, contact.address);
    });
    builder.element('Person', nest: () {
      builder.element('Name', nest: contact.name);
    });
  }

  static void _buildUSAddress(xml.XmlBuilder builder, Address addr) {
    builder.element('Address', nest: () {
      builder.element('Line1', nest: addr.street);
      builder.element('Town', nest: addr.city);
      builder.element('State', nest: addr.state.toUpperCase());
      builder.element('ZIP', nest: addr.postalCode);
      builder.element('Country', nest: 'USA');
    });
  }

  static void _buildInternationalAddress(xml.XmlBuilder builder, Address addr) {
    builder.element('Address', nest: () {
      builder.element('Line1', nest: addr.street);
      builder.element('Town', nest: addr.city);
      if (addr.state.isNotEmpty) builder.element('State', nest: addr.state);
      if (addr.postalCode.isNotEmpty) builder.element('ZIP', nest: addr.postalCode);
      builder.element('Country', nest: 'USA');
    });
  }

  static void _buildAnimal(xml.XmlBuilder builder, Animal a, String inspectionDate) {
    builder.element('Animal', nest: () {
      builder.element('SpeciesOther', nest: () {
        builder.attribute('Text', (a.species?.trim().isNotEmpty == true) ? a.species!.trim() : 'Unknown');
      });
      builder.element('AnimalTags', nest: () {
        _emitAnimalTag(builder, a.identifier);
      });
      if (a.breed?.trim().isNotEmpty == true) builder.attribute('Breed', a.breed!.trim());
      final sex = _mapSex(a.sex);
      if (sex != null) builder.attribute('Sex', sex);
      builder.attribute('InspectionDate', inspectionDate);
    });
  }

  static void _emitAnimalTag(xml.XmlBuilder builder, String id) {
    final s = id.trim();
    final ain = RegExp(r'^840\\d{12}\$');
    final mfr = RegExp(r'^(9[0-8]\d|9\d[0-8])\d{12}$');
    final fifteen = RegExp(r'^\d{15}$');
    final nues9 = RegExp(r'^(\d{2}|[A-Z]{2})[A-Z]{3}\d{4}$');
    final nues8 = RegExp(r'^\d{2}[A-Z]{2}\d{4}$');

    if (ain.hasMatch(s)) {
      builder.element('AIN', nest: () {
        builder.attribute('Number', s);
      });
    } else if (mfr.hasMatch(s)) {
      builder.element('MfrRFID', nest: () {
        builder.attribute('Number', s);
      });
    } else if (fifteen.hasMatch(s)) {
      // 15 digits: assume InternationalAIN if not 840 and not 900-series manufacturer
      builder.element('InternationalAIN', nest: () {
        builder.attribute('Number', s);
      });
    } else if (nues9.hasMatch(s)) {
      builder.element('NUES9', nest: () {
        builder.attribute('Number', s);
      });
    } else if (nues8.hasMatch(s)) {
      builder.element('NUES8', nest: () {
        builder.attribute('Number', s);
      });
    } else {
      // Fallback to ManagementID
      builder.element('ManagementID', nest: () {
        builder.attribute('Number', s);
      });
    }
  }

  static String _fmtDate(DateTime dt) =>
      '${dt.toUtc().year.toString().padLeft(4, '0')}-${dt.toUtc().month.toString().padLeft(2, '0')}-${dt.toUtc().day.toString().padLeft(2, '0')}';

  static String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  static String? _mapSex(String? s) {
    if (s == null) return null;
    final v = s.trim().toUpperCase();
    switch (v) {
      case 'F':
      case 'FEMALE':
        return 'Female';
      case 'M':
      case 'MALE':
        return 'Male';
      case 'G':
      case 'NEUTERED':
      case 'NEUTERED MALE':
        return 'Neutered Male';
      case 'SPAYED':
      case 'SPAYED FEMALE':
        return 'Spayed Female';
      case 'UNKNOWN':
      case 'U':
        return 'Gender Unknown';
      default:
        return null;
    }
  }
}

