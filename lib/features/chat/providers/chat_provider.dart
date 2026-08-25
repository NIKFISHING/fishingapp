import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/message_model.dart';
import '../../../services/supabase_service.dart';

/// Хранит сообщения чата конкретного региона: подгружает историю из
/// таблицы `messages` и подписывается на Supabase Realtime, чтобы новые
/// сообщения появлялись у всех участников без перезагрузки экрана.
///
/// Dev-режим входа (`devTestUserProvider`) не создаёт настоящую сессию
/// Supabase, поэтому у него нет `auth.uid()` — писать в реальную таблицу
/// `messages` для него нельзя (это отклонят и RLS, и внешний ключ на
/// users). Чтение истории и realtime продолжают работать (SELECT открыт
/// всем), а собственные сообщения dev-пользователя добавляются только
/// локально, в состояние этого контроллера.
class ChatController extends StateNotifier<AsyncValue<List<MessageModel>>> {
  ChatController(this.regionId) : super(const AsyncLoading()) {
    _init();
  }

  final String regionId;
  RealtimeChannel? _channel;

  Future<void> _init() async {
    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.messages)
          .select()
          .eq('region_id', regionId)
          .order('created_at');
      state = AsyncData(rows.map(MessageModel.fromJson).toList());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
    _subscribeToRealtime();
  }

  void _subscribeToRealtime() {
    _channel = SupabaseService.client
        .channel('messages-region-$regionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseTables.messages,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'region_id',
            value: regionId,
          ),
          callback: (payload) {
            final message = MessageModel.fromJson(payload.newRecord);
            final current = state.valueOrNull ?? [];
            if (current.any((m) => m.id == message.id)) return;
            state = AsyncData([...current, message]);
          },
        )
        .subscribe();
  }

  /// Отправка текстового сообщения. У авторизованного пользователя —
  /// настоящая запись в Supabase (само сообщение вернётся через realtime
  /// выше). У dev-пользователя — только локальное добавление в состояние.
  Future<void> sendText(
    String text, {
    required String authorId,
    required String authorName,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (SupabaseService.isAuthenticated) {
      await SupabaseService.client.from(SupabaseTables.messages).insert({
        'region_id': regionId,
        'author_id': authorId,
        'text': trimmed,
      });
      return;
    }

    _appendLocal(
      MessageModel(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        regionId: regionId,
        authorId: authorId,
        authorName: authorName,
        createdAt: DateTime.now(),
        text: trimmed,
      ),
    );
  }

  /// Фото пока отправляется только локально: загрузка в Supabase Storage —
  /// отдельный следующий шаг, здесь хранится лишь путь к файлу на устройстве.
  void sendPhoto(
    String photoPath, {
    required String authorId,
    required String authorName,
  }) {
    _appendLocal(
      MessageModel(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        regionId: regionId,
        authorId: authorId,
        authorName: authorName,
        createdAt: DateTime.now(),
        photoUrl: photoPath,
      ),
    );
  }

  void _appendLocal(MessageModel message) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, message]);
  }

  @override
  void dispose() {
    final channel = _channel;
    if (channel != null) {
      SupabaseService.client.removeChannel(channel);
    }
    super.dispose();
  }
}

final chatControllerProvider = StateNotifierProvider.family<ChatController,
    AsyncValue<List<MessageModel>>, String>((ref, regionId) {
  return ChatController(regionId);
});
