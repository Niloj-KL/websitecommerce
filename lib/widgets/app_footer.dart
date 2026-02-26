import 'package:flutter/material.dart';
import '../core/brand_text_styles.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 24),
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: Color(0xFFE7DECF))),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8ED), Color(0xFFF7F0E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB28B50).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 16,
            spacing: 16,
            children: const [
              _BrandBlock(),
              _ContactBlock(),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFE6DAC4)),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FooterPill(text: 'Terms of Service'),
              _FooterPill(text: 'Privacy Policy'),
              _FooterPill(text: 'Refund Policy'),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '© Elegant Way • Crafted with premium aesthetics',
            style: TextStyle(
              color: Color(0xFF6C5A3E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elegant Way',
          style: calligraphyAccentStyle(
            size: 22,
            color: Color(0xFF2A2318),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Refined fashion for everyday confidence.',
          style: inlineAccentStyle(size: 14, color: const Color(0xFF6F624B)),
        ),
      ],
    );
  }
}

class _ContactBlock extends StatelessWidget {
  const _ContactBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF2E271B),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'support@elegantway.lk',
          style: TextStyle(
            color: Color(0xFF6F624B),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3),
        Text(
          '+94 77 123 4567',
          style: TextStyle(
            color: Color(0xFF6F624B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FooterPill extends StatelessWidget {
  final String text;
  const _FooterPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2D3BA)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF5B4A31),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
