<#
Пересобирает web-версию приложения и синхронизирует её в docs/ (откуда
GitHub Pages раздаёт живую PWA-демку), передавая ОБА обязательных флага
за один раз:

  --base-href                        - без него ломаются все относительные
                                        пути ассетов: сайт отдаётся из
                                        /fishingapp/, а не с корня домена
  --dart-define SUPABASE_URL/ANON_KEY - без них приложение тихо откатывается
                                        на плейсхолдер и ломается вход по SMS

(Оба флага уже дважды забывали передать по отдельности при ручной
пересборке — этот скрипт существует, чтобы больше так не терять один из них.)

Использование:
  powershell -File scripts/deploy_web.ps1

После скрипта: docs/ обновлён локально. Проверьте `git status`/`git diff`
и закоммитьте + запушьте вручную, чтобы обновить живой сайт.

SUPABASE_ANON_KEY ниже — публичный ("publishable") ключ, специально
предназначенный для встраивания в клиентский код; он и так уже виден
любому в скомпилированном docs/main.dart.js. Секретом не является.
При необходимости все три значения можно переопределить переменными
окружения BASE_HREF / SUPABASE_URL / SUPABASE_ANON_KEY.
#>

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

$BaseHref = if ($env:BASE_HREF) { $env:BASE_HREF } else { "/fishingapp/" }
$SupabaseUrl = if ($env:SUPABASE_URL) { $env:SUPABASE_URL } else { "https://kvwnmxerwenxippfxzhl.supabase.co" }
$SupabaseAnonKey = if ($env:SUPABASE_ANON_KEY) { $env:SUPABASE_ANON_KEY } else { "sb_publishable_CV9BsOIVrFioqp6vkyJEOw_b3AYEClA" }

Write-Host "flutter build web --base-href $BaseHref --dart-define=SUPABASE_URL=$SupabaseUrl --dart-define=SUPABASE_ANON_KEY=***"

flutter build web `
  --base-href $BaseHref `
  --dart-define=SUPABASE_URL=$SupabaseUrl `
  --dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey

Copy-Item -Path "build\web\*" -Destination "docs" -Recurse -Force

Write-Host ""
Write-Host "Готово: build/web синхронизирован в docs/."
Write-Host "Проверьте 'git status' / 'git diff docs' и закоммитьте + запушьте вручную."
