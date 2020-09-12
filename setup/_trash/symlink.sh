# nginx
sudo mv /etc/nginx/nginx.conf ~/app/nginx/
sudo ln -s ~/app/nginx/nginx.conf /etc/nginx/

sudo service apache2 stop
sudo service apache2 disable
sudo service nginx start
sudo service nginx enable

# mysql

# bash