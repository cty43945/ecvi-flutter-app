import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/address.dart';
import '../models/animal.dart';
import '../models/certificate.dart';
import '../models/contact.dart';
import '../models/veterinarian.dart';
import '../services/db_helper.dart';

/// Placeholder screen for creating a new certificate.
///
/// This screen currently demonstrates how a certificate might be created and
/// saved using dummy data.  A full implementation should present a form to
/// enter consignor/consignee information, add animals, capture a signature,
/// and then construct a [Certificate] object accordingly.
class CertificateFormScreen extends StatelessWidget {
  const CertificateFormScreen({super.key});

  void _saveDummyCertificate(BuildContext context) async {
    // Example: generate a certificate with minimal required data using dummy
    // values.  In a real app, gather these from user input.
    const uuid = Uuid();
    final now = DateTime.now();
    final certId = 'MN-12345-${now.toIso8601String().replaceAll(':', '').replaceAll('-', '')}';
    final vet = Veterinarian(
      firstName: 'John',
      lastName: 'Doe',
      licenseNumber: '12345',
      licenseState: 'MN',
      businessName: 'Doe Vet Clinic',
      phone: '555-123-4567',
      email: '[email protected]',
    );
    final consignor = Contact(
      name: 'Alice Farmer',
      businessName: 'Sunny Farms',
      phone: '555-111-2222',
      email: '[email protected]',
      address: Address(street: '100 Farm Rd', city: 'Bemidji', state: 'MN', postalCode: '56601'),
    );
    final consignee = Contact(
      name: 'Bob Buyer',
      businessName: 'Cattle Co.',
      phone: '555-333-4444',
      email: '[email protected]',
      address: Address(street: '200 Ranch Ln', city: 'Fargo', state: 'ND', postalCode: '58102'),
    );
    final animals = <Animal>[
      Animal(identifier: uuid.v4(), species: 'Bovine', breed: 'Beef', sex: 'F', age: '2 years'),
      Animal(identifier: uuid.v4(), species: 'Bovine', breed: 'Beef', sex: 'M', age: '3 years'),
    ];
    final certificate = Certificate(
      id: certId,
      veterinarian: vet,
      consignor: consignor,
      consignee: consignee,
      origin: consignor.address,
      destination: consignee.address,
      movementPurpose: 'Sale',
      dateOfIssue: now,
      statements: ['Animals were inspected and found free of communicable disease.'],
      animals: animals,
      signaturePath: null,
    );
    await DbHelper().insertCertificate(certificate);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Certificate saved')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Certificate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Certificate form coming soon.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text('For now, press the button below to create a dummy certificate.'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _saveDummyCertificate(context),
              icon: const Icon(Icons.save),
              label: const Text('Save Dummy Certificate'),
            ),
          ],
        ),
      ),
    );
  }
}