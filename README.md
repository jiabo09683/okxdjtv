# 部署指南

## 前置条件
- Ubuntu 20.04/CentOS 7 或更高版本
- Python 3.10.9 或更高版本
- 已解析的域名（指向服务器IP）
- root 权限

## Python 环境配置

### Ubuntu/Debian 系统:
```bash
# 安装依赖
sudo apt update
sudo apt install -y software-properties-common

# 添加 deadsnakes PPA 源
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

# 安装 Python 3.10
sudo apt install -y python3.10 python3.10-venv python3.10-dev

# 设置 Python 3.10 为默认版本
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
```

### CentOS 系统:
```bash
# 安装依赖
sudo yum update -y
sudo yum groupinstall -y "Development Tools"
sudo yum install -y openssl-devel bzip2-devel libffi-devel

# 下载并编译 Python 3.10.9
wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz
tar xzf Python-3.10.9.tgz
cd Python-3.10.9
./configure --enable-optimizations
sudo make altinstall

# 创建软链接
sudo ln -sf /usr/local/bin/python3.10 /usr/bin/python3
sudo ln -sf /usr/local/bin/pip3.10 /usr/bin/pip3
```

### 验证 Python 版本
```bash
python3 --version  # 应显示 Python 3.10.9 或更高版本
```

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

## 常见问题

### Python 版本问题
如果遇到 Python 版本相关错误，请确保：
1. Python 版本 >= 3.10.9
2. pip 已正确安装
3. 虚拟环境使用正确的 Python 版本

检查方法：
```bash
# 检查 Python 版本
python3 --version

# 检查 pip 版本
pip3 --version

# 检查虚拟环境 Python 版本
source venv/bin/activate
python --version
```