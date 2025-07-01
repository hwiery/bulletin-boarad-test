#!/bin/bash

# TSBOARD 운영환경 배포 스크립트
# 사용법: sudo ./deploy.sh [domain]
# 예시: sudo ./deploy.sh mydomain.com

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 스크립트가 root로 실행되는지 확인
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "이 스크립트는 root 권한으로 실행되어야 합니다."
        log_info "다음과 같이 실행하세요: sudo $0"
        exit 1
    fi
}

# 필수 패키지 설치
install_packages() {
    log_info "필수 패키지를 설치합니다..."
    
    # 시스템 업데이트
    apt update
    apt upgrade -y
    
    # 필수 패키지 설치
    apt install -y nginx mysql-server certbot python3-certbot-nginx ufw fail2ban
    apt install -y nodejs npm git curl wget
    
    # libvips 설치 (이미지 처리용)
    apt install -y libvips-dev pkg-config
    
    log_info "필수 패키지 설치 완료"
}

# MySQL 보안 설정
setup_mysql() {
    log_info "MySQL 보안을 설정합니다..."
    
    # MySQL 보안 설정 자동화
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'strong_root_password';"
    mysql -e "DELETE FROM mysql.user WHERE User='';"
    mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -e "DROP DATABASE IF EXISTS test;"
    mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -e "FLUSH PRIVILEGES;"
    
    # 운영환경용 데이터베이스 및 사용자 생성
    mysql -e "CREATE DATABASE IF NOT EXISTS tsboard_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -e "CREATE USER IF NOT EXISTS 'tsboard_prod'@'localhost' IDENTIFIED BY 'production_password_here';"
    mysql -e "GRANT ALL PRIVILEGES ON tsboard_prod.* TO 'tsboard_prod'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
    
    log_info "MySQL 설정 완료"
}

# 방화벽 설정
setup_firewall() {
    log_info "방화벽을 설정합니다..."
    
    # UFW 기본 정책 설정
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    
    # 필요한 포트 허용
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # UFW 활성화
    ufw --force enable
    
    log_info "방화벽 설정 완료"
}

# Fail2Ban 설정
setup_fail2ban() {
    log_info "Fail2Ban을 설정합니다..."
    
    cat > /etc/fail2ban/jail.local << EOF
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
EOF
    
    systemctl enable fail2ban
    systemctl restart fail2ban
    
    log_info "Fail2Ban 설정 완료"
}

# 사용자 계정 생성
create_user() {
    log_info "tsboard 사용자 계정을 생성합니다..."
    
    # tsboard 사용자 생성
    if ! id "tsboard" &>/dev/null; then
        useradd -r -m -s /bin/bash tsboard
        usermod -aG www-data tsboard
    fi
    
    # 디렉토리 생성
    mkdir -p /var/www/tsboard
    mkdir -p /var/www/tsboard/uploads
    mkdir -p /var/log/tsboard
    
    # 권한 설정
    chown -R tsboard:tsboard /var/www/tsboard
    chown -R tsboard:tsboard /var/log/tsboard
    chmod 755 /var/www/tsboard
    chmod 755 /var/www/tsboard/uploads
    
    log_info "사용자 계정 생성 완료"
}

# SSL 인증서 설정
setup_ssl() {
    local domain=$1
    if [ -z "$domain" ]; then
        log_warn "도메인이 지정되지 않았습니다. SSL 설정을 건너뜁니다."
        return
    fi
    
    log_info "SSL 인증서를 설정합니다..."
    
    # Let's Encrypt 인증서 발급
    certbot --nginx -d $domain -d www.$domain --non-interactive --agree-tos --email admin@$domain
    
    log_info "SSL 인증서 설정 완료"
}

# TSBOARD 배포
deploy_tsboard() {
    log_info "TSBOARD를 배포합니다..."
    
    cd /var/www/tsboard
    
    # Git에서 최신 코드 가져오기
    if [ ! -d ".git" ]; then
        git clone https://github.com/hwiery/bulletin-boarad-test.git .
    else
        git pull origin main
    fi
    
    # Node.js 의존성 설치
    npm ci --production
    
    # 운영환경용 설정 파일 복사
    cp tsboard.config.production.ts tsboard.config.ts
    cp env.production.sample .env
    
    log_warn "⚠️ .env 파일을 실제 운영환경 값으로 수정해야 합니다!"
    
    # Vue.js 빌드
    npm run build
    
    # Go 바이너리 컴파일 (Linux용)
    cd goapi.git
    go build -o ../goapi-linux cmd/main.go
    cd ..
    
    # 권한 설정
    chown -R tsboard:tsboard /var/www/tsboard
    chmod +x goapi-linux
    
    log_info "TSBOARD 배포 완료"
}

# Nginx 설정
setup_nginx() {
    local domain=$1
    
    log_info "Nginx를 설정합니다..."
    
    # 기존 default 설정 비활성화
    rm -f /etc/nginx/sites-enabled/default
    
    # TSBOARD Nginx 설정 복사
    cp deployment/nginx.conf /etc/nginx/sites-available/tsboard
    
    # 도메인 설정 (지정된 경우)
    if [ ! -z "$domain" ]; then
        sed -i "s/yourdomain.com/$domain/g" /etc/nginx/sites-available/tsboard
    fi
    
    # 설정 활성화
    ln -sf /etc/nginx/sites-available/tsboard /etc/nginx/sites-enabled/
    
    # Nginx 설정 테스트
    nginx -t
    
    # Nginx 재시작
    systemctl restart nginx
    systemctl enable nginx
    
    log_info "Nginx 설정 완료"
}

# systemd 서비스 설정
setup_service() {
    log_info "systemd 서비스를 설정합니다..."
    
    # 서비스 파일 복사
    cp deployment/systemd/tsboard-api.service /etc/systemd/system/
    
    # systemd 재로드 및 서비스 활성화
    systemctl daemon-reload
    systemctl enable tsboard-api
    systemctl start tsboard-api
    
    log_info "systemd 서비스 설정 완료"
}

# 메인 실행 함수
main() {
    local domain=$1
    
    log_info "🚀 TSBOARD 운영환경 배포를 시작합니다..."
    
    check_root
    install_packages
    setup_mysql
    setup_firewall
    setup_fail2ban
    create_user
    deploy_tsboard
    setup_nginx "$domain"
    setup_service
    setup_ssl "$domain"
    
    log_info "🎉 TSBOARD 배포가 완료되었습니다!"
    log_warn "⚠️ 다음 작업을 수행해야 합니다:"
    echo "1. /var/www/tsboard/.env 파일의 설정값들을 실제 운영환경에 맞게 수정"
    echo "2. MySQL 비밀번호를 강력한 것으로 변경"
    echo "3. JWT_SECRET_KEY를 무작위 강력한 값으로 변경"
    echo "4. 관리자 계정 정보 수정"
    echo "5. 도메인 DNS 설정 확인"
    
    if [ ! -z "$domain" ]; then
        echo "6. https://$domain 에서 사이트 확인"
    fi
}

# 스크립트 실행
main "$1" 