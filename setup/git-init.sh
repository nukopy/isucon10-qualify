# MUST: 事前にサーバ <-> GitHub 間の SSH 接続の設定をしておく
# MUST: サーバ側に git が入っていることを確認
# MUST: サーバ側のアプリケーションディレクトリの位置を確認
export APP_DIR="/home/$USER/app"
export GIT_REMOTE="git@github.com:nukopy/nisucon2020.git"  # git clone
export CMD="cd $APP_DIR && git init && git remote add origin $GIT_REMOTE && git pull origin master"
export CMD_REMOVE_REMOTE="cd $APP_DIR && git init && git remote rm origin"

# git pull: どのサーバからでも Git push できるようにする
ssh $USER@$CL1 $CMD
ssh $USER@$CL2 $CMD
ssh $USER@$CL3 $CMD

# 一旦 remote を消去したいとき
# ssh $USER@$CL1 $CMD_REMOVE_REMOTE
# ssh $USER@$CL2 $CMD_REMOVE_REMOTE
# ssh $USER@$CL3 $CMD_REMOVE_REMOTE
