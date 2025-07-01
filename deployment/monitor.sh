#!/bin/bash

# TSBOARD 시스템 모니터링 스크립트
# crontab에 등록하여 정기 실행
# 예시: */5 * * * * /var/www/tsboard/deployment/monitor.sh

set -e

# 설정
LOG_FILE="/var/log/tsboard/monitor.log"
ALERT_EMAIL="admin@yourdomain.com"
API_URL="http://localhost:3003/goapi"
WEB_URL="https://yourdomain.com"
DISK_THRESHOLD=85  # 디스크 사용률 임계값 (%)
MEMORY_THRESHOLD=90  # 메모리 사용률 임계값 (%)
CPU_THRESHOLD=80  # CPU 사용률 임계값 (%)

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 로그 함수
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# 알림 전송
send_alert() {
    local subject="$1"
    local message="$2"
    
    if command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "$subject" "$ALERT_EMAIL" 2>/dev/null || true
    fi
    
    log_error "ALERT: $subject - $message"
}

# 서비스 상태 확인
check_services() {
    local failed_services=()
    
    # TSBOARD API 서비스 확인
    if ! systemctl is-active --quiet tsboard-api; then
        failed_services+=("tsboard-api")
        log_error "TSBOARD API 서비스가 실행 중이 아닙니다"
        
        # 자동 재시작 시도
        systemctl restart tsboard-api || true
        sleep 5
        
        if systemctl is-active --quiet tsboard-api; then
            log_info "TSBOARD API 서비스가 자동으로 재시작되었습니다"
        else
            send_alert "TSBOARD API Service Failed" "API 서비스가 실행 중이 아니며 자동 재시작에 실패했습니다."
        fi
    fi
    
    # Nginx 서비스 확인
    if ! systemctl is-active --quiet nginx; then
        failed_services+=("nginx")
        log_error "Nginx 서비스가 실행 중이 아닙니다"
        
        systemctl restart nginx || true
        sleep 3
        
        if systemctl is-active --quiet nginx; then
            log_info "Nginx 서비스가 자동으로 재시작되었습니다"
        else
            send_alert "Nginx Service Failed" "Nginx 서비스가 실행 중이 아니며 자동 재시작에 실패했습니다."
        fi
    fi
    
    # MySQL 서비스 확인
    if ! systemctl is-active --quiet mysql; then
        failed_services+=("mysql")
        log_error "MySQL 서비스가 실행 중이 아닙니다"
        
        systemctl restart mysql || true
        sleep 5
        
        if systemctl is-active --quiet mysql; then
            log_info "MySQL 서비스가 자동으로 재시작되었습니다"
        else
            send_alert "MySQL Service Failed" "MySQL 서비스가 실행 중이 아니며 자동 재시작에 실패했습니다."
        fi
    fi
    
    if [ ${#failed_services[@]} -eq 0 ]; then
        log_info "모든 서비스가 정상 작동 중입니다"
    fi
}

# API 응답 확인
check_api_response() {
    local response_code
    
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL" --max-time 10 || echo "000")
    
    if [ "$response_code" -eq 200 ]; then
        log_info "API 응답 정상 (HTTP $response_code)"
    else
        log_error "API 응답 비정상 (HTTP $response_code)"
        send_alert "API Response Error" "API가 HTTP $response_code를 반환했습니다. URL: $API_URL"
    fi
}

# 웹사이트 접근 확인
check_website() {
    local response_code
    
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$WEB_URL" --max-time 10 || echo "000")
    
    if [ "$response_code" -eq 200 ]; then
        log_info "웹사이트 접근 정상 (HTTP $response_code)"
    else
        log_error "웹사이트 접근 비정상 (HTTP $response_code)"
        send_alert "Website Access Error" "웹사이트가 HTTP $response_code를 반환했습니다. URL: $WEB_URL"
    fi
}

# 디스크 사용량 확인
check_disk_usage() {
    local usage
    local mount_point
    
    while read -r usage mount_point; do
        usage=${usage%\%}
        
        if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
            log_warn "디스크 사용량 높음: $mount_point ($usage%)"
            
            if [ "$usage" -gt 95 ]; then
                send_alert "Critical Disk Usage" "디스크 사용량이 임계치를 초과했습니다: $mount_point ($usage%)"
            fi
        else
            log_info "디스크 사용량 정상: $mount_point ($usage%)"
        fi
    done < <(df -h | awk 'NR>1 {print $5 " " $6}' | grep -E '^[0-9]+%')
}

# 메모리 사용량 확인
check_memory_usage() {
    local memory_usage
    
    memory_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    
    if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
        log_warn "메모리 사용량 높음: ${memory_usage}%"
        send_alert "High Memory Usage" "메모리 사용량이 임계치를 초과했습니다: ${memory_usage}%"
    else
        log_info "메모리 사용량 정상: ${memory_usage}%"
    fi
}

# CPU 사용량 확인
check_cpu_usage() {
    local cpu_usage
    
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    cpu_usage=${cpu_usage%.*}  # 소수점 제거
    
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        log_warn "CPU 사용량 높음: ${cpu_usage}%"
        send_alert "High CPU Usage" "CPU 사용량이 임계치를 초과했습니다: ${cpu_usage}%"
    else
        log_info "CPU 사용량 정상: ${cpu_usage}%"
    fi
}

# 로그 파일 크기 확인
check_log_sizes() {
    local log_dir="/var/log/tsboard"
    local max_size=100  # MB
    
    if [ -d "$log_dir" ]; then
        while IFS= read -r -d '' log_file; do
            local size=$(du -m "$log_file" | cut -f1)
            
            if [ "$size" -gt "$max_size" ]; then
                log_warn "로그 파일 크기 초과: $log_file (${size}MB)"
                
                # 로그 로테이션
                mv "$log_file" "${log_file}.old"
                touch "$log_file"
                chown tsboard:tsboard "$log_file"
                
                log_info "로그 파일이 로테이션되었습니다: $log_file"
            fi
        done < <(find "$log_dir" -name "*.log" -print0)
    fi
}

# SSL 인증서 만료 확인
check_ssl_expiry() {
    if [ -f "/etc/letsencrypt/live/yourdomain.com/fullchain.pem" ]; then
        local expiry_date
        local days_left
        
        expiry_date=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/yourdomain.com/fullchain.pem" | cut -d= -f 2)
        days_left=$(( ($(date -d "$expiry_date" +%s) - $(date +%s)) / 86400 ))
        
        if [ "$days_left" -lt 30 ]; then
            log_warn "SSL 인증서 만료 임박: ${days_left}일 남음"
            send_alert "SSL Certificate Expiring" "SSL 인증서가 ${days_left}일 후 만료됩니다."
        else
            log_info "SSL 인증서 상태 정상: ${days_left}일 남음"
        fi
    fi
}

# 데이터베이스 연결 확인
check_database() {
    if mysql -u tsboard_prod -pproduction_password_here -e "SELECT 1;" >/dev/null 2>&1; then
        log_info "데이터베이스 연결 정상"
    else
        log_error "데이터베이스 연결 실패"
        send_alert "Database Connection Failed" "데이터베이스에 연결할 수 없습니다."
    fi
}

# 시스템 정보 수집
collect_system_info() {
    local uptime_info
    local load_avg
    
    uptime_info=$(uptime | awk '{print $3,$4}' | sed 's/,//')
    load_avg=$(uptime | awk '{print $(NF-2),$(NF-1),$NF}')
    
    log_info "시스템 정보 - Uptime: $uptime_info, Load Average: $load_avg"
}

# 메인 실행 함수
main() {
    # 로그 디렉토리 생성
    mkdir -p "$(dirname "$LOG_FILE")"
    
    log_info "=== TSBOARD 시스템 모니터링 시작 ==="
    
    collect_system_info
    check_services
    check_api_response
    check_website
    check_disk_usage
    check_memory_usage
    check_cpu_usage
    check_log_sizes
    check_ssl_expiry
    check_database
    
    log_info "=== TSBOARD 시스템 모니터링 완료 ==="
}

# 스크립트 실행
main 