# インクルード

インクルードプラグインを使うことで, Slim テンプレートに他の Slim ファイルを読み込むことができます。.slim 拡張子はファイル名に自動的に付加されます。
読み込まれたファイルが Slim でない場合は `#{文字列展開}` を含んだテキストファイルとして扱われます。

例:

    include partial.slim
    include partial
    include partial.txt

インクルードプラグインを有効化

    require 'slim/include'

# オプション

| タイプ | 名前 | デフォルト値 | 目的 |
| ------ | ---- | ------------ | ---- |
| Array | :include_dirs | [Dir.pwd, '.'] | ファイルを検索するディレクトリ |
