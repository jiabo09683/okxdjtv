# 部署指南

## 前置条件
- Ubuntu 20.04/CentOS 7 或更高版本
- 已解析的域名（指向服务器IP）
- root 权限

## 一键部署步骤

1. 登录服务器:
```bash
ssh root@你的服务器IP
```

2. 下载并运行部署脚本:
```bash
wget https://raw.githubusercontent.com/jiabo09683/okxdjtv/main/deploy.sh
chmod +x deploy.sh
./deploy.sh
```

3. 按提示输入:
- 域名地址
- 环境变量配置

## 部署后验证

1. 检查服务状态:
```bash
supervisorctl status okxdjtv
```

2. 检查SSL证书:
```bash
curl https://你的域名
```

3. 查看运行日志:
```bash
tail -f /var/log/okxdjtv/out.log
```

## 常用维护命令

- 重启服务:
```bash
supervisorctl restart okxdjtv
```

- 停止服务:
```bash
supervisorctl stop okxdjtv
```

- 启动服务:
```bash
supervisorctl start okxdjtv
```

- 查看错误日志:
```bash
tail -f /var/log/okxdjtv/err.log
```