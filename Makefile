NGX_LOG:=/var/log/nginx/access.log
MYSQL_LOG:=/var/log/mysql/slow.log

SLACKCAT:=slackcat --tee --channel isucon10

# TODO: 当日設定する
PROJECT_ROOT:=/home/isucon/**

# DB settings
# DB_HOST:=127.0.0.1
# DB_PORT:=3306
# DB_USER:=isucari
# DB_PASS:=isucari
# DB_NAME:=isucari
# MYSQL_CMD:=mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

########################################
# basic commands
########################################

# Git
.PHONY: commit
commit:
	git add .; \
	git commit --allow-empty -m "Makefile test"

.PHONY: push
push: 
	git push

.PHONY: pull
pull: 
	git pull

# API のテスト
.PHONY: test
test:
	curl localhost -o /dev/null -s -w "%{http_code}\n"

# アプリケーション
.PHONY: dev
dev:
	# TODO: flask の開発サーバを起動させるコマンド
	echo "hello"

.PHONY: restart-app
restart-app:
	# TODO: app の Unit ファイル名を入力
	echo "===== Copy app.service settings... ====="
	sudo cp $(PROJECT_ROOT)/config/nginx.conf /etc/nginx/nginx.conf
	sudo cp $(PROJECT_ROOT)/my.conf /etc/mysql/my.conf
	echo "----- Copied. -----"
	echo "===== Restart middlewares... ====="
	sudo systemctl restart nginx
	sudo systemctl restart mysql
	echo "----- Restarted. -----"

# ミドルウェアの設定を反映させる
.PHONY: restart-mid
restart-mid:
	echo "===== Copy middleware settings... ====="
	sudo cp $(PROJECT_ROOT)/config/nginx/nginx.conf /etc/nginx/nginx.conf
	sudo cp $(PROJECT_ROOT)/config/mysql/my.conf /etc/mysql/my.conf
	echo "----- Copied. -----"
	echo "===== Restart middlewares... ====="
	sudo systemctl restart nginx
	sudo systemctl restart mysql
	echo "----- Restarted. -----"

# ログ
.PHONY: log-ngx
log-ngx:
	tail -f $(NGX_LOG)

########################################
# initial configuration
########################################

.PHONY: machine
machine:
	$(shell free -h)


.PHONY: os
os:
	grep -H "" /etc/*version ; grep -H "" /etc/*release

# サーバのセットアップ
.PHONY: setup
setup:
	# install basic packages, pt-query-digest(percona-toolkit)
	sudo apt-get update && sudo apt-get install -y dstat htop git unzip percona-toolkit
	# install kataribe
	wget https://github.com/matsuu/kataribe/releases/download/v0.4.1/kataribe-v0.4.1_linux_amd64.zip -O kataribe.zip
	unzip -o kataribe.zip
	sudo mv kataribe /usr/local/bin/
	sudo chmod +x /usr/local/bin/kataribe
	rm kataribe.zip
	kataribe -generate
	# install slackcat
	wget https://github.com/bcicen/slackcat/releases/download/v1.5/slackcat-1.5-linux-amd64 -O slackcat
	sudo mv slackcat /usr/local/bin/
	sudo chmod +x /usr/local/bin/slackcat
	slackcat --configure

########################################
# performance tuning
########################################

# アクセスログ解析 with kataribe(リポジトリのルートディレクトリで実行)
.PHONY: kataru
	sudo cat $(NGX_LOG) | kataribe -f ./kataribe.toml | $(SLACKCAT) --filename kataru.prof

# スロークエリログ解析
.PHONY: slow
slow:
	sudo pt-query-digest $(MYSQL_LOG) | $(SLACKCAT)

.PHONY: slow-on
slow-on:
	sudo mysql -e "set global slow_query_log_file = '$(MYSQL_LOG)'; set global long_query_time = 0; set global slow_query_log = ON;"
	# sudo $(MYSQL_CMD) -e "set global slow_query_log_file = '$(MYSQL_LOG)'; set global long_query_time = 0; set global slow_query_log = ON;"

.PHONY: slow-off
slow-off:
	sudo mysql -e "set global slow_query_log = OFF;"
	# sudo $(MYSQL_CMD) -e "set global slow_query_log = OFF;"

# ログのローテート
.PHONY: 
rot-ngx:
	when=$(eval when := $(shell date "+%Y%m%d-%H%M%S"))
	mkdir -p ~/logs/$(when)
	@if [ -f $(NGX_LOG) ]; then \
		sudo mv -f $(NGX_LOG) ~/logs/$(when)/ ; \
	fi
	sudo systemctl restart nginx

.PHONY: 
rot-sql:
	when=$(eval when := $(shell date "+%Y%m%d-%H%M%S"))
	mkdir -p ~/logs/$(when)
	@if [ -f $(MYSQL_LOG) ]; then \
		sudo mv -f $(MYSQL_LOG) ~/logs/$(when)/ ; \
	fi
	sudo systemctl restart mysql

########################################
# deploy
########################################

# 全てのコードを
.PHONY: deploy
deploy:
