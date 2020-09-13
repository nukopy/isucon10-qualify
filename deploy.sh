# 全てのサーバのファイルを同期する
# MUST: 全サーバを git 管理ができている状態にしておく
export CMD="cd $APP_DIR && git pull origin master"

ssh $USER@$CL1 $CMD
ssh $USER@$CL2 $CMD
ssh $USER@$CL3 $CMD