# generate key pair
ssh-keygen -f ~/.ssh/$KEY -t rsa -N ""

# MUST: sshpass, ssh-copy-id はインストール済み
# brew install hudochenkov/sshpass/sshpass
# brew install ssh-copy-id
sshpass -p $PSW ssh-copy-id -i ~/.ssh/$KEY $USER@$IP1
sshpass -p $PSW ssh-copy-id -i ~/.ssh/$KEY $USER@$IP2
sshpass -p $PSW ssh-copy-id -i ~/.ssh/$KEY $USER@$IP3

# 接続をチェック
# MUST: ~/.ssh/config に SSH クライアント追加済み
# echo $(ssh -T $USER@$CL1)
# echo $(ssh -T $USER@$CL2)
# echo $(ssh -T $USER@$CL3)
