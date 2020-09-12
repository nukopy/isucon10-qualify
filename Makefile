NGX_LOG:=/var/log/nginx/access.log
MYSQL_LOG:=/var/log/mysql/slow.log

SLACKCAT:=slackcat --tee --channel isucon10

PROJECT_ROOT:=/home/isucon/isuumo

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
	git commit --allow-empty -m "$(msg)"

.PHONY: push
push: 
	git push origin master

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

.PHONY: rst-app
rst-app:
	echo "===== Copy app.service settings... ====="
	sudo cp $(PROJECT_ROOT)/config/systemd/isuumo.python.service /etc/systemd/system/isuumo.python.service
	echo "----- Copied. -----"
	echo "===== Restart middlewares... ====="
	sudo systemctl daemon-reload
	sleep 5
	sudo systemctl restart isuumo.python.service
	echo "----- Restarted. -----"

# ミドルウェアの設定を反映させる
.PHONY: rst-ngx
rst-ngx:
	echo "===== Copy nginx settings... ====="
	sudo cp $(PROJECT_ROOT)/config/nginx/nginx.conf /etc/nginx/nginx.conf
	echo "----- Copied. -----"
	echo "===== Restart nginx... ====="
	sudo systemctl restart nginx
	echo "----- Restarted. -----"

.PHONY: rst-db
rst-db:
	echo "===== Copy mysql settings... ====="
	sudo cp $(PROJECT_ROOT)/config/mysql/my.conf /etc/mysql/my.conf
	echo "----- Copied. -----"
	echo "===== Restart mysql... ====="
	sudo systemctl restart mysql
	echo "----- Restarted. -----"

# ログ
.PHONY: log-ngx
log-ngx:
	sudo tail -f $(NGX_LOG)

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
	# git config
	git config --global user.name "nukopy"
	git config --global user.email "pytwbf201830@gmail.com"
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
kataru:
	sudo cat $(NGX_LOG) | kataribe -f ./kataribe.toml | $(SLACKCAT) --filename kataru.prof

# スロークエリログ解析
.PHONY: slow
slow:
	sudo pt-query-digest $(MYSQL_LOG) | $(SLACKCAT) --filename slow-summary.txt

.PHONY: slow-on
slow-on:
	sudo mysql -e "set global slow_query_log_file = '$(MYSQL_LOG)'; set global long_query_time = 0; set global slow_query_log = ON;"
	# sudo $(MYSQL_CMD) -e "set global slow_query_log_file = '$(MYSQL_LOG)'; set global long_query_time = 0; set global slow_query_log = ON;"

.PHONY: slow-off
slow-off:
	sudo mysql -e "set global slow_query_log = OFF;"
	# sudo $(MYSQL_CMD) -e "set global slow_query_log = OFF;"

# ログのローテート
.PHONY: rot-ngx
rot-ngx:
	$(eval when := $(shell date "+%Y%m%d-%H%M%S"))
	mkdir -p ~/logs/$(when)
	@if [ -f $(NGX_LOG) ]; then \
		sudo mv -f $(NGX_LOG) ~/logs/$(when)/ ; \
	fi
	sudo systemctl restart nginx

.PHONY: rot-db 
rot-db:
	$(eval when := $(shell date "+%Y%m%d-%H%M%S"))
	mkdir -p ~/logs/$(when)
	@if [ -f $(MYSQL_LOG) ]; then \
		sudo mv -f $(MYSQL_LOG) ~/logs/$(when)/ ; \
	fi
	sudo systemctl restart mysql

# ベンチを回す前に実行
.PHONY: before-bench
# before-bench: rot-ngx rst-ngx rot-db rst-db rst-app
before-bench: rot-ngx rst-ngx rst-app


########################################
# deploy
########################################

# 全てのコードを
.PHONY: deploy
deploy: commit push pull