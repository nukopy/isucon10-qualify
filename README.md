# ISUCON 10

2020/09/12 に開催された ISUCON10 のリポジトリ

- team: HHKB は実質 0 円
- member: nukopy（1 人チーム）

## ディレクトリ構造

- `config/`：ミドルウェア，計測系ソフトウェアの設定ファイル
  - Nginx の設定ファイル：`nginx.conf`
  - MySQL の設定ファイル：`mysql.conf`
- `setup/`：初期設定のためのシェルスクリプト
  - `ssh-local2server.sh`：SSH 接続：ローカル環境 <-> ISUCON サーバ
    - ローカルから SSH 接続できるようにする for "VSCode Remote Development"
  - `ssh-server2github.sh`：SSH 接続：ISUCON サーバ <-> GitHub
    - ISUCON サーバで git pull/push できるようにする
    - `config-server2github`サーバ側の `~/.ssh/config` のテンプレ
  - `git-init.sh`
    - サーバでローカルリポジトリを初期化して git pull
