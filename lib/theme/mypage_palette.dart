import 'package:flutter/material.dart';

class MyPagePalette {
  final Color bg, fg, muted, panel, border, chipBg, accentBg, accentFg;

  const MyPagePalette({
    required this.bg,
    required this.fg,
    required this.muted,
    required this.panel,
    required this.border,
    required this.chipBg,
    required this.accentBg,
    required this.accentFg,
  });

  factory MyPagePalette.fromBrightness(bool isDark) => isDark
      ? const MyPagePalette(
    bg: Color(0xFF0D1117),
    panel: Color(0xFF151A20),
    border: Color(0xFF2A2F36),
    fg: Color(0xFFE6E8EB),
    muted: Color(0xFF9BA3AF),
    chipBg: Color(0xFF11161B),
    accentBg: Color(0xFF1E2530),
    accentFg: Color(0xFF9FB4D9),
  )
      : const MyPagePalette(
    bg: Color(0xFFF7F8FA),
    panel: Colors.white,
    border: Color(0xFFE3E8EF),
    fg: Color(0xFF0F172A),
    muted: Color(0xFF6B7280),
    chipBg: Color(0xFFF1F5F9),
    accentBg: Color(0xFFE7EEF8),
    accentFg: Color(0xFF3B5B8D),
  );
}
