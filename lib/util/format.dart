String formatDateMmddyyyy(DateTime dt) {
  final d = dt.toLocal();
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  final y = d.year.toString().padLeft(4, '0');
  return '$m/$day/$y';
}

