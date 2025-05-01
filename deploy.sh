#!/bin/bash

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 获取域名输入
read -p "请输入您的域名(例如: trade.yourdomain.com): " DOMAIN
EMAIL="admin@${DOMAIN}"
echo "已自动生成邮箱: $EMAIL"

# 更新系统并安装必要的包
if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu系统
    apt update && apt upgrade -y
    apt install -y python3 python3-pip git supervisor nginx certbot python3-certbot-nginx
elif [ -f /etc/redhat-release ]; then
    # CentOS系统
    yum update -y
    yum install -y epel-release
    yum install -y python3 python3-pip git supervisor nginx certbot python3-certbot-nginx
fi

# 克隆项目
git clone https://github.com/jiabo09683/okxdjtv.git
cd okxdjtv

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
echo "请编辑 .env 文件配置您的环境变量"
sleep 3
nano .env

# 配置 Supervisor
cat > /etc/supervisor/conf.d/okxdjtv.conf << EOF
[program:okxdjtv]
directory=/root/okxdjtv
command=/root/okxdjtv/venv/bin/python okx_account.py
autostart=true
autorestart=true
stderr_logfile=/var/log/okxdjtv/err.log
stdout_logfile=/var/log/okxdjtv/out.log
EOF

# 创建日志目录
mkdir -p /var/log/okxdjtv

# 配置 Nginx
cat > /etc/nginx/conf.d/$DOMAIN.conf << EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN;
    
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

# 重启 Nginx
systemctl restart nginx

# 申请 SSL 证书
certbot --nginx -d $DOMAIN --email $EMAIL --agree-tos --no-eff-email --redirect --non-interactive

# 配置证书自动续期
systemctl enable certbot.timer
systemctl start certbot.timer

# 测试证书续期
certbot renew --dry-run

# 启动服务
supervisorctl reread
supervisorctl update
supervisorctl start okxdjtv

# 输出部署结果
echo "=================== 部署完成 ==================="
echo "项目目录: /root/okxdjtv"
echo "域名: $DOMAIN"
echo "SSL证书路径: /etc/letsencrypt/live/$DOMAIN/"
echo "日志文件位置:"
echo "  - 程序输出: /var/log/okxdjtv/out.log"
echo "  - 错误日志: /var/log/okxdjtv/err.log"
echo "常用命令:"
echo "  - 查看状态: supervisorctl status okxdjtv"
echo "  - 重启服务: supervisorctl restart okxdjtv"
echo "  - 查看日志: tail -f /var/log/okxdjtv/out.log"
echo "=============================================="