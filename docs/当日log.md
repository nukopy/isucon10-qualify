# 作業ログ

## 序盤

- ポータルにログイン
- サーバのグローバル IP 確認
  - `.envrc` を更新
- ローカル環境の `~/.ssh/config` を書く
  - 踏み台サーバの設定に注意
- `setup/from-local/ssh-local2server`
- SSH の設定まで終える

- ## git pull でコードを全サーバに反映

ローカル

- ミドルウェアの設定ファイルを自前のものにする
  - Nginx
  - MySQL
- web と db を分ける

## 中盤

- まず Nginx の設定
  - 全てのサーバで app を動かし，ロードバランシングする
