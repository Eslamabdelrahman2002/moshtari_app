import 'package:flutter/material.dart';

class MenuScreenArgs {
  final bool isAuthenticated;
  final VoidCallback onLogout;
  final VoidCallback onProfileTap;
  final VoidCallback onLoginTap;

  MenuScreenArgs({
    required this.isAuthenticated,
    required this.onLogout,
    required this.onProfileTap,
    required this.onLoginTap,
  });
}