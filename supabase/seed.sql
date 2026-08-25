-- ============================================================
-- Seed-скрипт для локальной разработки/тестирования.
-- Выполнить в SQL Editor проекта Supabase ПОСЛЕ supabase/schema.sql.
-- Безопасно выполнять повторно — вставки идут через "where not exists"
-- (дублей не будет), обновления фото товаров идут через update по title.
-- ============================================================

-- На случай, если schema.sql уже выполнялся раньше в старой версии,
-- где seller_id был обязательным полем — снимаем ограничение, иначе
-- тестовые товары без владельца не вставятся.
alter table products alter column seller_id drop not null;

-- Регионы -------------------------------------------------------
insert into regions (name, description)
select 'Москва', 'Московская область и ближайшие водоёмы'
where not exists (select 1 from regions where name = 'Москва');

insert into regions (name, description)
select 'Санкт-Петербург', 'Финский залив, Ладога и Нева'
where not exists (select 1 from regions where name = 'Санкт-Петербург');

-- Товары каталога -------------------------------------------------
-- Фото — свободные (Wikimedia Commons, CC/public domain), проверены
-- вручную на тематическое соответствие товару.
--
-- Обновляем image_url у уже существующих строк (на случай, если seed.sql
-- уже запускался раньше со старыми, нетематичными фото) — только вставки
-- через "where not exists" этого не сделают.
update products set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/A_spinning_reel_on_a_rod.jpg/500px-A_spinning_reel_on_a_rod.jpg'
  where title = 'Спиннинг Shimano Catana';

update products set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Abu_reel.jpg/500px-Abu_reel.jpg'
  where title = 'Катушка Daiwa Legalis';

update products set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Angeln_zubehoer_wobbler_01.jpg/500px-Angeln_zubehoer_wobbler_01.jpg'
  where title = 'Набор воблеров (5 шт.)';

update products set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Fishfinder_display_showing_the_mark_at_Flash_Pinnacle_P7280213.jpg/500px-Fishfinder_display_showing_the_mark_at_Flash_Pinnacle_P7280213.jpg'
  where title = 'Эхолот Lucky FF718';

update products set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Zan%C4%99ta_na_ryby_%28Murowana_Goslina%29%2C_groundbait.jpg/500px-Zan%C4%99ta_na_ryby_%28Murowana_Goslina%29%2C_groundbait.jpg'
  where title = 'Прикормка Sensas 3000';

insert into products (title, description, price, image_url)
select 'Спиннинг Shimano Catana', 'Длина 2.1м, тест 5-21г', 3490,
  'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/A_spinning_reel_on_a_rod.jpg/500px-A_spinning_reel_on_a_rod.jpg'
where not exists (select 1 from products where title = 'Спиннинг Shimano Catana');

insert into products (title, description, price, image_url)
select 'Катушка Daiwa Legalis', 'Безынерционная, 2500 размер', 5200,
  'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Abu_reel.jpg/500px-Abu_reel.jpg'
where not exists (select 1 from products where title = 'Катушка Daiwa Legalis');

insert into products (title, description, price, image_url)
select 'Набор воблеров (5 шт.)', 'Для ловли щуки и окуня', 1750,
  'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Angeln_zubehoer_wobbler_01.jpg/500px-Angeln_zubehoer_wobbler_01.jpg'
where not exists (select 1 from products where title = 'Набор воблеров (5 шт.)');

insert into products (title, description, price, image_url)
select 'Эхолот Lucky FF718', 'Беспроводной, портативный', 4990,
  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Fishfinder_display_showing_the_mark_at_Flash_Pinnacle_P7280213.jpg/500px-Fishfinder_display_showing_the_mark_at_Flash_Pinnacle_P7280213.jpg'
where not exists (select 1 from products where title = 'Эхолот Lucky FF718');

insert into products (title, description, price, image_url)
select 'Прикормка Sensas 3000', 'Универсальная, 1 кг', 690,
  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Zan%C4%99ta_na_ryby_%28Murowana_Goslina%29%2C_groundbait.jpg/500px-Zan%C4%99ta_na_ryby_%28Murowana_Goslina%29%2C_groundbait.jpg'
where not exists (select 1 from products where title = 'Прикормка Sensas 3000');
