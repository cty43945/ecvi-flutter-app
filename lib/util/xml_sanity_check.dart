import 'package:xml/xml.dart' as xml;

bool checkEcviXml(String xmlStr, {List<String>? errors}) {
  errors ??= <String>[];
  try {
    final doc = xml.XmlDocument.parse(xmlStr);
    final root = doc.rootElement;
    if (root.name.local != 'eCVI') {
      errors.add('Root element must be <eCVI>');
    }
    final schemaVersion = root.getAttribute('XMLSchemaVersion');
    if (schemaVersion == null || schemaVersion.isEmpty) {
      errors.add('Missing XMLSchemaVersion attribute');
    }
    final cviNumber = root.getAttribute('CviNumber');
    if (cviNumber == null || cviNumber.isEmpty) {
      errors.add('Missing CviNumber attribute');
    }
    for (final attr in ['IssueDate', 'ExpirationDate']) {
      if ((root.getAttribute(attr) ?? '').isEmpty) {
        errors.add('Missing $attr attribute');
      }
    }
    // Required structure: eCVI contains specific children and at least one Animal
    final topRequired = <String>['Veterinarian', 'MovementPurposes', 'Origin', 'Destination'];
    for (final name in topRequired) {
      if (root.findElements(name).isEmpty) {
        errors.add('Missing <$name> under <eCVI>');
      }
    }
    final animals = root.findElements('Animal');
    if (animals.isEmpty) {
      errors.add('At least one <Animal> is required');
    }
  } catch (e) {
    errors.add('XML parse error: $e');
  }
  return errors.isEmpty;
}

// (no extensions currently required)


