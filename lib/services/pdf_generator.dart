import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/certificate.dart';
import '../models/animal.dart';
import '../util/format.dart';

/// Utility class for generating a human‑readable PDF certificate.
///
/// The generated PDF includes all certificate data and the vet’s signature.
/// It can be saved to a file and shared via email or printed directly from
/// within the app using a PDF viewer.  The layout is a basic example and
/// should be customized to match official form requirements.
class PdfGenerator {
  /// Creates a PDF document as a [Uint8List].  The caller can write this
  /// byte list to a file or present it in a PDF viewer.
  static Future<Uint8List> generatePdf(Certificate cert) async {
    final doc = pw.Document();
    final pw.TextStyle headerStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
    );
    final pw.TextStyle labelStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    final pw.TextStyle valueStyle = pw.TextStyle(
      fontSize: 10,
    );

    // Load signature image if present
    pw.ImageProvider? signatureImage;
    if (cert.signaturePath != null) {
      final file = File(cert.signaturePath!);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        signatureImage = pw.MemoryImage(bytes);
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Text('Certificate of Veterinary Inspection', style: headerStyle),
            pw.SizedBox(height: 8),
            _buildCertificateInfo(cert, labelStyle, valueStyle),
            pw.SizedBox(height: 12),
            _buildPartySection('Consignor (Sender)', cert.consignor, labelStyle, valueStyle),
            pw.SizedBox(height: 8),
            _buildPartySection('Consignee (Receiver)', cert.consignee, labelStyle, valueStyle),
            pw.SizedBox(height: 8),
            _buildAddressSection('Origin', cert.origin, labelStyle, valueStyle),
            pw.SizedBox(height: 8),
            _buildAddressSection('Destination', cert.destination, labelStyle, valueStyle),
            pw.SizedBox(height: 12),
            _buildAnimalsTable(cert.animals),
            pw.SizedBox(height: 12),
            _buildStatements(cert.statements),
            pw.SizedBox(height: 16),
            _buildSignature(cert, signatureImage),
          ];
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildCertificateInfo(Certificate cert, pw.TextStyle labelStyle, pw.TextStyle valueStyle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(children: [
          pw.Text('Certificate ID: ', style: labelStyle),
          pw.Text(cert.id, style: valueStyle),
        ]),
        pw.Row(children: [
          pw.Text('Issue Date: ', style: labelStyle),
          pw.Text(formatDateMmddyyyy(cert.dateOfIssue), style: valueStyle),
        ]),
        pw.Row(children: [
          pw.Text('Expiration Date: ', style: labelStyle),
          pw.Text(formatDateMmddyyyy(cert.expirationDate), style: valueStyle),
        ]),
        pw.Row(children: [
          pw.Text('Purpose of Movement: ', style: labelStyle),
          pw.Text(cert.movementPurpose, style: valueStyle),
        ]),
      ],
    );
  }

  static pw.Widget _buildPartySection(String title, dynamic contact, pw.TextStyle labelStyle, pw.TextStyle valueStyle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: labelStyle.copyWith(fontSize: 12)),
        pw.Text(contact.name, style: valueStyle),
        if (contact.businessName != null && contact.businessName!.isNotEmpty)
          pw.Text(contact.businessName!, style: valueStyle),
        if (contact.phone != null && contact.phone!.isNotEmpty)
          pw.Text('Phone: ${contact.phone}', style: valueStyle),
        if (contact.email != null && contact.email!.isNotEmpty)
          pw.Text('Email: ${contact.email}', style: valueStyle),
        _buildAddressSection('', contact.address, labelStyle, valueStyle),
      ],
    );
  }

  static pw.Widget _buildAddressSection(String title, dynamic address, pw.TextStyle labelStyle, pw.TextStyle valueStyle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) pw.Text(title, style: labelStyle.copyWith(fontSize: 12)),
        pw.Text('${address.street}', style: valueStyle),
        pw.Text('${address.city}, ${address.state} ${address.postalCode}', style: valueStyle),
        if (address.country != null && address.country != 'US')
          pw.Text('${address.country}', style: valueStyle),
      ],
    );
  }

  static pw.Widget _buildAnimalsTable(List<Animal> animals) {
    final headers = ['ID', 'Species', 'Breed', 'Sex', 'Age', 'Color'];
    final data = animals.map((a) => [
          a.identifier,
          a.species ?? '',
          a.breed ?? '',
          a.sex ?? '',
          a.age ?? '',
          a.color ?? '',
        ]).toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Animals', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
          headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(fontSize: 8),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        ),
      ],
    );
  }

  static pw.Widget _buildStatements(List<String> statements) {
    if (statements.isEmpty) return pw.Container();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Statements', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        ...statements.map((s) => pw.Text('- $s', style: pw.TextStyle(fontSize: 8))),
      ],
    );
  }

  static pw.Widget _buildSignature(Certificate cert, pw.ImageProvider? signatureImage) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Veterinarian Signature', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        if (signatureImage != null)
          pw.Image(signatureImage, width: 200, height: 60, fit: pw.BoxFit.contain),
        if (signatureImage == null)
          pw.Text('(Signature not captured)', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
        pw.SizedBox(height: 4),
        pw.Text(cert.veterinarian.fullName, style: pw.TextStyle(fontSize: 8)),
        pw.Text('License: ${cert.veterinarian.licenseNumber} (${cert.veterinarian.licenseState})', style: pw.TextStyle(fontSize: 8)),
        if (cert.veterinarian.accreditationNumber != null && cert.veterinarian.accreditationNumber!.isNotEmpty)
          pw.Text('Accreditation: ${cert.veterinarian.accreditationNumber}', style: pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}
