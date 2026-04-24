import 'package:intl/intl.dart';

/// Format angka menjadi mata uang Rupiah Indonesia.
/// Contoh: 1.500.000 → "Rp 1.500.000"
String formatRupiah(double value, {bool showSymbol = true}) {
  final fmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: showSymbol ? 'Rp ' : '',
    decimalDigits: 0,
  );
  return fmt.format(value);
}

/// Format angka besar menjadi singkatan ringkas.
/// Contoh: 1.500.000 → "1,5 jt" | 750.000 → "750 rb"
String formatRupiahRingkas(double value) {
  if (value >= 1000000000) {
    final m = value / 1000000000;
    return 'Rp ${_formatDecimal(m)} M';
  } else if (value >= 1000000) {
    final m = value / 1000000;
    return 'Rp ${_formatDecimal(m)} jt';
  } else if (value >= 1000) {
    final m = value / 1000;
    return 'Rp ${_formatDecimal(m)} rb';
  }
  return formatRupiah(value);
}

String _formatDecimal(double v) {
  // Gunakan koma sebagai desimal (id_ID), tanpa desimal jika bulat
  if (v == v.floorToDouble()) {
    return v.toInt().toString();
  }
  return v.toStringAsFixed(1).replaceAll('.', ',');
}
