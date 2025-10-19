import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String _sanitizePhone(String? raw) {
  var p = (raw ?? '').trim();
  if (p.isEmpty) return '';
  p = p.replaceAll(RegExp(r'[\s\-KATEX_INLINE_OPENKATEX_INLINE_CLOSE]'), '');
  if (p.startsWith('00')) p = '+${p.substring(2)}';
  return p;
}

Future<void> launchCaller(BuildContext context, String? phone) async {
  final p = _sanitizePhone(phone);
  if (p.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد رقم هاتف')));
    return;
  }
  final uri = Uri(scheme: 'tel', path: p);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح الاتصال')));
  }
}

Future<void> launchWhatsApp(BuildContext context, String? phone, {String? message}) async {
  final p = _sanitizePhone(phone);
  if (p.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد رقم واتساب')));
    return;
  }
  final text = Uri.encodeComponent(message ?? 'مرحباً 👋');
  // whatsapp:// يعمل على أندرويد، wa.me يعمل كـ fallback
  final uriNative = Uri.parse('whatsapp://send?phone=$p&text=$text');
  final uriWeb = Uri.parse('https://wa.me/$p?text=$text');

  if (await canLaunchUrl(uriNative)) {
    await launchUrl(uriNative);
  } else if (await canLaunchUrl(uriWeb)) {
    await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح واتساب')));
  }
}