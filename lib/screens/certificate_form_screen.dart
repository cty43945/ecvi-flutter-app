import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

import '../models/address.dart';
import '../models/animal.dart';
import '../models/certificate.dart';
import '../models/contact.dart';
import '../models/veterinarian.dart';
import '../services/db_helper.dart';

class CertificateFormScreen extends StatefulWidget {
  const CertificateFormScreen({super.key});

  @override
  State<CertificateFormScreen> createState() => _CertificateFormScreenState();
}

class _CertificateFormScreenState extends State<CertificateFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Veterinarian
  final vetFirstCtrl = TextEditingController();
  final vetLastCtrl = TextEditingController();
  final vetLicenseCtrl = TextEditingController();
  final vetLicenseStateCtrl = TextEditingController();
  final vetBusinessCtrl = TextEditingController();
  final vetPhoneCtrl = TextEditingController();
  final vetEmailCtrl = TextEditingController();

  // Consignor
  final consignorNameCtrl = TextEditingController();
  final consignorBizCtrl = TextEditingController();
  final consignorPhoneCtrl = TextEditingController();
  final consignorEmailCtrl = TextEditingController();
  final originStreetCtrl = TextEditingController();
  final originCityCtrl = TextEditingController();
  final originStateCtrl = TextEditingController();
  final originPostalCtrl = TextEditingController();

  // Consignee
  final consigneeNameCtrl = TextEditingController();
  final consigneeBizCtrl = TextEditingController();
  final consigneePhoneCtrl = TextEditingController();
  final consigneeEmailCtrl = TextEditingController();
  final destStreetCtrl = TextEditingController();
  final destCityCtrl = TextEditingController();
  final destStateCtrl = TextEditingController();
  final destPostalCtrl = TextEditingController();

  // Other
  final movementPurposeCtrl = TextEditingController();
  final statementsCtrl = TextEditingController();
  DateTime? _expirationDate;

  // Animals
  final List<Animal> animals = [];

  // Signature
  final SignatureController sigController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    for (final c in [
      vetFirstCtrl,
      vetLastCtrl,
      vetLicenseCtrl,
      vetLicenseStateCtrl,
      vetBusinessCtrl,
      vetPhoneCtrl,
      vetEmailCtrl,
      consignorNameCtrl,
      consignorBizCtrl,
      consignorPhoneCtrl,
      consignorEmailCtrl,
      originStreetCtrl,
      originCityCtrl,
      originStateCtrl,
      originPostalCtrl,
      consigneeNameCtrl,
      consigneeBizCtrl,
      consigneePhoneCtrl,
      consigneeEmailCtrl,
      destStreetCtrl,
      destCityCtrl,
      destStateCtrl,
      destPostalCtrl,
      movementPurposeCtrl,
      statementsCtrl,
    ]) {
      c.dispose();
    }
    sigController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _expirationDate = DateTime.now().add(const Duration(days: 30));
  }

  Future<String?> _saveSignaturePng(String certId) async {
    if (sigController.isEmpty) return null;
    final bytes = await sigController.toPngBytes();
    if (bytes == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final sigDir = Directory('${dir.path}${Platform.pathSeparator}signatures');
    if (!(await sigDir.exists())) await sigDir.create(recursive: true);
    final file = File('${sigDir.path}${Platform.pathSeparator}$certId.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  void _addAnimalDialog() {
    final idCtrl = TextEditingController();
    final speciesCtrl = TextEditingController();
    final breedCtrl = TextEditingController();
    final sexCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Animal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Identifier *')),
              TextField(controller: speciesCtrl, decoration: const InputDecoration(labelText: 'Species')),
              TextField(controller: breedCtrl, decoration: const InputDecoration(labelText: 'Breed')),
              TextField(controller: sexCtrl, decoration: const InputDecoration(labelText: 'Sex')),
              TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age')),
              TextField(controller: colorCtrl, decoration: const InputDecoration(labelText: 'Color')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (idCtrl.text.trim().isEmpty) return;
              setState(() {
                animals.add(Animal(
                  identifier: idCtrl.text.trim(),
                  species: speciesCtrl.text.trim().isEmpty ? null : speciesCtrl.text.trim(),
                  breed: breedCtrl.text.trim().isEmpty ? null : breedCtrl.text.trim(),
                  sex: sexCtrl.text.trim().isEmpty ? null : sexCtrl.text.trim(),
                  age: ageCtrl.text.trim().isEmpty ? null : ageCtrl.text.trim(),
                  color: colorCtrl.text.trim().isEmpty ? null : colorCtrl.text.trim(),
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _bulkImportDialog() {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Import IDs'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: textCtrl,
            decoration: const InputDecoration(
              hintText: 'Paste one ID per line',
              border: OutlineInputBorder(),
            ),
            minLines: 8,
            maxLines: 12,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final lines = textCtrl.text.split(RegExp(r'\r?\n'));
              final ids = lines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
              if (ids.isEmpty) return;
              setState(() {
                for (final id in ids) {
                  animals.add(Animal(identifier: id));
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromFile() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'txt'],
        withData: true,
      );
      if (res == null || res.files.isEmpty) return;
      final picked = res.files.single;
      final bytes = picked.bytes;
      String content;
      if (bytes == null) {
        if (picked.path == null) return;
        final file = File(picked.path!);
        content = await file.readAsString();
      } else {
        content = String.fromCharCodes(bytes);
      }
      final ext = (picked.extension ?? '').toLowerCase();
      if (ext == 'csv') {
        await _importCsv(content);
      } else {
        _importIdsFromString(content);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  void _importIdsFromString(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    final ids = lines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (ids.isEmpty) return;
    setState(() {
      for (final id in ids) {
        animals.add(Animal(identifier: id));
      }
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Imported ${ids.length} IDs from file')));
  }

  Future<void> _importCsv(String content) async {
    try {
      final rows = const CsvToListConverter(shouldParseNumbers: false).convert(content);
      if (rows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV is empty')));
        return;
      }
      final header = rows.first.map((e) => (e ?? '').toString()).toList();
      final dataRows = rows.skip(1).map((r) => r.map((e) => (e ?? '').toString()).toList()).toList();
      if (dataRows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV has no data rows')));
        return;
      }

      // Show mapping dialog
      await showDialog(
        context: context,
        builder: (context) {
          final normHeader = header.map(_normalizeHeader).toList(growable: false);
          int? idIdx = _guessIndex(normHeader, const ['identifier', 'id', 'rfid', 'tag', 'animalid', 'microchip', 'chip']);
          int? speciesIdx = _guessIndex(normHeader, const ['species']);
          int? breedIdx = _guessIndex(normHeader, const ['breed']);
          int? sexIdx = _guessIndex(normHeader, const ['sex', 'gender', 'sexcode']);
          int? ageIdx = _guessIndex(normHeader, const ['age', 'agemonths', 'ageyears']);
          int? colorIdx = _guessIndex(normHeader, const ['color', 'colour', 'markings']);
          int? testsIdx = _guessIndex(normHeader, const ['tests', 'test', 'vaccinations']);

          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text('Map CSV Columns'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _mapRow('Identifier (required)', header, idIdx, (v) => setState(() => idIdx = v)),
                    _mapRow('Species', header, speciesIdx, (v) => setState(() => speciesIdx = v), allowNone: true),
                    _mapRow('Breed', header, breedIdx, (v) => setState(() => breedIdx = v), allowNone: true),
                    _mapRow('Sex', header, sexIdx, (v) => setState(() => sexIdx = v), allowNone: true),
                    _mapRow('Age', header, ageIdx, (v) => setState(() => ageIdx = v), allowNone: true),
                    _mapRow('Color', header, colorIdx, (v) => setState(() => colorIdx = v), allowNone: true),
                    _mapRow('Tests (separated by ; or ,)', header, testsIdx, (v) => setState(() => testsIdx = v), allowNone: true),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: (idIdx == null)
                      ? null
                      : () {
                          final imported = <Animal>[];
                          for (final row in dataRows) {
                            String getVal(int? idx) => (idx != null && idx >= 0 && idx < row.length) ? row[idx].toString().trim() : '';
                            final id = getVal(idIdx);
                            if (id.isEmpty) continue;
                            final testsVal = getVal(testsIdx);
                            final tests = testsVal.isEmpty
                                ? null
                                : testsVal.split(RegExp(r'[;,]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                            imported.add(Animal(
                              identifier: id,
                              species: _toNull(getVal(speciesIdx)),
                              breed: _toNull(getVal(breedIdx)),
                              sex: _toNull(getVal(sexIdx)),
                              age: _toNull(getVal(ageIdx)),
                              color: _toNull(getVal(colorIdx)),
                              tests: tests,
                            ));
                          }
                          if (imported.isNotEmpty) {
                            setState(() {
                              animals.addAll(imported);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Imported ${imported.length} animals from CSV')),
                            );
                          }
                          Navigator.pop(context);
                        },
                  child: const Text('Import'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV parse failed: $e')));
    }
  }

  String _normalizeHeader(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  int? _guessIndex(List<String> normalizedHeaders, List<String> candidates) {
    for (final cand in candidates) {
      final idx = normalizedHeaders.indexOf(cand);
      if (idx != -1) return idx;
    }
    return null;
  }

  String? _toNull(String s) => s.trim().isEmpty ? null : s.trim();

  Widget _mapRow(String label, List<String> header, int? current, ValueChanged<int?> onChanged, {bool allowNone = false}) {
    final items = <DropdownMenuItem<int?>>[];
    if (allowNone) {
      items.add(const DropdownMenuItem<int?>(value: null, child: Text('None')));
    }
    for (var i = 0; i < header.length; i++) {
      items.add(DropdownMenuItem<int?>(value: i, child: Text(header[i])));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: current,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCertificate() async {
    if (!_formKey.currentState!.validate()) return;
    if (animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one animal')));
      return;
    }
    final now = DateTime.now();
    final licenseState = vetLicenseStateCtrl.text.trim().toUpperCase();
    final licenseNumber = vetLicenseCtrl.text.trim();
    final timestamp = now.toIso8601String().replaceAll(':', '').replaceAll('-', '');
    final certId = '$licenseState-$licenseNumber-$timestamp';
    final vet = Veterinarian(
      firstName: vetFirstCtrl.text.trim(),
      lastName: vetLastCtrl.text.trim(),
      licenseNumber: licenseNumber,
      licenseState: licenseState,
      businessName: _orNull(vetBusinessCtrl.text),
      phone: _orNull(vetPhoneCtrl.text),
      email: _orNull(vetEmailCtrl.text),
    );
    final consignor = Contact(
      name: consignorNameCtrl.text.trim(),
      businessName: _orNull(consignorBizCtrl.text),
      phone: _orNull(consignorPhoneCtrl.text),
      email: _orNull(consignorEmailCtrl.text),
      address: Address(
        street: originStreetCtrl.text.trim(),
        city: originCityCtrl.text.trim(),
        state: originStateCtrl.text.trim().toUpperCase(),
        postalCode: originPostalCtrl.text.trim(),
      ),
    );
    final consignee = Contact(
      name: consigneeNameCtrl.text.trim(),
      businessName: _orNull(consigneeBizCtrl.text),
      phone: _orNull(consigneePhoneCtrl.text),
      email: _orNull(consigneeEmailCtrl.text),
      address: Address(
        street: destStreetCtrl.text.trim(),
        city: destCityCtrl.text.trim(),
        state: destStateCtrl.text.trim().toUpperCase(),
        postalCode: destPostalCtrl.text.trim(),
      ),
    );
    final signaturePath = await _saveSignaturePng(certId);
    final certificate = Certificate(
      id: certId,
      veterinarian: vet,
      consignor: consignor,
      consignee: consignee,
      origin: consignor.address,
      destination: consignee.address,
      movementPurpose: movementPurposeCtrl.text.trim(),
      dateOfIssue: now,
      expirationDate: _expirationDate ?? now.add(const Duration(days: 30)),
      statements: _lines(statementsCtrl.text),
      animals: animals,
      signaturePath: signaturePath,
    );
    await DbHelper().insertCertificate(certificate);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Certificate saved')));
    Navigator.of(context).pop();
  }

  String? _required(String? v, {String field = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  String? _stateRequired(String? v) {
    final val = v?.trim().toUpperCase() ?? '';
    if (val.isEmpty) return 'State is required';
    if (val.length != 2) return 'Use 2-letter code';
    return null;
  }

  List<String> _lines(String text) => text
      .split(RegExp(r'\r?\n'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  String? _orNull(String? s) {
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Certificate'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Veterinarian'),
              Row(children: [
                Expanded(
                  child: TextFormField(controller: vetFirstCtrl, decoration: const InputDecoration(labelText: 'First Name *'), validator: (v) => _required(v, field: 'First name')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(controller: vetLastCtrl, decoration: const InputDecoration(labelText: 'Last Name *'), validator: (v) => _required(v, field: 'Last name')),
                ),
              ]),
              Row(children: [
                Expanded(
                  child: TextFormField(controller: vetLicenseCtrl, decoration: const InputDecoration(labelText: 'License Number *'), validator: (v) => _required(v, field: 'License number')),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextFormField(controller: vetLicenseStateCtrl, decoration: const InputDecoration(labelText: 'State *'), validator: _stateRequired, textCapitalization: TextCapitalization.characters),
                ),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: vetBusinessCtrl, decoration: const InputDecoration(labelText: 'Business'))),
              ]),
              Row(children: [
                Expanded(child: TextFormField(controller: vetPhoneCtrl, decoration: const InputDecoration(labelText: 'Phone'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: vetEmailCtrl, decoration: const InputDecoration(labelText: 'Email'))),
              ]),
              const Divider(),
              _sectionTitle('Consignor (Sender)'),
              TextFormField(controller: consignorNameCtrl, decoration: const InputDecoration(labelText: 'Name *'), validator: (v) => _required(v, field: 'Consignor name')),
              Row(children: [
                Expanded(child: TextFormField(controller: consignorBizCtrl, decoration: const InputDecoration(labelText: 'Business'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: consignorPhoneCtrl, decoration: const InputDecoration(labelText: 'Phone'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: consignorEmailCtrl, decoration: const InputDecoration(labelText: 'Email'))),
              ]),
              Row(children: [
                Expanded(child: TextFormField(controller: originStreetCtrl, decoration: const InputDecoration(labelText: 'Origin Street *'), validator: (v) => _required(v, field: 'Origin street'))),
              ]),
              Row(children: [
                Expanded(child: TextFormField(controller: originCityCtrl, decoration: const InputDecoration(labelText: 'Origin City *'), validator: (v) => _required(v, field: 'Origin city'))),
                const SizedBox(width: 12),
                SizedBox(width: 100, child: TextFormField(controller: originStateCtrl, decoration: const InputDecoration(labelText: 'State *'), validator: _stateRequired, textCapitalization: TextCapitalization.characters)),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: originPostalCtrl, decoration: const InputDecoration(labelText: 'ZIP *'), validator: (v) => _required(v, field: 'ZIP'))),
              ]),
              const Divider(),
              _sectionTitle('Consignee (Receiver)'),
              TextFormField(controller: consigneeNameCtrl, decoration: const InputDecoration(labelText: 'Name *'), validator: (v) => _required(v, field: 'Consignee name')),
              Row(children: [
                Expanded(child: TextFormField(controller: consigneeBizCtrl, decoration: const InputDecoration(labelText: 'Business'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: consigneePhoneCtrl, decoration: const InputDecoration(labelText: 'Phone'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: consigneeEmailCtrl, decoration: const InputDecoration(labelText: 'Email'))),
              ]),
              Row(children: [
                Expanded(child: TextFormField(controller: destStreetCtrl, decoration: const InputDecoration(labelText: 'Destination Street *'), validator: (v) => _required(v, field: 'Destination street'))),
              ]),
              Row(children: [
                Expanded(child: TextFormField(controller: destCityCtrl, decoration: const InputDecoration(labelText: 'Destination City *'), validator: (v) => _required(v, field: 'Destination city'))),
                const SizedBox(width: 12),
                SizedBox(width: 100, child: TextFormField(controller: destStateCtrl, decoration: const InputDecoration(labelText: 'State *'), validator: _stateRequired, textCapitalization: TextCapitalization.characters)),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: destPostalCtrl, decoration: const InputDecoration(labelText: 'ZIP *'), validator: (v) => _required(v, field: 'ZIP'))),
              ]),
              const Divider(),
              _sectionTitle('Movement & Statements'),
              TextFormField(controller: movementPurposeCtrl, decoration: const InputDecoration(labelText: 'Movement Purpose *'), validator: (v) => _required(v, field: 'Movement purpose')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Expiration Date *', border: OutlineInputBorder()),
                      child: Text('${_expirationDate!.toLocal()}'.split(' ').first),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expirationDate ?? now.add(const Duration(days: 30)),
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) {
                        setState(() {
                          _expirationDate = picked;
                        });
                      }
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: statementsCtrl,
                decoration: const InputDecoration(labelText: 'Statements (one per line)'),
                minLines: 3,
                maxLines: 5,
              ),
              const Divider(),
              _sectionTitle('Animals'),
              if (animals.isEmpty) const Text('(none yet)'),
              if (animals.isNotEmpty)
                Column(
                  children: animals
                      .asMap()
                      .entries
                      .map((e) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(e.value.identifier),
                            subtitle: Text([
                              e.value.species,
                              e.value.breed,
                              e.value.sex,
                              e.value.age,
                              e.value.color,
                            ].whereType<String>().where((s) => s.isNotEmpty).join(', ')),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => setState(() => animals.removeAt(e.key)),
                            ),
                          ))
                      .toList(),
                ),
              Row(children: [
                ElevatedButton.icon(onPressed: _addAnimalDialog, icon: const Icon(Icons.add), label: const Text('Add Animal')),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: _bulkImportDialog, icon: const Icon(Icons.file_upload), label: const Text('Bulk Import IDs')),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _importFromFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import CSV/TXT'),
                ),
              ]),
              const Divider(),
              _sectionTitle('Veterinarian Signature'),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
                height: 160,
                child: Signature(controller: sigController, backgroundColor: Colors.white),
              ),
              Row(children: [
                TextButton(onPressed: sigController.clear, child: const Text('Clear')),
              ]),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(onPressed: _saveCertificate, icon: const Icon(Icons.save), label: const Text('Save Certificate')),
                  const SizedBox(width: 8),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
