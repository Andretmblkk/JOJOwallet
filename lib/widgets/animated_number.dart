import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedNumber extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final Duration duration;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.prefix = 'Rp ',
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutQuart,
      builder: (context, val, child) {
        final formatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: prefix,
          decimalDigits: 0,
        );
        return Text(
          formatter.format(val),
          style: style,
        );
      },
    );
  }
}
