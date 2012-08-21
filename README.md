MikanChat
=========
- - -


<a href="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/main1.png" rel="attachment wp-att-192"><img src="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/main1.png" alt="" title="main" width="950" height="472" class="aligncenter size-full wp-image-192" /></a>



License
-------
Copyright (c) 2012 hsmikan

The MIT License.
<http://www.opensource.org/licenses/mit-license.php>

* INCLUDED
 * [RegexKitLite](http://regexkit.sourceforge.net/RegexKitLite/)  Copyright (c) 2008-2010, John Engelhart
 * [YukkuroidRPCClient](http://yukkuroid.com/)  Copyright 2011 Cisco Systems. All rights reserved.



開発状況/予定
-----------
* 機能テスト段階（ALPHA）
* アイコン作ってくれる人募集中
* LiveTubeは気が向いたら・・・



概要
----
Mac用チャットブラウザ／コメント読み上げアプリケーションです。以下のチャットに対応しています。<br>
なお、コメント読み上げ機能を利用するには別途音声合成ソフトが必要になります。

* IRC(Ustreamでも採用されているチャットシステム)
* [cavetube](http://gae.cavelis.net/)
* [Livetube](http://livetube.cc/)
* [STICKAM JAPAN](http://www.stickam.jp)





システム要件
----------
* Tested on Mac OS X 10.8
 * 10.7は今後対応します。10.6の対応予定はありません。





<a name="onsei">音声合成環境</a>
-------------------
 * [SayKotoeri2](https://sites.google.com/site/nicohemus/home/saykotoeri2)
 * [SayKotoeri](https://sites.google.com/site/nicohemus/home/saykotoeri) ※ SayKotoeriを利用するには[SayKana](http://www.a-quest.com/quickware/saykana/)も必要になります。
 * say コマンドの Kyokoボイス
 * [ゆっくろいど](http://www.yukkuroid.com/yukkuroid/index.html) （予定）




DOWNLOAD
-----------
* Under Development.
 * [Repository](https://github.com/hsmikan/MikanChat)




-------
<a name="startup">START UP</a>
----------------
* [IRC](#irc)
* [cavetube](#cavetube)
* [STICKAM JAPAN](#stickam)
* [読み上げ](#yomiage)


- - -
#### <a name="irc">IRC</a>
1. 右上のJOINボタンを押す
<a href="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/IRC.png"><img src="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/IRC-300x291.png" alt="" title="IRC" width="300" height="291" class="aligncenter size-medium wp-image-183" /></a>

2. チャットの情報を入力します
 * <font color="red">※</font>は入力必須です。
 * <font color="red">チャット名の頭につく記号(#等)をつけ忘れないように！</font>
<a href="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/irc_login.png"><img src="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/irc_login-300x295.png" alt="" title="irc_login" width="300" height="295" class="aligncenter size-medium wp-image-182" /></a>



- - -
#### <a name="cavetube">cavetube</a>
1. 画面上部にあるテキスト欄にライブのURLを入力します。
 * 入力するものはURL(http://gae.cavelis.net/view/hogehoge) もしくは ライブID(hogehoge)です。
<a href="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/cavetube.png"><img src="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/cavetube-300x229.png" alt="" title="cavetube" width="300" height="229" class="aligncenter size-medium wp-image-185" /></a>

2. 右上のJOINボタンを押す


- - -
#### <a name="stickam">STICKAM JAPAN</a>
1. 画面上部にあるライブの情報を入力します。
 * URLだけでなくNicknameも必須事項です。
<a href="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/stickam.png"><img src="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/stickam-300x229.png" alt="" title="stickam" width="300" height="229" class="aligncenter size-medium wp-image-186" /></a>

2. 右上のJOINボタンを押す



--------------
#### <a name="yomiage">読み上げを利用する</a>
各クライアントで読み上げ機能を利用するには、事前にいくつかの準備をしなければなりません。
次の4ステップが必要となります。

1. [音声合成環境](#onsei)のインストール
 * ページ上部の[音声合成環境](#onsei)にあるリンク先からダウンロードできます。

2. 読み上げ設定を作成する
 * 画面左上部の『＋』ボタンで設定を追加します。
 * この画面で読み上げソフトやその設定と音声出力デバイスを調整できます。
<a href="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/main.png"><img src="http://www.waterbolt.info/~hsmikan/blog/wp-content/uploads/2012/08/main-300x149.png" alt="main window" title="main" width="300" height="149" class="aligncenter size-medium wp-image-180" /></a>

3. 各クライアントのウィンドウ左上部にあるボタンで２で作成した読み上げ設定を選択し、
読み上げ機能ボタンにチェックをいれます。