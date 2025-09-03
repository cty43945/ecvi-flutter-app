import 'dart:io';

/// Attempts to validate an XML file against an XSD using xmllint if available.
/// Usage: dart run tool/xsd_validate.dart <xmlPath> <xsdPath>
Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln('Usage: dart run tool/xsd_validate.dart <xmlPath> <xsdPath>');
    exitCode = 2;
    return;
  }
  final xmlPath = args[0];
  final xsdPath = args[1];
  final xmllint = await _which('xmllint');
  if (xmllint == null) {
    stderr.writeln('xmllint not found on PATH. Install libxml2 tools to enable XSD validation.');
    exitCode = 127;
    return;
  }
  final result = await Process.run(xmllint, ['--noout', '--schema', xsdPath, xmlPath]);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  exitCode = result.exitCode;
}

Future<String?> _which(String cmd) async {
  if (Platform.isWindows) {
    final where = await Process.run('where', [cmd]);
    if (where.exitCode == 0) {
      final line = where.stdout.toString().split(RegExp(r'[\r\n]+')).firstWhere(
            (e) => e.trim().isNotEmpty,
            orElse: () => '',
          );
      return line.isNotEmpty ? line.trim() : null;
    }
    return null;
  } else {
    final which = await Process.run('which', [cmd]);
    if (which.exitCode == 0) return which.stdout.toString().trim();
    return null;
  }
}

