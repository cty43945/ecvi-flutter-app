import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ecvi_flutter_app/util/format.dart';

import '../models/animal.dart';
import '../models/certificate.dart';
import '../services/db_helper.dart';
import '../services/pdf_generator.dart';
import '../services/xml_generator.dart';

class CertificateDetailScreen extends StatefulWidget {
  const CertificateDetailScreen({super.key, required this.certificate});

  final Certificate certificate;

  @override
  State<CertificateDetailScreen> createState() => _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen> {
  late Future<List<Animal>> _animalsFuture;

  @override
  void initState() {
    super.initState();
    _animalsFuture = DbHelper().getAnimalsForCertificate(widget.certificate.id);
  }

  Future<Directory> _ensureDir(Directory base, String name) async {
    final dir = Directory('${base.path}${Platform.pathSeparator}$name');
    if (!(await dir.exists())) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _exportXml() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final outDir = await _ensureDir(docs, 'exports');
      // Load animals to include them in XML
      final animals = await DbHelper().getAnimalsForCertificate(widget.certificate.id);
      final cert = Certificate(
        id: widget.certificate.id,
        veterinarian: widget.certificate.veterinarian,
        consignor: widget.certificate.consignor,
        consignee: widget.certificate.consignee,
        origin: widget.certificate.origin,
        destination: widget.certificate.destination,
        movementPurpose: widget.certificate.movementPurpose,
        dateOfIssue: widget.certificate.dateOfIssue,
        expirationDate: widget.certificate.expirationDate,
        statements: widget.certificate.statements,
        animals: animals,
        signaturePath: widget.certificate.signaturePath,
      );
      final xml = XmlGenerator.generateEcviXml(cert);
      final file = File('${outDir.path}${Platform.pathSeparator}${cert.id}.xml');
      await file.writeAsString(xml);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('XML saved to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export XML: $e')),
        );
      }
    }
  }

  Future<void> _exportPdf() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final outDir = await _ensureDir(docs, 'exports');
      final animals = await DbHelper().getAnimalsForCertificate(widget.certificate.id);
      final cert = Certificate(
        id: widget.certificate.id,
        veterinarian: widget.certificate.veterinarian,
        consignor: widget.certificate.consignor,
        consignee: widget.certificate.consignee,
        origin: widget.certificate.origin,
        destination: widget.certificate.destination,
        movementPurpose: widget.certificate.movementPurpose,
        dateOfIssue: widget.certificate.dateOfIssue,
        expirationDate: widget.certificate.expirationDate,
        statements: widget.certificate.statements,
        animals: animals,
        signaturePath: widget.certificate.signaturePath,
      );
      final bytes = await PdfGenerator.generatePdf(cert);
      final file = File('${outDir.path}${Platform.pathSeparator}${cert.id}.pdf');
      await file.writeAsBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e')),
        );
      }
    }
  }

  Future<void> _shareXml() async {
    final docs = await getApplicationDocumentsDirectory();
    final outDir = await _ensureDir(docs, 'exports');
    await _exportXml();
    final file = File('${outDir.path}${Platform.pathSeparator}${widget.certificate.id}.xml');
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: 'eCVI XML: ${widget.certificate.id}');
    }
  }

  Future<void> _sharePdf() async {
    final docs = await getApplicationDocumentsDirectory();
    final outDir = await _ensureDir(docs, 'exports');
    await _exportPdf();
    final file = File('${outDir.path}${Platform.pathSeparator}${widget.certificate.id}.pdf');
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: 'eCVI PDF: ${widget.certificate.id}');
    }
  }

  Widget _buildSectionTitle(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    final cert = widget.certificate;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Details'),
        actions: [
          IconButton(onPressed: _exportXml, tooltip: 'Export XML', icon: const Icon(Icons.code)),
          IconButton(onPressed: _exportPdf, tooltip: 'Export PDF', icon: const Icon(Icons.picture_as_pdf)),
          IconButton(onPressed: _shareXml, tooltip: 'Share XML', icon: const Icon(Icons.share)),
          IconButton(onPressed: _sharePdf, tooltip: 'Share PDF', icon: const Icon(Icons.ios_share)),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Certificate'),
                  content: const Text('This will permanently delete this certificate and its animals.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: const ButtonStyle(),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await DbHelper().deleteCertificate(widget.certificate.id);
                if (!mounted) return;
                Navigator.of(context).pop(true);
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Core Info'),
              Text('ID: ${cert.id}'),
              Text('Issued: ${formatDateMmddyyyy(cert.dateOfIssue)}'),
              Text('Expires: ${formatDateMmddyyyy(cert.expirationDate)}'),
              Text('Purpose: ${cert.movementPurpose}'),
              const Divider(),
              _buildSectionTitle('Veterinarian'),
              Text(cert.veterinarian.fullName),
              if (cert.veterinarian.businessName != null) Text(cert.veterinarian.businessName!),
              Text('License: ${cert.veterinarian.licenseNumber} (${cert.veterinarian.licenseState})'),
              if (cert.veterinarian.phone != null) Text('Phone: ${cert.veterinarian.phone}'),
              if (cert.veterinarian.email != null) Text('Email: ${cert.veterinarian.email}'),
              const Divider(),
              _buildSectionTitle('Consignor'),
              Text(cert.consignor.name),
              if (cert.consignor.businessName != null) Text(cert.consignor.businessName!),
              Text('${cert.origin.street}, ${cert.origin.city}, ${cert.origin.state} ${cert.origin.postalCode}'),
              const Divider(),
              _buildSectionTitle('Consignee'),
              Text(cert.consignee.name),
              if (cert.consignee.businessName != null) Text(cert.consignee.businessName!),
              Text('${cert.destination.street}, ${cert.destination.city}, ${cert.destination.state} ${cert.destination.postalCode}'),
              const Divider(),
              _buildSectionTitle('Statements'),
              if (cert.statements.isEmpty) const Text('(none)'),
              ...cert.statements.map((s) => Text('• ')),
              const Divider(),
              _buildSectionTitle('Animals'),
              FutureBuilder<List<Animal>>(
                future: _animalsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  final animals = snapshot.data ?? const <Animal>[];
                  if (animals.isEmpty) {
                    return const Text('No animals recorded.');
                  }
                  return Column(
                    children: animals
                        .map((a) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(a.identifier),
                              subtitle: Text([
                                a.species,
                                a.breed,
                                a.sex,
                                a.age,
                                a.color,
                              ].whereType<String>().where((e) => e.isNotEmpty).join(', ')),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(onPressed: _exportXml, icon: const Icon(Icons.code), label: const Text('Export XML')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(onPressed: _exportPdf, icon: const Icon(Icons.picture_as_pdf), label: const Text('Export PDF')),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(onPressed: _shareXml, icon: const Icon(Icons.share), label: const Text('Share XML')),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(onPressed: _sharePdf, icon: const Icon(Icons.ios_share), label: const Text('Share PDF')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}










