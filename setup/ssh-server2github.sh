# scp [送信側] [受信側]
# config ファイルの転送
scp ./config-server2github $USER@$CL1:~/.ssh/config 
scp ./config-server2github $USER@$CL2:~/.ssh/config 
scp ./config-server2github $USER@$CL3:~/.ssh/config 
# 秘密鍵（GitHub に登録されている公開鍵とペアの秘密鍵）
scp ~/.ssh/id_rsa_nukopy_github $USER@$CL1:~/.ssh/id_rsa_nukopy_github
scp ~/.ssh/id_rsa_nukopy_github $USER@$CL2:~/.ssh/id_rsa_nukopy_github
scp ~/.ssh/id_rsa_nukopy_github $USER@$CL3:~/.ssh/id_rsa_nukopy_github

# GitHub と接続できるかチェック
ssh $USER@$CL1 "ssh -T git@github.com"
ssh $USER@$CL2 "ssh -T git@github.com"
ssh $USER@$CL3 "ssh -T git@github.com"
# サーバ側でエラーが起きる場合があるから一旦サーバに入って以下を実行
# ssh -T git@github.com  # yes を入力して enter
# The authenticity of host 'github.com (52.192.72.89)' can't be established.
# RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
# Are you sure you want to continue connecting (yes/no)? yes
# Warning: Permanently added 'github.com,52.192.72.89' (RSA) to the list of known hosts.
