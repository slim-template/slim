# 翻訳/I18n

翻訳プラグインは Gettext, Fast-Gettext または Rails I18n を使ったテンプレートの自動翻訳機能を提供します。
テンプレート内の静的テキストを翻訳版に変換します。

例:

    h1 Welcome to #{url}!

Gettext は文字列を英語からドイツ語に変換し, 文字列が展開される部分は %1, %2, ... の順に変換されます。

    "Welcome to %1!" -> "Willkommen auf %1!"

次のようにレンダリングされます。

    <h1>Willkommen auf slim-lang.com!</h1>

翻訳プラグインを有効化します。

    require 'slim/translator'

# オプション

| 種類 | 名前 | デフォルト | 用途 |
| ---- | ---- | ---------- | ---- |
| 真偽値   | :tr      | true     | 翻訳の有効化 ('slim/translator' の required が必要) |
| シンボル | :tr_mode | :dynamic | 翻訳を :static = コンパイル時に実施, :dynamic = ランタイムで実施 |
| 文字列   | :tr_fn   | インストールされた翻訳ライブラリに依存 | 翻訳用ヘルパ, gettext の場合 '_' |
