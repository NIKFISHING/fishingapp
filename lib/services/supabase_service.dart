import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

/// Обёртка над Supabase-клиентом: инициализация SDK и методы
/// авторизации по номеру телефона (SMS-код).
///
/// Остальные фичи (регионы/чат/каталог) обращаются к базе данных
/// через `SupabaseService.client`, когда переходят с тестовых данных
/// на реальные запросы.
class SupabaseService {
  SupabaseService._();

  /// Вызывается один раз в main() до runApp().
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static Session? get currentSession => auth.currentSession;

  static User? get currentUser => auth.currentUser;

  /// false, если сессии нет или Supabase ещё не инициализирован
  /// (например, экран построен раньше main() — в тестах).
  static bool get isAuthenticated {
    try {
      return currentSession != null;
    } catch (_) {
      return false;
    }
  }

  /// Шаг 1 авторизации: отправляет SMS с кодом на указанный номер.
  /// Номер должен быть в формате E.164, например +79001234567.
  static Future<void> sendOtp(String phone) {
    return auth.signInWithOtp(phone: phone);
  }

  /// Шаг 2 авторизации: проверяет код из SMS и создаёт сессию.
  static Future<AuthResponse> verifyOtp({
    required String phone,
    required String otpCode,
  }) {
    return auth.verifyOTP(
      type: OtpType.sms,
      phone: phone,
      token: otpCode,
    );
  }

  static Future<void> signOut() {
    return auth.signOut();
  }

  /// Создаёт (или обновляет) строку профиля текущего пользователя в
  /// таблице `users`. Вызывается сразу после успешного verifyOtp: без неё
  /// отправка сообщений/товаров упадёт на внешнем ключе, ссылающемся на
  /// `users(id)`.
  static Future<void> upsertCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return;
    await client.from(SupabaseTables.users).upsert({
      'id': user.id,
      'phone': user.phone ?? '',
    });
  }
}
