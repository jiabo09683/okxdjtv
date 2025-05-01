#!/bin/bash

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
  echo "请使用root权限运行此脚本"
  exit 1
fi

# 获取域名输入
read -p "请输入您的域名(例如: trade.yourdomain.com): " DOMAIN

# 自动生成邮箱
EMAIL="admin@${DOMAIN}"
echo "已自动生成邮箱: $EMAIL"

# 安装必要的包
if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu系统
    apt update
    apt install -y nginx certbot python3-certbot-nginx
elif [ -f /etc/redhat-release ]; then
    # CentOS系统
    yum install -y epel-release
    yum install -y nginx certbot python3-certbot-nginx
fi

# 配置nginx
cat > /etc/nginx/conf.d/$DOMAIN.conf << EOF
server {
    listen 80;
    server_name $DOMAIN;
    # 将所有http请求重定向到https
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN;
    
    # SSL证书配置
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# 重启nginx
systemctl restart nginx

# 自动申请SSL证书
certbot --nginx -d $DOMAIN --email $EMAIL --agree-tos --no-eff-email --redirect --non-interactive

# 配置自动续期
systemctl enable certbot.timer
systemctl start certbot.timer

# 测试续期
certbot renew --dry-run

echo "=========================================="
echo "SSL证书配置完成！"
echo "证书路径: /etc/letsencrypt/live/$DOMAIN/"
echo "自动生成的邮箱: $EMAIL"
echo "已配置自动续期服务"
echo "=========================================="