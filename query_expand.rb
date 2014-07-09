#!ruby
# coding: utf-8

require "./lib/scraiping"
require "./extractcontent/lib/extractcontent"
require "nkf"
require "./lib/mecab_lib.rb"
require "pp"
require "FileUtils"

# 検索文書
query_docs = []
File.open("./query_data/querylist.txt", "r") { |f| query_docs = f.read.split("\n") }

# 形態素解析
queries = MeCabLib.new.analyze_sentences(query_docs)

# 検索エンジンインスタンス初期化 
web_client = Scraiping::WebClient.new       # Webアクセスを担当するインスタンスを生成
yahoo_search = Scraiping::YahooSearch.new   # Yahoo検索エンジンのインスタンスを生成
yahoo_search.web_client = web_client        # 検索結果ページへのアクセスにweb_clientインスタンスを使用

# クエリと検索結果
# { ['q1', 'q2'] => ['d1', 'd2'] }
query_to_result = {}

# クエリ単語
queries.each do |query|

    # 検索エンジンを使用して検索
    # 1引数目 => ページの番号
    urlList = yahoo_search.retrieve(1, query)   # 検索クエリで，1~10番目の検索結果のURLを取得

    # 検索結果ページへのアクセス 
    url_bodies = []
    
        urlList.each do |url| 
            begin
                http = web_client.open(url)                         # 実際にページにアクセス

                # 検索結果ページが有効でない場合，そのURLへのアクセスをスキップ
                if http == nil
                    next
                end

                # 検索結果から本文らしい部分を抽出して表示
                encoded_contents = NKF.nkf("-w", http.read)         # 文字コード変換
                p encoded_contents
                body = ExtractContent::analyse(encoded_contents)    # 本文らしい部分を尤度計算して，抽出
                url_bodies << body

                # pp query

                # puts body                                           # 抽出した本文を表示
                # puts "======================================================================"

            rescue => e
                p e
                next
            end
        end
        
    query_to_result[query] = url_bodies
end

pp query_to_result

# Web検索文書をファイルに出力
query_to_result.values.each_with_index do |result_docs, i|
    result_docs.each_with_index do |result_doc, j|
        # result_docは["文書", "タイトル"]となっている
        dir_name = "./query_expand/#{format("%03d", i+1)}"

        FileUtils.mkdir_p(dir_name) unless FileTest.exist?(dir_name)
        File.open("#{dir_name}/#{format("%03d", j+1)}.txt", "wb") do |f|
            f.write(result_doc[0])
        end
    end
end

