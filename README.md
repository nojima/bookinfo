bookinfo
========

ISBN を与えると Amazon から本の情報を取ってくるスクリプト．


## インストール

* Ruby 1.9 が必要です．Debian や Ubuntu の場合は以下のコマンドでインストール可能です．

    $ sudo apt-get install ruby1.9.1 libruby1.9.1

* `config/amazon.yml` に Product Advertising API の key と secret と AssociateTag を記述する必要があります．
  `config/amazon.yml.example` を参考に記述してください．


## 使い方

標準入力にISBNのリストを与えると，標準出力にTSV(タブ区切りテキスト)を吐きます．

    $ cat isbn.txt
    9784894711631
    9784756136497
    9784320018778
    
    $ bookinfo < isbn.txt > info.tsv
    
    $ cat info.tsv
    9784894711631	ジェラルド・ジェイ サスマン	ピアソンエデュケーション	計算機プログラムの構造と解釈
    9784756136497	ブライアン カーニハン	アスキー	プログラミング作法
    9784320018778	Judea Pearl	共立出版	統計的因果推論 -モデル・推論・推測-

`--fetch-images` を指定することで，指定したディレクトリに表紙画像をダウンロードすることができます．

    $ mkdir /tmp/bookimages
    $ bookinfo --fetch-images /tmp/bookimages < isbn.txt > info.tsv
    $ ls /tmp/bookimages
    9784320018778.jpg  9784756136497.jpg  9784894711631.jpg

その他のオプションについては，`bookinfo --help` を参照してください．


## ライセンス

MIT License
