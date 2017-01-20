# Slim

[![Gem Version](https://img.shields.io/gem/v/slim.svg)](http://rubygems.org/gems/slim) [![Build Status](https://img.shields.io/travis/slim-template/slim.svg?branch=master)](http://travis-ci.org/slim-template/slim) [![Dependency Status](https://img.shields.io/gemnasium/slim-template/slim.svg?travis)](https://gemnasium.com/slim-template/slim) [![Code Climate](https://codeclimate.com/github/slim-template/slim/badges/gpa.svg)](https://codeclimate.com/github/slim-template/slim) [![Test Coverage](https://codeclimate.com/github/slim-template/slim/badges/coverage.svg)](https://codeclimate.com/github/slim-template/slim/coverage) [![Gittip donate button](https://img.shields.io/gratipay/bevry.svg)](https://www.gittip.com/min4d/ "Donate weekly to this project using Gittip")
[![Flattr donate button](https://raw.github.com/balupton/flattr-buttons/master/badge-89x18.gif)](https://flattr.com/submit/auto?user_id=min4d&url=http%3A%2F%2Fslim-lang.org%2F "Donate monthly to this project using Flattr")

Slim は 不可解にならないように view の構文を本質的な部品まで減らすことを目指したテンプレート言語です。標準的な HTML テンプレートからどれだけのものが削除できるか確かめるところから始まりました。(<, >, 閉じタグなど) 多くの人が Slim に興味を持ったことで, 機能性は発展し, 柔軟な構文をもたらしました。

機能の短いリスト

* すっきりした構文
    * 閉じタグの無い短い構文 (代わりにインデントを用いる)
    * 閉じタグを用いた HTML 形式の構文
    * 設定可能なショートカットタグ (デフォルトでは `#` は `<div id="...">` に, `.` は `<div class="...">` に)
* 安全性
    * デフォルトで自動 HTML エスケープ
    * Rails の `html_safe?` に対応
* 柔軟な設定
* プラグインを用いた拡張性:
    * Mustache と同様のロジックレスモード
    * インクルード
    * 多言語化/I18n
* 高性能
    * ERB/Erubis に匹敵するスピード
    * Rails のストリーミングに対応
* 全てのメジャーフレームワークが対応 (Rails, Sinatra, ...)
* タグや属性の Unicode に完全対応
* Markdown や Textile のような埋め込みエンジン

## リンク

* ホームページ: <http://slim-lang.com>
* ソース: <http://github.com/slim-template/slim>
* バグ:   <http://github.com/slim-template/slim/issues>
* リスト:   <http://groups.google.com/group/slim-template>
* API ドキュメント:
    * 最新の Gem: <http://rubydoc.info/gems/slim/frames> <https://www.omniref.com/ruby/gems/slim>
    * GitHub master: <http://rubydoc.info/github/slim-template/slim/master/frames> <https://www.omniref.com/github/slim-template/slim>

## イントロダクション

### Slim とは?

Slim は __Rails3 および 4__ に対応した高速, 軽量なテンプレートエンジンです。すべての主要な Ruby の実装でしっかりテストされています。
私たちは継続的インテグレーションを採用しています。(travis-ci)

Slim の核となる構文は1つの考えによって導かれます: "この動作を行うために最低限必要なものは何か"。

多くの人々の Slim への貢献によって, 彼らが使う [Haml](https://github.com/haml/haml) や [Pug](https://github.com/pugjs/pug) (以前は [Jade](https://github.com/visionmedia/jade)) の影響を受け構文の追加が行われています。 Slim の開発チームは美は見る人の目の中にあることを分っているのでこういった追加にオープンです。

Slim は 構文解析/コンパイルに [Temple](https://github.com/judofyr/temple) を使い [Tilt](https://github.com/rtomayko/tilt) に組み込まれます。これにより [Sinatra](https://github.com/sinatra/sinatra) やプレーンな [Rack](https://github.com/rack/rack) とも一緒に使えます。

Temple のアーキテクチャはとても柔軟でモンキーパッチなしで構文解析とコンパイルのプロセスの拡張を可能にします。これはロジックレスのプラグインや I18n が提供する翻訳プラグインに
使用されます。ロジックレスモードでは HTML をビルドするために Slim の構文を使いたいが, テンプレートの中で Ruby を書きたくない場合にも Slim を使うことができます。

### なぜ Slim を使うのか?

* Slim によって メンテナンスが容易な限りなく最小限のテンプレートを作成でき, 正しい文法の HTML や XML が書けることを保証します。
* Slim の構文は美的であり, テンプレートを書くのを楽しくしてくれると思います。Slim は主要なフレームワークで互換性があるので簡単に始めることができます。
* Slim のアーキテクチャは非常に柔軟なので構文の拡張やプラグインを書くことができます。

___そう, Slim は速い!___ Slim は開発当初からパフォーマンスに注意して開発されました。
ベンチマークはコミット毎に <http://travis-ci.org/slim-template/slim> で取られています。
この数字が信じられませんか? それは仕方ないことです。是非 rake タスクを使って自分でベンチマークを取ってみてください!

私たちの考えでは, あなたは Slim の機能と構文を使うべきです。Slim はあなたのアプリケーションのパフォーマンスに悪影響を与えないことを保証します。

### どう始めるの?

Slim を gem としてインストール:

~~~
gem install slim
~~~

あなたの Gemfile に `gem 'slim'` と書いてインクルードするか, ファイルに `require 'slim'` と書く必要があります。これだけです! 後は拡張子に .slim を使うだけで準備はできています。

### 構文例

Slim テンプレートがどのようなものか簡単な例を示します:

~~~ slim
doctype html
html
  head
    title Slim のファイル例
    meta name="keywords" content="template language"
    meta name="author" content=author
    link rel="icon" type="image/png" href=file_path("favicon.png")
    javascript:
      alert('Slim は javascript の埋め込みに対応します!')

  body
    h1 マークアップ例

    #content
      p このマークアップ例は Slim の典型的なファイルがどのようなものか示します。

    == yield

    - if items.any?
      table#items
        - for item in items
          tr
            td.name = item.name
            td.price = item.price
    - else
      p アイテムが見つかりませんでした。いくつか目録を追加してください。
        ありがとう!

    div id="footer"
      == render 'footer'
      | Copyright &copy; #{@year} #{@author}
~~~

インデントについて, インデントの深さはあなたの好みで選択できます。もし最初のインデントをスペース2つ, その次に5スペースを使いたい場合, それはあなたの選択次第です。マークアップを入れ子にするにはスペース1つのインデントが必要なだけです。

## ラインインジケータ

### テキスト `|`

パイプは Slim に行をコピーしろと命じます。基本的にどのような処理でもエスケープします。
パイプよりも深くインデントされた各行がコピーされます。

~~~ slim
body
  p
    |
      これはテキストブロックのテストです。
~~~

  構文解析結果は以下:

~~~ html
<body><p>これはテキストブロックのテストです。</p></body>
~~~

  ブロックの左端はパイプ +1 スペースのインデントに設定されています。
  追加のスペースはコピーされます。

~~~ slim
body
  p
    | この行は左端になります。
       この行はスペース 1 つを持つことになります。
         この行はスペース 2 つを持つことになります。
           以下同様に...
~~~

テキスト行に HTML を埋め込むこともできます。

~~~ slim
- articles.each do |a|
  | <tr><td>#{a.name}</td><td>#{a.description}</td></tr>
~~~

### テキスト行のスペースをたどる `'`

シングルクォートは Slim に行をコピーしろと命じます (`|` と同様に) が,  単一行の末尾にスペースが追加されているかチェックします。

### インライン html `<` (HTML 形式)

あなたは html タグを直接 Slim の中に書くことができます。Slim は閉じタグを使った html タグ形式や html と Slim を混ぜてテンプレートの中に書くことができます。
行頭が '<' の場合, 暗黙の `|` があるものとして動作します:

~~~ slim
<html>
  head
    title Example
  <body>
    - if articles.empty?
    - else
      table
        - articles.each do |a|
          <tr><td>#{a.name}</td><td>#{a.description}</td></tr>
  </body>
</html>
~~~

### 制御コード `-`

ダッシュは制御コードを意味します。制御コードの例としてループと条件文があります。`end` は `-` の後ろに置くことができません。ブロックはインデントによってのみ定義されます。
複数行にわたる Ruby のコードが必要な場合, 行末にバックスラッシュ `\` を追加します。行末がカンマ `,` で終わる場合 (例 関数呼び出し) には行末にバックスラッシュを追加する必要はありません。

~~~ slim
body
  - if articles.empty?
    | 在庫なし
~~~

### 出力 `=`

イコールはバッファに追加する出力を生成する Ruby 呼び出しを Slim に命令します。Ruby のコードが複数行にわたる場合, 例のように行末にバックスラッシュを追加します。

~~~ slim
= javascript_include_tag \
   "jquery",
   "application"
~~~

行末がカンマ `,` で終わる場合 (例 関数呼び出し) には行末にバックスラッシュを追加する必要はありません。行末スペースを追加するために修飾子の `>` や `<` もサポートします。

* `=>` は末尾のスペースを伴った出力をします。 末尾のスペースが追加されることを除いて, 単一の等合 (`=`) と同じです。
* `=<` は先頭のスペースを伴った出力をします。先頭のスペースが追加されることを除いて, 単一の等号 (`=`) と同じです。

### HTML エスケープを伴わない出力 `==`

単一のイコール (`=`) と同じですが, `escape_html` メソッドを経由しません。 末尾や先頭のスペースを追加するための修飾子 `>` と `<` はサポートされています。

* `==>` は HTML エスケープを行わず末尾のスペースを伴った出力をします。末尾のスペースが追加されることを除いて, 二重等号 (`==`) と同じです。
* `==<` は HTML エスケープを行わず先頭のスペースを伴った出力をします。先頭のスペースが追加されることを除いて, 二重等号 (`==`) と同じです。

### コードコメント `/`

コードコメントにはスラッシュを使います。スラッシュ以降は最終的なレンダリング結果に表示されません。コードコメントには `/` を, html コメントには `/!` を使います。

~~~ slim
body
  p
    / この行は表示されません。
      この行も表示されません。
    /! html コメントとして表示されます。
~~~

  構文解析結果は以下:

~~~ html
<body><p><!--html コメントとして表示されます。--></p></body>
~~~

### HTML コメント `/!`

html コメントにはスラッシュの直後にエクスクラメーションマークを使います (`<!-- ... -->`)。

### IE コンディショナルコメント `/[...]`

~~~ slim
/[if IE]
    p もっといいブラウザを使ってください。
~~~

レンダリング結果:

~~~ html
<!--[if IE]><p>もっといいブラウザを使ってください。</p><![endif]-->
~~~

## HTML タグ

# <!DOCTYPE> 宣言

doctype はとても簡単な方法で複雑なドキュメントタイプを生成するために使われる特別なキーワードです。

XML 宣言

~~~ slim
doctype xml
  <?xml version="1.0" encoding="utf-8" ?>

doctype xml ISO-8859-1
  <?xml version="1.0" encoding="iso-8859-1" ?>
~~~

XHTML ドキュメントタイプ

~~~ slim
doctype html
  <!DOCTYPE html>

doctype 5
  <!DOCTYPE html>

doctype 1.1
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

doctype strict
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

doctype frameset
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">

doctype mobile
  <!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN"
    "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">

doctype basic
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN"
    "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">

doctype transitional
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
~~~

HTML 4 ドキュメントタイプ

~~~ slim
doctype strict
  <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
    "http://www.w3.org/TR/html4/strict.dtd">

doctype frameset
  <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"
    "http://www.w3.org/TR/html4/frameset.dtd">

doctype transitional
  <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
~~~

### 閉じタグ (末尾 `/`)

末尾に `/` を付けることで明示的にタグを閉じることができます。

~~~ slim
img src="image.png"/
~~~

(注) 標準的な html タグ (img, br, ...) は自動的にタグを閉じるので,
通常必要ありません。

### スペースを追加する (`<`, `>`)

a タグの後に > を追加することで末尾にスペースを追加するよう Slim に強制することができます。

~~~ slim
a> href='url1' リンク1
a> href='url2' リンク2
~~~

< を追加することで先頭のスペースを追加できます。

~~~ slim
a< href='url1' リンク1
a< href='url2' リンク2
~~~

これらを組み合わせて使うこともできます。

~~~ slim
a<> href='url1' リンク1
~~~

### インラインタグ

時々タグをよりコンパクトにインラインにしたくなるかもしれません。

~~~ slim
ul
  li.first: a href="/a" A リンク
  li: a href="/b" B リンク
~~~

読みやすくするために, 属性を囲むことができるのを忘れないでください。

~~~ slim
ul
  li.first: a[href="/a"] A リンク
  li: a[href="/b"] B リンク
~~~

### テキストコンテンツ

タグと同じ行で開始するか

~~~ slim
body
  h1 id="headline" 私のサイトへようこそ。
~~~

入れ子にするのかどちらかです。エスケープ処理を行うためにはパイプかバッククォートを使わなければなりません。


~~~ slim
body
  h1 id="headline"
    | 私のサイトへようこそ。
~~~

スマートテキストモードを有効化して利用する場合

~~~ slim
body
  h1 id="headline"
    私のサイトへようこそ。
~~~

### 動的コンテンツ (`=` と `==`)

同じ行で呼び出すか

~~~ slim
body
  h1 id="headline" = page_headline
~~~

入れ子にすることができます。

~~~ slim
body
  h1 id="headline"
    = page_headline
~~~

### 属性

タグの後に直接属性を書きます。属性のテキストにはダブルクォート `"` か シングルクォート `'` を使わなければなりません (引用符で囲まれた属性)。

~~~ slim
a href="http://slim-lang.com" title='Slim のホームページ' Slim のホームページへ
~~~

引用符で囲まれたテキストを属性として使えます。

#### 属性の囲み

区切り文字が構文を読みやすくするのであれば,
`{...}`, `(...)`, `[...]` が属性の囲みに使えます。
これらの記号は設定できます (`:attr_list_delims` オプション参照)。

~~~ slim
body
  h1(id="logo") = page_logo
  h2[id="tagline" class="small tagline"] = page_tagline
~~~

属性を囲んだ場合, 属性を複数行にわたって書くことができます:

~~~ slim
h2[id="tagline"
   class="small tagline"] = page_tagline
~~~

属性の囲みや変数まわりにスペースを使うことができます:

~~~ slim
h1 id = "logo" = page_logo
h2 [ id = "tagline" ] = page_tagline
~~~

#### 引用符で囲まれた属性

例:

~~~ slim
a href="http://slim-lang.com" title='Slim のホームページ' Slim のホームページへ
~~~

引用符で囲まれたテキストを属性として使えます:

~~~ slim
a href="http://#{url}" #{url} へ
~~~

属性値はデフォルトでエスケープされます。属性のエスケープを無効にしたい場合 == を使います。

~~~ slim
a href=="&amp;"
~~~

引用符で囲まれた属性をバックスラッシュ `\` で改行できます。

~~~ slim
a data-title="help" data-content="極めて長い長い長いヘルプテキストで\
  続けてその後はまたやり直して繰り返し...."
~~~

#### Ruby コードを用いた属性

`=` の後に直接 Ruby コードを書きます。コードにスペースが含まれる場合,
`(...)` の括弧でコードを囲まなければなりません。ハッシュを `{...}` に, 配列を `[...]` に書くこともできます。

~~~ slim
body
  table
    - for user in users
      td id="user_#{user.id}" class=user.role
        a href=user_action(user, :edit) Edit #{user.name}
        a href=(path_to_user user) = user.name
~~~

属性値はデフォルトでエスケープされます。属性のエスケープを無効にしたい場合 == を使います。

~~~ slim
a href==action_path(:start)
~~~

Ruby コードの属性は, コントロールセクションにあるようにバックスラッシュ `\` や `,` を用いて改行できます。

#### 真偽値属性

属性値の `true`, `false` や `nil` は真偽値として
評価されます。属性を括弧で囲む場合, 属性値の指定を省略することができます。

~~~ slim
input type="text" disabled="disabled"
input type="text" disabled=true
input(type="text" disabled)

input type="text"
input type="text" disabled=false
input type="text" disabled=nil
~~~

#### 属性の結合

複数の属性が与えられた場合に属性をまとめるように設定することができます (`:merge_attrs` 参照)。デフォルト設定では
 class 属性は空白区切りで結合されます。

~~~ slim
a.menu class="highlight" href="http://slim-lang.com/" Slim-lang.com
~~~

レンダリング結果:

~~~ html
<a class="menu highlight" href="http://slim-lang.com/">Slim-lang.com</a>
~~~

また, `Array` や配列要素を属性値として区切り文字で結合し使うこともできます。

~~~ slim
a class=["menu","highlight"]
a class=:menu,:highlight
~~~

#### アスタリスク属性 `*`

アスタリスクによってハッシュを属性/値のペアとして使うことができます。

~~~ slim
.card*{'data-url'=>place_path(place), 'data-id'=>place.id} = place.name
~~~

レンダリング結果:

~~~ html
<div class="card" data-id="1234" data-url="/place/1234">Slim の家</div>
~~~

次のようにハッシュを返すメソッドやインスタンス変数を使うこともできます"

~~~ slim
.card *method_which_returns_hash = place.name
.card *@hash_instance_variable = place.name
~~~

属性の結合 (Slim オプション `:merge_attrs` 参照) に対応するハッシュ属性には `Array` を与えることもできます。

~~~ slim
.first *{class: [:second, :third]} テキスト
~~~

レンダリング結果

~~~ slim
div class="first second third"
~~~

スプラット(アスタリスク)属性のプレフィックスは `splat_prefix` オプションで設定できます。デフォルト値は `'*'` です。

#### 動的タグ `*`

アスタリスク属性を使用することで完全に動的なタグを作ることができます。:tag をキーにもつハッシュを返すメソッドを
作るだけです。

~~~ slim
ruby:
  def a_unless_current
    @page_current ? {tag: 'span'} : {tag: 'a', href: 'http://slim-lang.com/'}
  end
- @page_current = true
*a_unless_current リンク
- @page_current = false
*a_unless_current リンク
~~~

レンダリング結果:

~~~ html
<span>リンク</span><a href="http://slim-lang.com/">リンク</a>
~~~

### ショートカット

#### タグショートカット

`:shortcut` オプションを設定することで独自のタグショートカットを定義できます。Rails アプリケーションでは, `config/initializers/slim.rb` のようにイニシャライザに定義します。Sinatra アプリでは, `require 'slim'` が書かれた下であればどこにでも設定を定義することができます。

~~~ ruby
Slim::Engine.set_options shortcut: {'c' => {tag: 'container'}, '#' => {attr: 'id'}, '.' => {attr: 'class'} }
~~~

Slim コードの中でこの様に使用できます。

~~~ slim
c.content テキスト
~~~

レンダリング結果

~~~ html
<container class="content">テキスト</container>
~~~

#### 属性のショートカット

カスタムショートカットを定義することができます (`#` が id で `.` が class であるように)。

例として `&` で作った type 属性付きの input 要素のショートカットを作成し追加します。

~~~ ruby
Slim::Engine.set_options shortcut: {'&' => {tag: 'input', attr: 'type'}, '#' => {attr: 'id'}, '.' => {attr: 'class'}}
~~~

Slim コードの中でこの様に使用できます。

~~~ slim
&text name="user"
&password name="pw"
&submit
~~~

レンダリング結果

~~~ html
<input type="text" name="user" />
<input type="password" name="pw" />
<input type="submit" />
~~~

別の例として `@` で作った role 属性のショートカットを作成し追加します。

~~~ ruby
Slim::Engine.set_options shortcut: {'@' => 'role', '#' => 'id', '.' => 'class'}
~~~

Slim コードの中でこの様に使用できます。

~~~ slim
.person@admin = person.name
~~~

レンダリング結果

~~~ html
<div class="person" role="admin">Daniel</div>
~~~

1つのショートカットを使って複数の属性を設定することもできます。

~~~ ruby
Slim::Engine.set_options shortcut: {'@' => {attr: %w(data-role role)}}
~~~

Slim の中で次のように使用し

~~~ slim
.person@admin = person.name
~~~

このようのレンダリングされます。

~~~ html
<div class="person" role="admin" data-role="admin">Daniel</div>
~~~

次のように追加の属性固定値を設定することもできます。

~~~ ruby
Slim::Engine.set_options shortcut: {'^' => {tag: 'script', attr: 'data-binding',
  additional_attrs: { type: "text/javascript" }}}
~~~

このように使用します。

~~~ slim
^products
  == @products.to_json
~~~

レンダリング結果です。

~~~ html
<script data-binding="products" type="text/javascript">
[{"name": "product1", "price": "$100"},
 {"name": "prodcut2", "price": "$200"}]
</script>
~~~

#### ID ショートカット `#` と class ショートカット `.`

`id` と `class` の属性を次のショートカットで指定できます。

~~~ slim
body
  h1#headline
    = page_headline
  h2#tagline.small.tagline
    = page_tagline
  .content
    = show_content
~~~

これは次に同じです

~~~ slim
body
  h1 id="headline"
    = page_headline
  h2 id="tagline" class="small tagline"
    = page_tagline
  div class="content"
    = show_content
~~~

## ヘルパ, キャプチャとインクルード

いくつかのヘルパを使用してテンプレートを拡張することもできます。次のヘルパが定義されていることを前提として,

~~~ruby
module Helpers
  def headline(&block)
    if defined?(::Rails)
      # Rails の場合には capture メソッドを使う
      "<h1>#{capture(&block)}</h1>"
    else
      # フレームワークなしで Slim を使う場合(Tilt の場合),
      # ただ出力する
      "<h1>#{yield}</h1>"
    end
  end
end
~~~

このインクルードされたコードのスコープは実行される Slim のテンプレートコードです。Slim テンプレートの中では次のように使用することができます。

~~~ slim
p
  = headline do
    ' Hello
    = user.name
~~~

`do` ブロック内のコンテンツが自動的にキャプチャされ `yield` を通してヘルパに渡されます。糖衣構文として
`do` キーワードを省略して書くこともできます。

~~~ slim
p
  = headline
    ' Hello
    = user.name
~~~

### ローカル変数のキャプチャ

次のように `Binding` を使ってローカル変数をキャプチャすることができます:

~~~ruby
module Helpers
  def capture_to_local(var, &block)
    set_var = block.binding.eval("lambda {|x| #{var} = x }")
    # Rails では capture! を使います
    # Slim をフレームワークなしで使う場合 (Tilt のみを使う場合),
    # キャプチャブロックを取得するには yield が利用できます
    set_var.call(defined?(::Rails) ? capture(&block) : yield)
  end
end
~~~

このヘルパは次のように使用できます

~~~ slim
/ captured_content 変数は Binding 前に定義されていなければいけません。
= capture_to_local captured_content=:captured_content
  p この段落は captured_content 変数にキャプチャされます
= captured_content
~~~

別の興味深いユースケースは, enumerableを使いそれぞれの要素をキャプチャすることです。ヘルパは, このようになります。

~~~ ruby
module Capture
  def capture(var, enumerable = nil, &block)
    value = enumerable ? enumerable.map(&block) : yield
    block.binding.eval("lambda {|x| #{var} = x }").call(value)
    nil
  end
end
~~~

そして, 次のように使用出来ます。

~~~ slim
- links = { 'http://slim-lang.com' => 'The Slim Template Language' }
= capture link_list=:link_list, links do |url, text|
  a href=url = text
~~~

その後は, `link_list`はキャプチャしたコンテンツを含みます。

###　インクルードヘルパ

コンパイル時にインクルード機能を使いたい場合には, [パーシャルのインクルード](doc/jp/include.md) を見てください。
実行時にサブテンプレートを実行すること ( Rails の `#render` のように) もできます。インクルードヘルパを自分で用意する必要があります:

~~~ ruby
module Helpers
  def include_slim(name, options = {}, &block)
    Slim::Template.new("#{name}.slim", options).render(self, &block)
  end
end
~~~

このヘルパは次のように使用できます

~~~ slim
nav = include_slim 'menu'
section = include_slim 'content'
~~~

しかし, このヘルパはキャッシュを行いません。その為, 目的にあったよりインテリジェントなバージョンを
実装する必要があります。また, ほとんどのフレームワークにはすでに同様のヘルパが含まれるので注意してください。(例: Rails の `render` メソッド)

## テキストの展開

Ruby の標準的な展開方法を使用します。テキストはデフォルトで html エスケープされます。

~~~ slim
body
  h1 ようこそ #{current_user.name} ショーへ。
  | エスケープしない #{{content}} こともできます。
~~~

展開したテキストのエスケープ方法 (言い換えればそのままのレンダリング)

~~~ slim
body
  h1 ようこそ \#{current_user.name} ショーへ。
~~~

## 埋め込みエンジン (Markdown, ...)

ありがとう [Tilt](https://github.com/rtomayko/tilt), Slim は他のテンプレートエンジンの埋め込みに見事に対応します。

例:

~~~ slim
    coffee:
      square = (x) -> x * x

    markdown:
      #Header
        #{"Markdown"} からこんにちわ!
        2行目!

p: markdown: Tag with **inline** markdown!
~~~

対応エンジン:

| フィルタ | 必要な gems | 種類 | 説明 |
| -------- | ----------- | ---- | ----------- |
| ruby: | なし | ショートカット | Ruby コードを埋め込むショートカット |
| javascript: | なし | ショートカット | JavaScript コードを埋め込むショートカットで script タグで囲む |
| css: | なし | ショートカット | css コードを埋め込むショートカットで style タグで囲む |
| sass: | sass | コンパイル時 | sass コードを埋め込むショートカットで style タグで囲む |
| scss: | sass | コンパイル時 | scss コードを埋め込むショートカットで style タグで囲む |
| less: | less | コンパイル時 | less コードを埋め込むショートカットで style タグで囲む |
| styl: | styl | コンパイル時 | stylus コードを埋め込むショートカットで style タグで囲む |
| coffee: | coffee-script | コンパイル時 | コンパイルした CoffeeScript で script タグで囲む |
| asciidoc: | asciidoctor | コンパイル時 + 展開 | AsciiDoc コードのコンパイルとテキスト中の # \{variables} の展開 |
| markdown: | redcarpet/rdiscount/kramdown | コンパイル時 + 展開 | Markdownのコンパイルとテキスト中の # \{variables} の展開 |
| textile: | redcloth | コンパイル時 + 展開 | textile のコンパイルとテキスト中の # \{variables} の展開 |
| creole: | creole | コンパイル時 + 展開 | cleole のコンパイルとテキスト中の # \{variables} の展開 |
| wiki:, mediawiki: | wikicloth | コンパイル時 + 展開 | wiki のコンパイルとテキスト中の # \{variables} の展開 |
| rdoc: | rdoc | コンパイル時 + 展開 | RDoc のコンパイルとテキスト中の # \{variables} の展開 |
| builder: | builder | プレコンパイル | builder コードの埋め込み |
| nokogiri: | nokogiri | プレコンパイル | nokogiri コードの埋め込み |
| erb: | なし | プレコンパイル | erb コードの埋め込み |

埋め込みエンジンは Slim の `Slim::Embedded` フィルタのオプションで直接設定されます。例:

~~~ ruby
Slim::Embedded.options[:markdown] = {auto_ids: false}
~~~

## Slim の設定

Slim とその基礎となる [Temple](https://github.com/judofyr/temple) は非常に柔軟に設定可能です。
Slim を設定する方法はコンパイル機構に少し依存します。(Rails や [Tilt](https://github.com/rtomayko/tilt))。デフォルトオプションの設定は `Slim::Engine` クラスでいつでも可能です。Rails の 環境設定ファイルで設定可能です。例えば, config/environments/developers.rb で設定したいとします:

### デフォルトオプション

~~~ ruby
# デバック用に html をきれいにインデントし属性をソートしない
Slim::Engine.set_options pretty: true, sort_attrs: false
~~~

ハッシュで直接オプションにアクセスすることもできます:

~~~ ruby
Slim::Engine.options[:pretty] = true
~~~

### 実行時のオプション設定

実行時のオプション設定の方法は2つあります。Tilt テンプレート (`Slim::Template`) の場合, テンプレートを
インスタンス化する時にオプションを設定できます。

~~~ ruby
Slim::Template.new('template.slim', optional_option_hash).render(scope)
~~~

他の方法は Rails に主に関係がありますがスレッド毎にオプション設定を行う方法です:

~~~ slim
Slim::Engine.with_options(option_hash) do
   # ここで作成される Slim エンジンは option_hash を使用します
   # Rails での使用例:
   render :page, layout: true
end
~~~

Rails ではコンパイルされたテンプレートエンジンのコードとオプションはテンプレート毎にキャッシュされ, 後でオプションを変更できないことに注意する必要があります。

~~~ slim
# 最初のレンダリング呼び出し
Slim::Engine.with_options(pretty: true) do
   render :page, layout: true
end

# 2回目のレンダリング呼び出し
Slim::Engine.with_options(pretty: false) do
   render :page, layout: true # :pretty is still true because it is cached
end
~~~

### 可能なオプション

次のオプションが `Slim::Engine` によって用意され `Slim::Engine.set_options` で設定することができます。
沢山ありますが良いことに, Slim はもし誤った設定キーを使用しようとした場合キーをチェックしエラーを報告します。


| 種類 | 名前 | デフォルト | 用途 |
| ---- | ---- | ---------- | ---- |
| 文字列 | :file | nil | 解析対象のファイル名ですが,  Slim::Template によって自動的に設定されます |
| 数値 | :tabsize | 4 | 1 タブあたりのスペース数 (構文解析で利用されます) |
| 文字列 | :encoding | "utf-8" | テンプレートのエンコーディングを設定 |
| 文字列 | :default_tag | "div" | タグ名が省略されている場合デフォルトのタグとして使用される |
| ハッシュ | :shortcut | \{'.' => {attr: 'class'}, '#' => {attr: 'id'}} | 属性のショートカット |
| ハッシュ | :code_attr_delims | \{'(' => ')', '[' => ']', '{' => '}'} | Ruby コードの属性区切り文字 |
| ハッシュ | :attr_list_delims | \{'(' => ')', '[' => ']', '{' => '}'} | 属性リスト区切り文字 |
| 配列&lt;シンボル,文字列&gt; | :enable_engines | nil <i>(すべて可)</i> | 有効な埋め込みエンジンリスト (ホワイトリスト) |
| 配列&lt;シンボル,文字列&gt; | :disable_engines | nil <i>(無効なし)</i> | 無効な埋め込みエンジンリスト (ブラックリスト) |
| 真偽値 | :disable_capture | false (Rails では true) | ブロック内キャプチャ無効 (ブロックはデフォルトのバッファに書き込む)  |
| 真偽値 | :disable_escape | false | 文字列の自動エスケープ無効 |
| 真偽値 | :use_html_safe | false (Rails では true) | ActiveSupport の String# html_safe? を使う (:disable_escape と一緒に機能する) |
| シンボル | :format | :xhtml | html の出力フォーマット (対応フォーマット :html, :xhtml, :xml) |
| 文字列 | :attr_quote |  '"'  | html の属性を囲む文字 (' または " が可能) |
| ハッシュ | :merge_attrs | \{'class' => ' '} | 複数の html 属性が与えられた場合結合に使われる文字列 (例: class="class1 class2") |
| 配列&lt;文字列&gt; | :hyphen_attrs | %w(data) | 属性にハッシュが与えられた場合ハイフンつなぎされます。(例: data={a:1, b:2} は data-a="1" data-b="2" のように) |
| 真偽値 | :sort_attrs | true | 名前によって属性をソート |
| シンボル | :js_wrapper | nil | :comment,  :cdata や :both で JavaScript をラップします。:guess を指定することで :format オプションに基いて設定することもできます |
| 真偽値 | :pretty | false | 綺麗な html インデント <b>(遅くなります!)</b> |
| 文字列 | :indent | '  ' | インデントに使用される文字列 |
| 真偽値 | :streaming | false (Rails では true, 無効化するにはストリーミングを参照) | ストリーミング出力の有効化, 体感的なパフォーマンスの向上 |
| Class | :generator | Temple::Generators::StringBuffer/ RailsOutputBuffer | Temple コードジェネレータ (デフォルトのジェネレータは文字列バッファを生成します) |
| 文字列 | :buffer | '_buf' (Rails では '@output_buffer') | バッファに使用される変数 |
| 文字列 | :splat_prefix | '*' | スプラット(アスタリスク)属性のプレフィックス |

Temple フィルタによってもっと多くのオプションがサポートされていますが一覧には載せず公式にはサポートしません。
Slim と Temple のコードを確認しなければなりません。

### オプションの優先順位と継承

Slim や Temple のアーキテクチャについてよく知っている開発者は異なる場所で設定を
上書きすることができます。 Temple はサブクラスがスーパークラスのオプションを上書きできるように
継承メカニズムを採用しています。オプションの優先順位は次のとおりです:

1. `Slim::Template` オプションはエンジン初期化時に適用されます
2. `Slim::Template.options`
3. `Slim::Engine.thread_options`, `Slim::Engine.options`
5. パーサ/フィルタ/ジェネレータ `thread_options`, `options` (例: `Slim::Parser`, `Slim::Compiler`)

`Temple::Engine` のようにスーパークラスのオプションを設定することも可能です。しかしこれはすべての Temple テンプレートエンジンに影響します。

~~~ ruby
Slim::Engine < Temple::Engine
Slim::Compiler < Temple::Filter
~~~

## プラグイン

Slim はロジックレスモードと I18n, インクルードプラグインを提供しています。プラグインのドキュメントを確認してください。

* [ロジックレスモード](doc/jp/logic_less.md)
* [パーシャルのインクルード](doc/jp/include.md)
* [多言語化/I18n](doc/jp/translator.md)
* [スマートテキストモード](doc/jp/smart.md)

## フレームワークサポート

### Tilt

Slim は生成されたコードをコンパイルするために [Tilt](https://github.com/rtomayko/tilt) を使用します。Slim テンプレートを直接使いたい場合, Tilt インターフェイスが使用できます。

~~~ ruby
Tilt.new['template.slim'].render(scope)
Slim::Template.new('template.slim', optional_option_hash).render(scope)
Slim::Template.new(optional_option_hash) { source }.render(scope)
~~~

optional_option_hash は前述のオプションを持つことができます。このオブジェクトのスコープは実行されるテンプレートの
コードです。

### Sinatra

~~~ ruby
require 'sinatra'
require 'slim'

get('/') { slim :index }

 __END__
@@ index
doctype html
html
  head
    title Slim で Sinatra
  body
    h1 Slim は楽しい!
~~~

### Rails

Rails のジェネレータは [slim-rails](https://github.com/slim-template/slim-rails) によって提供されます。
slim-rails は Rails で Slim を使用する場合に必須ではありません。Slim をインストールし Gemfile に `gem 'slim'` を追加するだけです。
後は .slim 拡張子を使えば Rails で使用できます。

#### ストリーミング

HTTP ストリーミングは Rails がそれをサポートしているバージョンであればデフォルトで有効化されています。しかし, ストリーミングが体感的なパフォーマンスを改善していることを知る必要があります。
レンダリング時間は増加するでしょう。ストリーミングを無効化したい場合の設定です:

~~~ ruby
Slim::RailsTemplate.set_options streaming: false
~~~

### Angular2

Slim は Angular2 の構文に対応しています。ただし, いくつかのオプションを設定する必要があります:

#### `splat_prefix` オプション

このオプションはパーサにスプラット(アスタリスク)属性に使用する構文を知らせます。
デフォルト値はアスタリスクです: `splat_prefix: '*'`
アスタリスクは Angular2 でも構造ディレクティブとして `*ngIf` などで使われます。デフォルトの設定値は Slim と Angular2 の構文衝突の原因になります。

解決方法は 2 つあります:

* `splat_prefix` に 2 重アスタリスクのようなカスタム値(`splat_prefix: '**'`)を設定します。これで構造ディレクティブは期待通りに機能するはずです。スプラット(アスタリスク)属性は設定したカスタム値のプレフィックスで書かなければならないので注意してください。
* アスタリスクではない代わりのディレクティブ構文を使う

#### 属性区切り文字

Angular と Slim はそれぞれの構文で括弧を使います。この場合も解決方法は 2 つ:
* バインディングに代わりの構文を使う (`bind-...` など)
* 属性区切り文字を波括弧に限定する
```
code_attr_delims: {
 '{' => '}',
},
attr_list_delims: {
 '{' => '}',
},
```

これで次のよう書けます:
```
h1{ #var (bind1)="test" [bind2]="ok" [(bind3)]="works?" *ngIf="expr" *ngFor="expression" } {{it works}}
```

コンパイル結果:
```
<h1 #var="" (bind1)="test" [bind2]="ok" [(bind3)]="works?" *ngIf="expr" *ngFor="expression">
  {{it works}}
</h1>
```

## ツール

### Slim コマンド 'slimrb'

gem の 'slim' にはコマンドラインから Slim をテストするための小さなツール 'slimrb' が付属します。

<pre>
$ slimrb --help
Usage: slimrb [options]
    -s, --stdin                      Read input from standard input instead of an input file
        --trace                      Show a full traceback on error
    -c, --compile                    Compile only but do not run
    -e, --erb                        Convert to ERB
        --rails                      Generate rails compatible code (Implies --compile)
    -r, --require library            Load library or plugin with -r slim/plugin
    -p, --pretty                     Produce pretty html
    -o, --option name=code           Set slim option
    -l, --locals Hash|YAML|JSON      Set local variables
    -h, --help                       Show this message
    -v, --version                    Print version
</pre>

'slimrb' で起動し, コードをタイプし Ctrl-d で EOF を送ります。Windows のコマンドプロンプトでは Ctrl-z で EOF を送ります。使い方例:

<pre>
$ slimrb
markdown:
  最初の段落。

  2つ目の段落。

  * 1つ
  * 2つ
  * 3つ

//Enter Ctrl-d
&lt;p&gt;最初の段落。 &lt;/p&gt;

&lt;p&gt;2つめの段落。 &lt;/p&gt;

&lt;ul&gt;
&lt;li&gt;1つ&lt;/li&gt;
&lt;li&gt;2つ&lt;/li&gt;
&lt;li&gt;3つ&lt;/li&gt;
&lt;/ul&gt;
</pre>

### 構文ハイライト

様々なテキストエディタのためのプラグインがあります。(最も重要なものも含めて - Vim, Emacs や Textmate):

* [Vim](https://github.com/slim-template/vim-slim)
* [Emacs](https://github.com/slim-template/emacs-slim)
* [Textmate / Sublime Text](https://github.com/slim-template/ruby-slim.tmbundle)
* [Espresso text editor](https://github.com/slim-template/Slim-Sugar)
* [Coda](https://github.com/slim-template/Coda-2-Slim.mode)
* [Atom](https://github.com/slim-template/language-slim)

### テンプレート変換 (HAML, ERB, ...)

* Slim は gem に含まれる `slimrb` や `Slim::ERBConverter` を用いて ERB に変換できます。
* [Haml2Slim converter](https://github.com/slim-template/haml2slim)
* [ERB2Slim, HTML2Slim converter](https://github.com/slim-template/html2slim)

## テスト

### ベンチマーク

  *そうです, Slim は最速の Ruby のテンプレートエンジンです!
   production モードの Slim は Erubis (最速のテンプレートエンジン) と同じくらい高速です。
   ありがたいことに何らかの理由であなたが Slim を選択した場合, 私たちは
   パフォーマンスが障害にならないだろうことを保証します。*

ベンチマークは `rake bench` で実行します。時間が余計にかかりますが遅い解析ベンチマークを
実行したい場合 `slow` オプションを追加できます。

~~~
rake bench slow=1 iterations=1000
~~~

私たちはコミット毎に Travis-CI でベンチマークをとっています。最新のベンチマーク結果はリンク先を確認: <http://travis-ci.org/slim-template/slim>

### テストスイートと継続的インテグレーション

Slim は minitest ベースの拡張性のあるテストスイートを提供します。テストは 'rake test' または
rails のインテグレーションテストの場合 'rake test:rails' で実行できます。

私たちは現在 markdown ファイルで書かれた人間が読めるテストを試しています: [TESTS.md](test/literate/TESTS.md)

Travis-CI は継続的インテグレーションテストに利用されています: <http://travis-ci.org/slim-template/slim>

Slim はすべての主要な Ruby 実装で動作します:

* Ruby 2.0, 2.1, 2.2 および 2.3
* JRuby 1.9 mode
* Rubinius 2.0

## 貢献

Slim の改良を支援したい場合, Git で管理されているプロジェクトを clone してください。

~~~
$ git clone git://github.com/slim-template/slim
~~~

魔法をかけた後 pull request を送ってください。私たちは pull request が大好きです！

Ruby の 2.3.0, 2.2.0, 2.1.0 と 2.0.0 でテストをすることを覚えておいてください。

もしドキュメントの不足を見つけたら, README.md をアップデートして私たちを助けて下さい。Slim に割く時間がないが, 私たちが知るべきものを何か見つけた場合には issue を送ってください。

## License

Slim は [MIT license](http://www.opensource.org/licenses/MIT) に基づいてリリースされています。

## 作者

* [Daniel Mendler](https://github.com/minad) (Lead developer)
* [Andrew Stone](https://github.com/stonean)
* [Fred Wu](https://github.com/fredwu)

## 寄付とサポート

このプロジェクトをサポートしたい場合, Gittip や Flattr のページを見てください。

[![Gittip donate button](http://img.shields.io/gittip/bevry.png)](https://www.gittip.com/min4d/ "Donate weekly to this project using Gittip")
[![Flattr donate button](https://raw.github.com/balupton/flattr-buttons/master/badge-89x18.gif)](https://flattr.com/submit/auto?user_id=min4d&url=http%3A%2F%2Fslim-lang.org%2F "Donate monthly to this project using Flattr")

今のところ, 寄付はホスティング費用 (ドメインなど) に当てられる予定です。

## 議論

* [Google Group](http://groups.google.com/group/slim-template)

## 関連プロジェクト

テンプレートのコンパイルフレームワーク:

* [Temple](https://github.com/judofyr/temple)

フレームワークサポート:

* [Rails generators (slim-rails)](https://github.com/slim-template/slim-rails)
  * [slimkeyfy - Translation string extraction](https://github.com/phrase/slimkeyfy)

構文ハイライト:

* [Vim](https://github.com/slim-template/vim-slim)
* [Emacs](https://github.com/slim-template/emacs-slim)
* [Textmate / Sublime Text](https://github.com/slim-template/ruby-slim.tmbundle)
* [Espresso text editor](https://github.com/slim-template/Slim-Sugar)
* [Coda](https://github.com/slim-template/Coda-2-Slim.mode)
* [Atom](https://github.com/slim-template/language-slim)

静的コード解析:

* [Slim-Lint](https://github.com/sds/slim-lint)
* [SublimeLinter-slim-lint](https://github.com/elstgav/SublimeLinter-slim-lint)

テンプレート変換 (HAML, ERB, ...):

* [Haml2Slim converter](https://github.com/slim-template/haml2slim)
* [ERB2Slim, HTML2Slim converter](https://github.com/slim-template/html2slim)

移植言語/同様の言語:

* [Sliq (Slim/Liquid integration)](https://github.com/slim-template/sliq)
* [Slm (Slim port to JavaScript)](https://github.com/slm-lang/slm)
* [Coffee script plugin for Slim](https://github.com/yury/coffee-views)
* [Clojure port of Slim](https://github.com/chaslemley/slim.clj)
* [Hamlet.rb (Similar template language)](https://github.com/gregwebs/hamlet.rb)
* [Plim (Python port of Slim)](https://github.com/2nd/plim)
* [Skim (Slim for JavaScript)](https://github.com/jfirebaugh/skim)
* [Emblem.js (JavaScript, similar to Slim)](https://github.com/machty/emblem.js)
* [Hamlit (High performance Haml implementation, based on Temple like Slim)](https://github.com/k0kubun/hamlit)
* [Faml (Faster Haml implementation, also using Temple like Slim)](https://github.com/eagletmt/faml)
* [Haml (Older engine which inspired Slim)](https://github.com/haml/haml)
* [Pug (Similar engine for JavaScript)](https://github.com/pugjs/pug)
* [Sweet (Similar engine which also allows to write classes and functions)](https://github.com/joaomdmoura/sweet)
* [Amber (Similar engine for Go)](https://github.com/eknkc/amber)
