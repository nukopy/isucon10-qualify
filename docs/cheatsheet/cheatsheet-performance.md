# パフォーマンス改善 チートシート

## 参考

- [(2014/08)ISUCON 夏期講習 - Web アプリケーションの パフォーマンス向上のコツ 概要編](https://www.slideshare.net/kazeburo/isucon-summerclass2014action1)
  - ISUCON の概要を知れる．
- [(2014/08)ISUCON 夏期講習 - Web アプリケーションの パフォーマンス向上のコツ 実践編 完全版](https://www.slideshare.net/kazeburo/isucon-summerclass2014action2final)
  - パフォーマンスチューニングの目の付け所を知れる．

## Web サーバ：アクセスログ解析

1. `nginx.conf` の編集
2. ログをローテートし，nginx の再起動（編集の反映を行うための再起動．また，ベンチマークごとのログをみたいため，ベンチマークを実行する前に現在のログを別のファイルにコピーしてから nginx を再起動する．）
3. ベンチマークを実行（ベンチマークに対してログが出力される）
4. アクセスログの解析

### Nginx の設定ファイルの設定

### Nginx ログのローテート

- `rotate.sh`

```sh
sudo mv "/var/log/nginx/access.log" "/var/log/nginx/`date +"%Y%m%d%H%M%S"`_access.log"
sudo systemctl restart nginx
```

### kataribe の使い方

```sh
$ sudo cat /var/log/nginx/ | kataribe -f ./kataribe.toml
```

## DB サーバ：スロークエリログ解析

pt-query-digest でスロークエリログを収集する．

- 参考
  - [Mysql slow query の設定と解析方法](https://masayuki14.hatenablog.com/entry/20120704/1341360260)
  - [MySQL スロークエリ リンク集](https://qiita.com/SuguruOoki/items/75b664942af3ff3c39ad)
  - [pt-query-digest を使って遅いクエリーを発見する](https://gihyo.jp/dev/serial/01/mysql-road-construction-news/0009?page=2)
    - pt-query-digest の集計の見方

### MySQL: my.conf の設定

MySQL の場合，まず，`/etc/mysql/my.conf` にスロークエリログを吐かせるように設定する必要がある．

- MySQL のコンソールから `show variables` コマンドでスロークエリログに関する設定を確認できる．
  - `slow_query_log` が OFF になっているとスロークエリの出力は行われまない．

```sql
mysql > show variables like 'slow%';
+---------------------+----------------+
| Variable_name       | Value          |
+---------------------+----------------+
| slow_launch_time    | 2              |
| slow_query_log      | OFF            |
| slow_query_log_file | mysql-slow.log |
+---------------------+----------------+
```

- `long_query_time` は何秒以上かかったスロークエリをログへ記録するかを指定する
  - 単位が秒なので注意
  - `5` の場合，5 秒異常かかったクエリのログが吐かれる
  - `0` の場合，全てのクエリのログがログファイルへ吐かれる

```sh
mysql > show variables like 'slow%';
```

#### コンソールからの設定

```sql
mysql> set global slow_query_log_file = '/tmp/mysql-slow.log';
mysql> set global long_query_time = 5;
mysql> set global slow_query_log = ON;
```

#### my.cnf での設定

```sh
$ sudo vim /etc/mysql/my.cnf
```

- `/etc/mysql/my.cnf`

```sh
[mysqld]
slow_query_log
slow_query_log-file = /var/log/mysql/mysql-slow.sql
long_query_time = 5
```

---

## 補足

### slackcat の使い方

- 参考
  - [コマンドラインから Slack に通知を送るツール slackcat を使って長いジョブを忘れないようにする](https://msyksphinz.hatenablog.com/entry/2019/03/02/040000)
  - [slackcat を使ってみる](https://qiita.com/tearoom6/items/dfebed94f1efbddd8962)

インストール，設定，Slack へポスト，の 3 ステップ．

- インストール

```sh
$ apt-get install -y wget
$ wget https://github.com/bcicen/slackcat/releases/download/v1.5/slackcat-1.5-linux-amd64 -O slackcat
$ sudo mv slackcat /usr/local/bin/
$ sudo chmod +x /usr/local/bin/slackcat
```

- 設定
  - チーム名（任意）を入力し，[http://slackcat.chat/configure](http://slackcat.chat/configure)へアクセスするとワークスペースを選択する画面に飛ぶ．
    - 個人で使う場合はチーム名は何でも良いが，複数のワークスペースで利用する場合は `~/.slackcat` で設定する必要がある．
  - ワークスペースを選択するとブラウザにトークンが表示されるため，それをターミナルにコピペ．

```sh
$ slackcat --configure
nickname for team: isucon
token issued: [発行された token をコピペ]
```

- Slack へポスト
  - `-tee`: ポスト前に標準出力を行うオプション
  - `--channel`: ポストするチャンネルを選択
  - `--filename`: Slack 側のポストでの表示名

```sh
# ex1
$ echo "hello" | slackcat --tee --channel general

# ex2 isucon での利用例
$ sudo cat /var/log/nginx/access.log | kataribe -f ./kataribe.toml | slackcat --tee --channel isucon10 --filename kataru.prof
```

- テキストファイルの送信

```sh
# "foo.csv" というファイル名で送信される
$ cat [filename].csv | slackcat --tee --channel [channel-name] --filename foo.csv
```

- ローカルの画像ファイルの送信

```sh
# ローカルの "logo.png" が，"foo.png" というファイル名で Slack へ送信される
$ slackcat --tee --channel [channel-name] --filename foo.png ./logo.png
```

- help

```sh
$ slackcat --helpNAME:
   slackcat - redirect a file to slack

USAGE:
   slackcat [global options] command [command options] [arguments...]

VERSION:
   1.5

COMMANDS:
     help, h  Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --channel value, -c value    Slack channel or group to post to
   --comment value              Initial comment for snippet
   --configure                  Configure Slackcat via oauth
   --filename value, -n value   Filename for upload. Defaults to current timestamp
   --filetype value             Specify filetype for syntax highlighting
   --list                       List team channel names
   --noop                       Skip posting file to Slack. Useful for testing
   --stream, -s                 Stream messages to Slack continuously instead of uploading a single snippet
   --tee, -t                    Print stdin to screen before posting
   --username value, -u value   Stream messages as given bot user. Defaults to auth user
   --iconemoji value, -i value  Stream messages as given bot icon emoji. Defaults to auth user's icon
   --help, -h                   show help
   --version, -v                print the version
```
