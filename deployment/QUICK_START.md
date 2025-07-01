# ⚡ TSBOARD 빠른 운영환경 배포 가이드

## 🚀 원클릭 배포 (Ubuntu 20.04+)

### 1단계: 서버 준비
```bash
# 서버에 SSH로 접속 후
curl -sSL https://raw.githubusercontent.com/hwiery/bulletin-boarad-test/main/deployment/deploy.sh -o deploy.sh
chmod +x deploy.sh
```

### 2단계: 배포 실행
```bash
# 도메인이 있는 경우 (SSL 자동 설정)
sudo ./deploy.sh yourdomain.com

# 도메인이 없는 경우 (IP 접근)
sudo ./deploy.sh
```

### 3단계: 필수 설정 변경
```bash
# 환경설정 파일 수정
sudo nano /var/www/tsboard/.env
```

**반드시 변경해야 할 항목들:**
- `GOAPI_URL=https://yourdomain.com` (실제 도메인)
- `DB_PASSWORD=강력한비밀번호` 
- `JWT_SECRET_KEY=64자이상의무작위문자열`
- `ADMIN_PASSWORD=관리자비밀번호`
- `ADMIN_ID=admin@yourdomain.com`

### 4단계: 서비스 재시작
```bash
sudo systemctl restart tsboard-api
sudo systemctl restart nginx
```

### 5단계: 접속 확인
- **웹사이트**: https://yourdomain.com
- **관리자**: /admin 경로로 접속

---

## 🔧 수동 설정이 필요한 경우

### MySQL 비밀번호 변경
```bash
# MySQL 접속
sudo mysql

# 비밀번호 변경
ALTER USER 'tsboard_prod'@'localhost' IDENTIFIED BY '새로운강력한비밀번호';
FLUSH PRIVILEGES;
exit
```

### JWT 시크릿 키 생성
```bash
# 무작위 64자 문자열 생성
openssl rand -hex 32
```

### SSL 인증서 수동 발급
```bash
# 도메인이 DNS에 올바르게 설정된 후
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### 관리자 비밀번호 해시 생성
```bash
# 새 비밀번호의 SHA256 해시 생성
echo -n "새비밀번호" | sha256sum
```

---

## ⚠️ 주의사항

1. **방화벽**: 80, 443, SSH 포트만 열려있습니다
2. **백업**: 매일 새벽 2시 자동 백업 실행
3. **모니터링**: 5분마다 시스템 상태 확인
4. **로그**: `/var/log/tsboard/`에서 확인

---

## 🆘 문제 해결

### 서비스 상태 확인
```bash
sudo systemctl status tsboard-api nginx mysql
```

### 로그 확인
```bash
# API 서버 로그
sudo journalctl -u tsboard-api -f

# Nginx 오류 로그
sudo tail -f /var/log/nginx/tsboard_error.log

# 모니터링 로그
sudo tail -f /var/log/tsboard/monitor.log
```

### 서비스 재시작
```bash
sudo systemctl restart tsboard-api
sudo systemctl restart nginx
sudo systemctl restart mysql
```

---

**🎉 배포 완료!** 
더 자세한 설정은 `PRODUCTION_GUIDE.md`를 참조하세요. 