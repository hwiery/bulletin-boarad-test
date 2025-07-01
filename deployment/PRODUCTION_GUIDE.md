# 🚀 TSBOARD 운영환경 배포 및 관리 가이드

이 문서는 TSBOARD를 운영환경에 안전하고 효율적으로 배포하는 방법을 설명합니다.

## 📋 사전 준비사항

### 필수 요구사항
- **운영 체제**: Ubuntu 20.04 LTS 이상 (권장)
- **서버 사양**: 최소 2GB RAM, 2 vCPU, 20GB 저장공간
- **도메인**: 실제 도메인 또는 서브도메인
- **DNS 설정**: A 레코드가 서버 IP를 가리키도록 설정

### 보안 고려사항
- 서버 방화벽 설정
- SSH 키 기반 인증 설정
- 정기적인 보안 업데이트
- 강력한 비밀번호 정책

## 🛠️ 자동 배포

### 1. 서버 준비
```bash
# 서버에 접속 후
cd /tmp
wget https://raw.githubusercontent.com/hwiery/bulletin-boarad-test/main/deployment/deploy.sh
chmod +x deploy.sh
```

### 2. 배포 실행
```bash
# 도메인을 지정하여 배포 (SSL 자동 설정)
sudo ./deploy.sh yourdomain.com

# 또는 도메인 없이 배포 (추후 수동 SSL 설정)
sudo ./deploy.sh
```

### 3. 배포 후 작업
배포 완료 후 다음 설정을 수동으로 변경해야 합니다:

```bash
# .env 파일 수정
sudo nano /var/www/tsboard/.env
```

#### 필수 변경 항목
- `GOAPI_URL`: 실제 도메인으로 변경
- `DB_PASSWORD`: 강력한 비밀번호로 변경
- `JWT_SECRET_KEY`: 64자 이상의 무작위 문자열
- `ADMIN_PASSWORD`: 관리자 비밀번호 변경
- `ADMIN_ID`: 실제 관리자 이메일로 변경

## 🔧 수동 배포

자동 배포를 사용할 수 없는 경우 다음 단계를 따라 수동으로 배포하세요.

### 1. 기본 패키지 설치
```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# 필수 패키지 설치
sudo apt install -y nginx mysql-server nodejs npm git
sudo apt install -y certbot python3-certbot-nginx
sudo apt install -y ufw fail2ban libvips-dev pkg-config
```

### 2. 사용자 계정 생성
```bash
# tsboard 사용자 생성
sudo useradd -r -m -s /bin/bash tsboard
sudo usermod -aG www-data tsboard

# 디렉토리 생성
sudo mkdir -p /var/www/tsboard
sudo mkdir -p /var/log/tsboard
sudo chown -R tsboard:tsboard /var/www/tsboard
sudo chown -R tsboard:tsboard /var/log/tsboard
```

### 3. 소스코드 배포
```bash
# 소스코드 다운로드
cd /var/www/tsboard
sudo -u tsboard git clone https://github.com/hwiery/bulletin-boarad-test.git .

# Node.js 의존성 설치
sudo -u tsboard npm ci --production

# 운영환경 설정
sudo -u tsboard cp tsboard.config.production.ts tsboard.config.ts
sudo -u tsboard cp env.production.sample .env

# Vue.js 빌드
sudo -u tsboard npm run build

# Go 바이너리 컴파일
cd goapi.git
sudo -u tsboard go build -o ../goapi-linux cmd/main.go
cd ..
sudo chmod +x goapi-linux
```

### 4. 데이터베이스 설정
```bash
# MySQL 보안 설정
sudo mysql_secure_installation

# 데이터베이스 생성
sudo mysql -e "CREATE DATABASE tsboard_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER 'tsboard_prod'@'localhost' IDENTIFIED BY 'strong_password_here';"
sudo mysql -e "GRANT ALL PRIVILEGES ON tsboard_prod.* TO 'tsboard_prod'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

### 5. Nginx 설정
```bash
# 설정 파일 복사
sudo cp deployment/nginx.conf /etc/nginx/sites-available/tsboard

# 도메인 설정 (yourdomain.com을 실제 도메인으로 변경)
sudo sed -i 's/yourdomain.com/실제도메인.com/g' /etc/nginx/sites-available/tsboard

# 설정 활성화
sudo ln -s /etc/nginx/sites-available/tsboard /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Nginx 재시작
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### 6. systemd 서비스 설정
```bash
# 서비스 파일 복사
sudo cp deployment/systemd/tsboard-api.service /etc/systemd/system/

# 서비스 활성화
sudo systemctl daemon-reload
sudo systemctl enable tsboard-api
sudo systemctl start tsboard-api
```

### 7. SSL 인증서 설정
```bash
# Let's Encrypt 인증서 발급
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### 8. 방화벽 설정
```bash
# UFW 설정
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## 📊 모니터링 설정

