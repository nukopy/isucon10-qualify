# コマンド チートシート

## サービスの起動，停止，再起動，自動起動有効，自動起動無効

- サービス一覧

- apache の停止，自動起動無効

```sh
sudo systemctl stop apache
sudo systemctl disable apache
```

- nginx の起動，自動起動有効

```sh
sudo systemctl start nginx
sudo systemctl enable nginx
```

## SSH 接続関連

- ターミナルからサーバへ SSH 接続

```sh
$ ssh [username]@[ホスト名 or グルーバル IP]

# ex
$ ssh isucon@34.247.15.19
```

- 秘密鍵 / 公開鍵のペアを名前を指定し，パスフレーズなしで生成
  - `-f`: output filename
  - `-t`: アルゴリズムの種類
  - `-N`: 鍵のパスフレーズ．`-N ""` でパスフレーズなしに出来る．

```sh
# [key-name] / [key-name].pub というペアができる
$ ssh-keygen -f [key-name] -t rsa -N ""

# ex
$ ssh-keygen -f ~/.ssh/id_rsa_isucon -t rsa -N ""
$ ls ~/.ssh/ | grep isucon
id_rsa_isucon
id_rsa_isucon.pub
```

- 公開鍵のアップロード
  - sshpass, ssh-copy-id を利用

```sh
$ sshpass -p "password" ssh-copy-id -i [ローカルの公開鍵] [user]@[グローバル IP]

# ex
$ sshpass -p "isucon" ssh-copy-id -i ~/.ssh/id_rsa_isucon isucon@34.247.15.19
```

- SSH クライアントの設定：`config` ファイルの例

```sh
# nisucon2020
Host bench
        User ptc-user
        HostName 34.84.137.217
        IdentityFile ~/.ssh/id_rsa_nisucon2020

Host web1
        User ptc-user
        HostName 35.189.152.112
        IdentityFile ~/.ssh/id_rsa_nisucon2020

Host web2
        User ptc-user
        HostName 34.84.123.241
        IdentityFile ~/.ssh/id_rsa_nisucon2020
```

- SSH 接続の確認
  - SSH 接続の設定がちゃんとできているか確認するときに用いる

```sh
$ ssh -T [user]@[host]

# ex
$ ssh -T git@github.com
Hi nukopy! You've successfully authenticated, but GitHub does not provide shell access.
```

## scp によるローカル <-> リモートのファイルのやりとり

- ローカル -> リモートへアップロード
  - 公開鍵のアップロード，SSH クライアントの設定を終えていると自分が指定したホスト名を用いてコマンドを実行できる．

```sh
$ scp [コピーしたいローカルのファイルパス] [user]@[ホスト名]:[リモートの保存したファイルパス]

# ex
# config のアップロード
$ scp ./config-server2github $USER@$CL1:~/.ssh/config
$ scp ./config-server2github $USER@$CL2:~/.ssh/config
$ scp ./config-server2github $USER@$CL3:~/.ssh/config
#
$ scp ~/.ssh/id_rsa_nukopy_github $USER@$CL1:~/.ssh/id_rsa_nukopy_github
$ scp ~/.ssh/id_rsa_nukopy_github $USER@$CL2:~/.ssh/id_rsa_nukopy_github
$ scp ~/.ssh/id_rsa_nukopy_github $USER@$CL3:~/.ssh/id_rsa_nukopy_github

```

- リモート -> ローカルへアップロード

```sh
$ scp [user]@[ホスト名]:[リモートのコピーしたいファイルパス] [保存したいローカルのファイルパス]

# ex
$ scp /local/test.txt user@sandbox_vps:/home/user/tmp
```

参考：[scp コマンドでサーバー上のファイル or ディレクトリをローカルに落としてくる](https://qiita.com/katsukii/items/225cd3de6d3d06a9abcb)
