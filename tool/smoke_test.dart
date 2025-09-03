import 'dart:io';

import 'package:ecvi_flutter_app/models/address.dart';
import 'package:ecvi_flutter_app/models/animal.dart';
import 'package:ecvi_flutter_app/models/certificate.dart';
import 'package:ecvi_flutter_app/models/contact.dart';
import 'package:ecvi_flutter_app/models/veterinarian.dart';
import 'package:ecvi_flutter_app/services/pdf_generator.dart';
import 'package:ecvi_flutter_app/services/xml_generator.dart';
import 'package:ecvi_flutter_app/util/xml_sanity_check.dart';

Future<void> main() async {
  final cert = Certificate(
    id: 'MN-12345-20250101T000000Z',
    veterinarian: Veterinarian(
      firstName: 'John',
      lastName: 'Doe',
      licenseNumber: '12345',
      licenseState: 'MN',
      businessName: 'Doe Vet Clinic',
      phone: '555-123-4567',
      email: 'john.doe@example.com',
    ),
    consignor: Contact(
      name: 'Alice Farmer',
      businessName: 'Sunny Farms',
      phone: '555-111-2222',
      email: 'alice@example.com',
      address: Address(
        street: '100 Farm Rd',
        city: 'Bemidji',
        state: 'MN',
        postalCode: '56601',
      ),
    ),
    consignee: Contact(
      name: 'Bob Buyer',
      businessName: 'Cattle Co.',
      phone: '555-333-4444',
      email: 'bob@example.com',
      address: Address(
        street: '200 Ranch Ln',
        city: 'Fargo',
        state: 'ND',
        postalCode: '58102',
      ),
    ),
    origin: Address(
      street: '100 Farm Rd',
      city: 'Bemidji',
      state: 'MN',
      postalCode: '56601',
    ),
    destination: Address(
      street: '200 Ranch Ln',
      city: 'Fargo',
      state: 'ND',
      postalCode: '58102',
    ),
    movementPurpose: 'Sale',
    dateOfIssue: DateTime.now().toUtc(),
    expirationDate: DateTime.now().toUtc().add(const Duration(days: 30)),
    statements: const ['Animals inspected and found free of communicable disease.'],
    animals: [
      Animal(identifier: 'RFID-001', species: 'Bovine', breed: 'Beef', sex: 'F', age: '2 years'),
      Animal(identifier: 'RFID-002', species: 'Bovine', breed: 'Beef', sex: 'M', age: '3 years'),
    ],
    signaturePath: null,
  );

  final xml = XmlGenerator.generateEcviXml(cert);
  stdout.writeln('XML length: ${xml.length}');
  final xmlOut = File('tool_out.xml');
  await xmlOut.writeAsString(xml);
  final errors = <String>[];
  final ok = checkEcviXml(xml, errors: errors);
  stdout.writeln('XML sanity check: ${ok ? 'OK' : 'FAIL'}');
  if (!ok) {
    for (final e in errors) {
      stdout.writeln(' - $e');
    }
  }
  final pdfBytes = await PdfGenerator.generatePdf(cert);
  stdout.writeln('PDF bytes: ${pdfBytes.length}');
}
