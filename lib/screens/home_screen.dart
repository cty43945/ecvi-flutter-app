import 'package:flutter/material.dart';

import '../models/certificate.dart';
import '../services/db_helper.dart';
import '../services/xml_generator.dart';
import '../services/pdf_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:ecvi_flutter_app/screens/certificate_form_screen.dart';
import 'package:ecvi_flutter_app/screens/certificate_detail_screen.dart';
import 'package:ecvi_flutter_app/util/format.dart';

/// The home screen displays a list of previously saved certificates and
/// offers an action to create a new one.  When tapped, a certificate
/// entry opens a detail view (not yet implemented).  This screen uses
/// [DbHelper] to retrieve certificates from local storage.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Certificate>> _certificates;

  // Use shared formatter from util/format.dart

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<Directory> _ensureDir(Directory base, String name) async {
    final dir = Directory('${base.path}${Platform.pathSeparator}$name');
    if (!(await dir.exists())) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _exportXml(Certificate c) async {
    try {
      final animals = await DbHelper().getAnimalsForCertificate(c.id);
      final cert = Certificate(
        id: c.id,
        veterinarian: c.veterinarian,
        consignor: c.consignor,
        consignee: c.consignee,
        origin: c.origin,
        destination: c.destination,
        movementPurpose: c.movementPurpose,
        dateOfIssue: c.dateOfIssue,
        expirationDate: c.expirationDate,
        statements: c.statements,
        animals: animals,
        signaturePath: c.signaturePath,
      );
      final xml = XmlGenerator.generateEcviXml(cert);
      final docs = await getApplicationDocumentsDirectory();
      final outDir = await _ensureDir(docs, 'exports');
      final file = File('${outDir.path}${Platform.pathSeparator}${c.id}.xml');
      await file.writeAsString(xml);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('XML saved to ${file.path}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('XML export failed: $e')));
      }
    }
  }

  Future<void> _exportPdf(Certificate c) async {
    try {
      final animals = await DbHelper().getAnimalsForCertificate(c.id);
      final cert = Certificate(
        id: c.id,
        veterinarian: c.veterinarian,
        consignor: c.consignor,
        consignee: c.consignee,
        origin: c.origin,
        destination: c.destination,
        movementPurpose: c.movementPurpose,
        dateOfIssue: c.dateOfIssue,
        expirationDate: c.expirationDate,
        statements: c.statements,
        animals: animals,
        signaturePath: c.signaturePath,
      );
      final bytes = await PdfGenerator.generatePdf(cert);
      final docs = await getApplicationDocumentsDirectory();
      final outDir = await _ensureDir(docs, 'exports');
      final file = File('${outDir.path}${Platform.pathSeparator}${c.id}.pdf');
      await file.writeAsBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF saved to ${file.path}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
      }
    }
  }

  Future<void> _shareXml(Certificate c) async {
    await _exportXml(c);
    final docs = await getApplicationDocumentsDirectory();
    final file = File('${docs.path}${Platform.pathSeparator}exports${Platform.pathSeparator}${c.id}.xml');
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: 'eCVI XML: ${c.id}');
    }
  }

  Future<void> _sharePdf(Certificate c) async {
    await _exportPdf(c);
    final docs = await getApplicationDocumentsDirectory();
    final file = File('${docs.path}${Platform.pathSeparator}exports${Platform.pathSeparator}${c.id}.pdf');
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: 'eCVI PDF: ${c.id}');
    }
  }

  void _loadCertificates() {
    _certificates = DbHelper().getCertificates();
  }

  void _navigateToNewCertificate() async {
    // Navigate to the certificate form. When the form returns, reload list.
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CertificateFormScreen()),
    );
    setState(() {
      _loadCertificates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eCVI Certificates'),
      ),
      body: FutureBuilder<List<Certificate>>(
        future: _certificates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final certs = snapshot.data ?? [];
            if (certs.isEmpty) {
              return const Center(child: Text('No certificates found.'));
            }
            return ListView.builder(
              itemCount: certs.length,
              itemBuilder: (context, index) {
                final cert = certs[index];
                return Dismissible(
                  key: ValueKey('cert-${cert.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Certificate'),
                        content: Text('Delete ${cert.id}? This cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    await DbHelper().deleteCertificate(cert.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted ${cert.id}')));
                    setState(() {
                      _loadCertificates();
                    });
                  },
                  child: ListTile(
                    title: Text(cert.id),
                    subtitle: Text('Issued ${formatDateMmddyyyy(cert.dateOfIssue)}  •  Expires ${formatDateMmddyyyy(cert.expirationDate)}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case 'export_xml':
                            await _exportXml(cert);
                            break;
                          case 'export_pdf':
                            await _exportPdf(cert);
                            break;
                          case 'share_xml':
                            await _shareXml(cert);
                            break;
                          case 'share_pdf':
                            await _sharePdf(cert);
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'export_xml', child: Text('Export XML')),
                        PopupMenuItem(value: 'export_pdf', child: Text('Export PDF')),
                        PopupMenuItem(value: 'share_xml', child: Text('Share XML')),
                        PopupMenuItem(value: 'share_pdf', child: Text('Share PDF')),
                      ],
                    ),
                    onTap: () async {
                      final changed = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CertificateDetailScreen(certificate: cert),
                        ),
                      );
                      if (changed == true) {
                        setState(() {
                          _loadCertificates();
                        });
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewCertificate,
        child: const Icon(Icons.add),
      ),
    );
  }
}
