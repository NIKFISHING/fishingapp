-- ============================================================
-- Supabase Storage: бакет для аватаров профиля.
-- Выполнить в SQL Editor проекта Supabase (как schema.sql/seed.sql).
-- ============================================================

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Аватары читает кто угодно (публичный URL показывается в профиле и чате).
create policy "Аватары доступны всем на чтение" on storage.objects
  for select using (bucket_id = 'avatars');

-- Пользователь загружает/меняет/удаляет только файлы в своей папке —
-- приложение сохраняет аватар по пути "<user_id>/avatar".
create policy "Пользователь загружает только свой аватар" on storage.objects
  for insert with check (
    bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Пользователь обновляет только свой аватар" on storage.objects
  for update using (
    bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Пользователь удаляет только свой аватар" on storage.objects
  for delete using (
    bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
  );
