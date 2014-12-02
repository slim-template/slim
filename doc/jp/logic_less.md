# ロジックレスモード

ロジックレスモードは [Mustache](https://github.com/defunkt/mustache) にインスパイアされています。ロジックレスモードは
例えば動的コンテンツを含む再帰的ハッシュツリーのような辞書オブジェクトを使います。

## 条件付き

オブジェクトが false または empty? ではない場合, コンテンツが表示されます。

    - article
      h1 = title

## 反転条件付き

オブジェクトが false または empty? の場合, コンテンツが表示されます。

    -! article
      p Sorry, article not found

## 繰り返し

オブジェクトが配列の場合, この部分は繰り返されます。

    - articles
      tr: td = title

## ラムダ式

Mustache のように, Slim はラムダ式をサポートします。

    = person
      = name

ラムダ式は次のように定義できます:

    def lambda_method
      "<div class='person'>#{yield(name: 'Andrew')}</div>"
    end

任意に 1 つ以上のハッシュを `yield` に渡すことができます。複数のハッシュを渡した場合, 先述したようにブロックが繰り返されます。

## 辞書アクセス

サンプルコード:

    - article
      h1 = title

辞書オブジェクトは `:dictionary_access` オプションによって設定された順序でアクセスされます。デフォルトの順序:

1. `シンボル` - `article.respond_to?(:has_key?)` 且つ `article.has_key?(:title)` の場合, Slim は `article[:title]` を実行します。
2. `文字列` - `article.respond_to?(:has_key?)` 且つ `article.has_key?('title')` の場合, Slim は `article['title']` を実行します。
3. `メソッド` - `article.respond_to?(:title)` の場合, Slim は `article.send(:title)` を実行します。
4. `インスタンス変数` - `article.instance_variable_defined?(@title)` の場合, Slim は `article.instance_variable_get @title` を実行します。

すべて失敗した場合, Slim は親オブジェクトに対して同じ順序で title の参照を解決しようとします。この例では, 親オブジェクトはレンダリングしているテンプレートに対する辞書オブジェクトになります。

ご想像のとおり, article への参照は辞書オブジェクトに対して同じ手順で行われます。インスタンス変数はビューのコードでは利用を許されていませんが, Slim はそれを見つけて使います。基本的には, テンプレートの中で @ プレフィックスを落として使っています。パラメータ付きメソッドの呼び出しは許可されません。


## 文字列

`self` キーワードは検討中の要素を `.to_s` した値を返します。

辞書オブジェクトを与え,

    {
      article: [
        'Article 1',
        'Article 2'
      ]
    }

ビューで次のように

    - article
      tr: td = self

これは次のようになります。

    <tr>
      <td>Article 1</td>
    </>
    <tr>
      <td>Article 2</td>
    </tr>


## Rails でロジックレスモード

インストール:

    $ gem install slim

require で指定:

    gem 'slim', require: 'slim/logic_less'

特定のアクションでのみロジックレスモードを有効化したい場合, まず設定でロジックレスモードを global に無効化します。

    Slim::Engine.set_options logic_less: false

さらに, アクションの中でレンダリングする度にロジックレスモードを有効化します。

    class Controller
      def action
        Slim::Engine.with_options(logic_less: true) do
          render
        end
      end
    end

## Sinatra でロジックレスモード

Sinatra には Slim のビルトインサポートがあります。しなければならないのはロジックレス Slim プラグインを require することです。config.ru で require できます:

    require 'slim/logic_less'

これで準備は整いました!

特定のアクションでのみロジックレスモードを有効化したい場合, まず設定でロジックレスモードを global に無効化します。

    Slim::Engine.set_options logic_less: false

さらに, アクションの中でレンダリングする度にロジックレスモードを有効化します。

    get '/page'
      slim :page, logic_less: true
    end

## オプション

| 種類 | 名前 | デフォルト | 用途 |
| ---- | ---- | ------- | ------- |
| 真偽値 | :logic_less | true | ロジックレスモードを有効化 ('slim/logic_less' の required が必要) |
| 文字列 | :dictionary | "self" | 変数が検索される辞書への参照 |
| シンボル/配列&lt;シンボル&gt; | :dictionary_access | [:symbol, :string, :method, :instance_variable] | 辞書のアクセス順序 (:symbol, :string, :method, :instance_variable) |
