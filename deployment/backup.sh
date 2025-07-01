#!/bin/bash

# TSBOARD 자동 백업 스크립트
# crontab에 등록하여 정기 실행
# 예시: 0 2 * * * /var/www/tsboard/deployment/backup.sh

set -e

# 설정
BACKUP_DIR="/var/backups/tsboard"
DB_NAME="tsboard_prod"
DB_USER="tsboard_prod"
DB_PASSWORD="production_password_here"  # .env 파일과 동일하게 설정
RETENTION_DAYS=30
DATE=$(date +"%Y%m%d_%H%M%S")

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "${BACKUP_DIR}/backup.log"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "${BACKUP_DIR}/backup.log"
}

# 백업 디렉토리 생성
create_backup_dir() {
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$BACKUP_DIR/db"
    mkdir -p "$BACKUP_DIR/files"
    mkdir -p "$BACKUP_DIR/config"
}

# 데이터베이스 백업
backup_database() {
    log_info "데이터베이스 백업을 시작합니다..."
    
    local backup_file="$BACKUP_DIR/db/tsboard_${DATE}.sql"
    
    mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --add-drop-database \
        --add-drop-table \
        --quick \
        --lock-tables=false > "$backup_file"
    
    # 압축
    gzip "$backup_file"
    
    log_info "데이터베이스 백업 완료: ${backup_file}.gz"
}

# 파일 백업
backup_files() {
    log_info "파일 백업을 시작합니다..."
    
    local backup_file="$BACKUP_DIR/files/uploads_${DATE}.tar.gz"
    
    # 업로드된 파일들 백업
    if [ -d "/var/www/tsboard/uploads" ]; then
        tar -czf "$backup_file" -C /var/www/tsboard uploads/
        log_info "업로드 파일 백업 완료: $backup_file"
    else
        log_info "업로드 디렉토리가 없습니다. 건너뜁니다."
    fi
}

# 설정 파일 백업
backup_config() {
    log_info "설정 파일 백업을 시작합니다..."
    
    local backup_file="$BACKUP_DIR/config/config_${DATE}.tar.gz"
    
    # 중요한 설정 파일들 백업
    tar -czf "$backup_file" \
        -C /var/www/tsboard \
        .env \
        tsboard.config.ts \
        deployment/ \
        --exclude='deployment/*.log' 2>/dev/null || true
    
    # Nginx 설정도 포함
    tar -czf "${backup_file%.tar.gz}_nginx.tar.gz" \
        -C /etc/nginx/sites-available \
        tsboard 2>/dev/null || true
    
    log_info "설정 파일 백업 완료: $backup_file"
}

# 오래된 백업 파일 정리
cleanup_old_backups() {
    log_info "오래된 백업 파일을 정리합니다... (${RETENTION_DAYS}일 이상)"
    
    # 데이터베이스 백업 정리
    find "$BACKUP_DIR/db" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    
    # 파일 백업 정리
    find "$BACKUP_DIR/files" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    
    # 설정 백업 정리
    find "$BACKUP_DIR/config" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    
    # 로그 파일 정리
    find "$BACKUP_DIR" -name "*.log" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    
    log_info "오래된 백업 파일 정리 완료"
}

# 백업 상태 확인
check_backup_status() {
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_info "✅ 백업이 성공적으로 완료되었습니다."
        
        # 백업 크기 정보 기록
        local db_size=$(du -sh "$BACKUP_DIR/db" 2>/dev/null | cut -f1 || echo "N/A")
        local files_size=$(du -sh "$BACKUP_DIR/files" 2>/dev/null | cut -f1 || echo "N/A")
        local config_size=$(du -sh "$BACKUP_DIR/config" 2>/dev/null | cut -f1 || echo "N/A")
        
        log_info "백업 크기 - DB: $db_size, Files: $files_size, Config: $config_size"
    else
        log_error "❌ 백업 중 오류가 발생했습니다. (Exit Code: $exit_code)"
        
        # 이메일 알림 (mailutils가 설치된 경우)
        if command -v mail >/dev/null 2>&1; then
            echo "TSBOARD 백업 실패 - $(date)" | mail -s "TSBOARD Backup Failed" admin@yourdomain.com 2>/dev/null || true
        fi
    fi
    
    return $exit_code
}

# 메인 실행 함수
main() {
    echo "=====================================" | tee -a "${BACKUP_DIR}/backup.log"
    log_info "TSBOARD 백업 시작 - $(date)"
    
    create_backup_dir
    backup_database
    backup_files
    backup_config
    cleanup_old_backups
    
    log_info "TSBOARD 백업 완료 - $(date)"
    echo "=====================================" | tee -a "${BACKUP_DIR}/backup.log"
}

# 트랩을 사용하여 스크립트 종료 시 상태 확인
trap check_backup_status EXIT

# 스크립트 실행
main 