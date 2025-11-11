#!/bin/bash

# codedeploy-agentのインストール
sudo dnf install -y ruby wget
cd /tmp
wget https://aws-codedeploy-ap-northeast-1.s3.ap-northeast-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent
sleep 30
rm -f /tmp/install

# httpdのインストール
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# ルートパス ("/") にアクセスがあった場合に HTTP 200 OK を返すための簡単なindex.html
echo "<html><head><title>Healthy</title></head><body>Instance is ready and healthy.</body></html>" | sudo tee /var/www/html/index.html > /dev/null