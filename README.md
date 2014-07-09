WebRetrieve
===========

概要:
クエリのファイル
=> 形態素解析 
=> yahooサーチ 
=> Web文書をファイルに出力するコード

実行:
ruby query_expand.rb

input:
./query_data/querylist.txt
(クエリーを含んだファイル)

output:
./query_expand
(1つ目クエリのweb文書の格納は
./query_expand/u001/001.txt ~ 00n.txt ...
の用に格納)

Usage
=====
Please see sample.rb and lib/scraiping.rb.

License
=======
The BSD License.
