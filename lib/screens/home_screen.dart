import 'package:flutter/material.dart';

import '../models/certificate.dart';
import '../services/db_helper.dart';
import 'certificate_form_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCertificates();
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
                return ListTile(
                  title: Text(cert.id),
                  subtitle: Text('Issued on ${cert.dateOfIssue.toLocal().toString().split(' ').first}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: implement certificate detail view
                  },
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