### 1. 모니터링 스크립트 설정
```bash
# 실행 권한 부여
sudo chmod +x /var/www/tsboard/deployment/monitor.sh

# 이메일 설정 (선택사항)
sudo apt install mailutils

# crontab에 등록 (5분마다 실행)
sudo crontab -e
```

crontab에 다음 라인 추가:
```bash
*/5 * * * * /var/www/tsboard/deployment/monitor.sh
```

### 2. 백업 설정
```bash
# 백업 스크립트 실행 권한 부여
sudo chmod +x /var/www/tsboard/deployment/backup.sh

# 백업 스크립트 내 비밀번호 설정
sudo nano /var/www/tsboard/deployment/backup.sh
# DB_PASSWORD를 실제 비밀번호로 변경

# crontab에 등록 (매일 새벽 2시 실행)
sudo crontab -e
```

crontab에 다음 라인 추가:
```bash
0 2 * * * /var/www/tsboard/deployment/backup.sh
```

## 🔒 보안 강화

### 1. SSH 보안 설정
```bash
# SSH 설정 파일 수정
sudo nano /etc/ssh/sshd_config
```

권장 설정:
```
Port 22222  # 기본 포트 변경
PermitRootLogin no
PasswordAuthentication no  # 키 기반 인증만 허용
PubkeyAuthentication yes
MaxAuthTries 3
```

### 2. Fail2Ban 설정
```bash
# 설정 파일 생성
sudo nano /etc/fail2ban/jail.local
```

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true

[nginx-http-auth]
enabled = true

[nginx-limit-req]
enabled = true
```

```bash
# Fail2Ban 재시작
sudo systemctl restart fail2ban
```

### 3. 정기 보안 업데이트
```bash
# unattended-upgrades 설치
sudo apt install unattended-upgrades

# 자동 보안 업데이트 활성화
sudo dpkg-reconfigure -plow unattended-upgrades
```

## 🔄 운영 관리

### 서비스 상태 확인
```bash
# 모든 서비스 상태 확인
sudo systemctl status tsboard-api nginx mysql

# 로그 확인
sudo journalctl -u tsboard-api -f
sudo tail -f /var/log/nginx/tsboard_error.log
sudo tail -f /var/log/tsboard/monitor.log
```

### 수동 백업
```bash
# 즉시 백업 실행
sudo /var/www/tsboard/deployment/backup.sh

# 백업 파일 확인
sudo ls -la /var/backups/tsboard/
```

### 업데이트 배포
```bash
cd /var/www/tsboard

# 소스코드 업데이트
sudo -u tsboard git pull origin main

# 의존성 업데이트
sudo -u tsboard npm ci --production

# 프론트엔드 재빌드
sudo -u tsboard npm run build

# 백엔드 재컴파일
cd goapi.git
sudo -u tsboard go build -o ../goapi-linux cmd/main.go
cd ..

# 서비스 재시작
sudo systemctl restart tsboard-api
sudo systemctl reload nginx
```

### 로그 로테이션
```bash
# logrotate 설정
sudo nano /etc/logrotate.d/tsboard
```

```
/var/log/tsboard/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 tsboard tsboard
    postrotate
        systemctl reload tsboard-api
    endscript
}
```

## 🚨 문제 해결

### 일반적인 문제들

#### 1. API 서버가 시작되지 않는 경우
```bash
# 로그 확인
sudo journalctl -u tsboard-api -n 50

# 환경변수 확인
sudo -u tsboard cat /var/www/tsboard/.env

# 수동 실행으로 오류 확인
sudo -u tsboard /var/www/tsboard/goapi-linux
```

#### 2. 데이터베이스 연결 오류
```bash
# MySQL 연결 테스트
mysql -u tsboard_prod -p -h 127.0.0.1 tsboard_prod

# MySQL 프로세스 확인
sudo systemctl status mysql
```

#### 3. Nginx 설정 오류
```bash
# 설정 파일 테스트
sudo nginx -t

# Nginx 로그 확인
sudo tail -f /var/log/nginx/error.log
```

#### 4. SSL 인증서 문제
```bash
# 인증서 갱신
sudo certbot renew --dry-run

# 인증서 상태 확인
sudo certbot certificates
```

### 성능 최적화

#### 1. MySQL 최적화
```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

추가 설정:
```ini
[mysqld]
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
query_cache_size = 32M
max_connections = 200
```

#### 2. Nginx 최적화
```bash
sudo nano /etc/nginx/nginx.conf
```

worker_processes와 worker_connections 조정:
```nginx
worker_processes auto;
worker_connections 1024;
```

## 📞 지원 및 문의

- **GitHub Issues**: https://github.com/hwiery/bulletin-boarad-test/issues
- **문서**: 프로젝트 README.md 참조
- **커뮤니티**: 설치 후 자체 게시판에서 질문 가능

---

이 가이드를 따라 TSBOARD를 안전하고 효율적으로 운영하시기 바랍니다. 추가 질문이나 문제가 있다면 GitHub Issues를 통해 문의해 주세요. 