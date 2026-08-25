import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_service.dart';
import '../../auth/providers/dev_auth_provider.dart';

/// Номер телефона текущего пользователя: реальная сессия Supabase,
/// либо тестовый пользователь из dev-режима, либо заглушка.
final currentUserPhoneProvider = Provider<String>((ref) {
  final realPhone = SupabaseService.currentUser?.phone;
  if (realPhone != null) return realPhone;

  final isDevTestUser = ref.watch(devTestUserProvider);
  return isDevTestUser ? DevTestUser.phone : '+7 900 123-45-67';
});
