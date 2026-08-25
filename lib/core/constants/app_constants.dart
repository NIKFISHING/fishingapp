/// Конфигурация Supabase-проекта.
///
/// Значения передаются через --dart-define при сборке/запуске, например:
/// flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///             --dart-define=SUPABASE_ANON_KEY=xxxx
///
/// Так реальные ключи не попадают в git. На этапе разработки можно
/// временно подставить значения по умолчанию ниже.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}

/// Названия таблиц в базе данных Supabase — используются сервисами,
/// чтобы не разбрасывать строковые литералы по коду.
class SupabaseTables {
  SupabaseTables._();

  static const String users = 'users';
  static const String regions = 'regions';
  static const String messages = 'messages';
  static const String products = 'products';
}

/// Общие текстовые константы приложения.
class AppStrings {
  AppStrings._();

  static const String appName = 'Рыбаки';
}
