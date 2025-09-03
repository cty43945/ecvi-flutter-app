import 'package:xml/xml.dart' as xml;

import '../models/animal.dart';
import '../models/certificate.dart';
import '../models/contact.dart';
import '../models/address.dart';
import '../models/veterinarian.dart';

/// Generates an eCVI XML document conforming to version 2 of the USAHA/AAVLD
/// data exchange standard.  The output string can be saved to a file with
/// extension `.xml` and supplied to state animal health authorities.
///
/// See the eCVI schema on GitHub for the canonical structure【1†L232-L239】.
class XmlGenerator {
  /// Schema version attribute to include on the root `<eCVI>` element.  The
  /// official schema as of 2025 is version "3.1"【30†L43-L50】.  If the
  /// schema changes, update this constant accordingly.
  static const String xmlSchemaVersion = '3.1';

  /// Creates a string containing XML for the provided [certificate].
  static String generateEcviXml(Certificate certificate) {
    final builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('eCVI', namespaces: {
      // The official namespace for eCVI v2 (this should match the schema).
      '': 'http://www.usaha.org/xmlns/ecvi2',
    }, nest: () {
      builder.attribute('XMLSchemaVersion', xmlSchemaVersion);
      _buildCertificate(builder, certificate);
    });
    final document = builder.buildDocument();
    return document.toXmlString(pretty: true);
  }

  static void _buildCertificate(xml.XmlBuilder builder, Certificate cert) {
    builder.element('Certificate', nest: () {
      builder.attribute('certificateID', cert.id);
      builder.element('IssueDate', nest: cert.dateOfIssue.toUtc().toIso8601String());
      builder.element('MovementPurpose', nest: cert.movementPurpose);
      // Veterinarian
      builder.element('Veterinarian', nest: () {
        _buildVeterinarian(builder, cert.veterinarian);
      });
      // Consignor (sender)
      builder.element('Consignor', nest: () {
        _buildContact(builder, cert.consignor);
      });
      // Consignee (receiver)
      builder.element('Consignee', nest: () {
        _buildContact(builder, cert.consignee);
      });
      // Origin and destination
      builder.element('Origin', nest: () {
        _buildAddress(builder, cert.origin);
      });
      builder.element('Destination', nest: () {
        _buildAddress(builder, cert.destination);
      });
      // Statements (if any)
      if (cert.statements.isNotEmpty) {
        builder.element('Statements', nest: () {
          for (final stmt in cert.statements) {
            builder.element('Statement', nest: stmt);
          }
        });
      }
      // Animals list
      builder.element('Animals', nest: () {
        for (final animal in cert.animals) {
          _buildAnimal(builder, animal);
        }
      });
    });
  }

  static void _buildVeterinarian(xml.XmlBuilder builder, Veterinarian vet) {
    builder.element('Name', nest: () {
      builder.element('FirstName', nest: vet.firstName);
      builder.element('LastName', nest: vet.lastName);
    });
    if (vet.businessName != null && vet.businessName!.isNotEmpty) {
      builder.element('BusinessName', nest: vet.businessName);
    }
    builder.element('License', nest: () {
      builder.attribute('state', vet.licenseState);
      builder.text(vet.licenseNumber);
    });
    if (vet.accreditationNumber != null && vet.accreditationNumber!.isNotEmpty) {
      builder.element('AccreditationNumber', nest: vet.accreditationNumber);
    }
    if (vet.address != null) {
      builder.element('Address', nest: () {
        _buildAddress(builder, vet.address!);
      });
    }
    if (vet.phone != null) {
      builder.element('Phone', nest: vet.phone);
    }
    if (vet.email != null) {
      builder.element('Email', nest: vet.email);
    }
  }

  static void _buildContact(xml.XmlBuilder builder, Contact contact) {
    builder.element('Name', nest: contact.name);
    if (contact.businessName != null && contact.businessName!.isNotEmpty) {
      builder.element('BusinessName', nest: contact.businessName);
    }
    if (contact.phone != null) {
      builder.element('Phone', nest: contact.phone);
    }
    if (contact.email != null) {
      builder.element('Email', nest: contact.email);
    }
    builder.element('Address', nest: () {
      _buildAddress(builder, contact.address);
    });
  }

  static void _buildAddress(xml.XmlBuilder builder, Address address) {
    builder.element('Street', nest: address.street);
    builder.element('City', nest: address.city);
    builder.element('State', nest: address.state);
    builder.element('PostalCode', nest: address.postalCode);
    builder.element('Country', nest: address.country);
  }

  static void _buildAnimal(xml.XmlBuilder builder, Animal animal) {
    builder.element('Animal', nest: () {
      builder.element('Identifier', nest: animal.identifier);
      if (animal.species != null) {
        builder.element('Species', nest: animal.species);
      }
      if (animal.breed != null) {
        builder.element('Breed', nest: animal.breed);
      }
      if (animal.sex != null) {
        builder.element('Sex', nest: animal.sex);
      }
      if (animal.age != null) {
        builder.element('Age', nest: animal.age);
      }
      if (animal.color != null) {
        builder.element('Color', nest: animal.color);
      }
      if (animal.tests != null && animal.tests!.isNotEmpty) {
        builder.element('Tests', nest: () {
          for (final t in animal.tests!) {
            builder.element('Test', nest: t);
          }
        });
      }
    });
  }
}