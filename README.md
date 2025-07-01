# 🚀 TSBOARD - TypeScript 기반 커뮤니티 게시판

> 현대적이고 확장 가능한 웹 기반 게시판 시스템

## 📋 프로젝트 개요

TSBOARD는 TypeScript와 Vue.js 기반의 현대적인 커뮤니티 게시판 시스템입니다. Go 언어로 작성된 고성능 백엔드와 Vuetify를 활용한 아름다운 프론트엔드를 제공합니다.

## ✨ 주요 기능

- 🎨 **현대적인 UI**: Vuetify 기반의 반응형 디자인
- 🔐 **사용자 인증**: JWT 토큰 기반 안전한 로그인 시스템
- 📝 **게시판 관리**: 다중 게시판 및 카테고리 지원
- 🖼️ **갤러리**: 이미지 업로드 및 갤러리 뷰
- 💬 **댓글 시스템**: 실시간 댓글 작성 및 관리
- 👤 **사용자 관리**: 프로필, 권한, 포인트 시스템
- 🔧 **관리자 패널**: 게시판, 사용자, 콘텐츠 관리
- 📱 **반응형**: 모바일, 태블릿, 데스크탑 지원

## 🛠️ 기술 스택

### 프론트엔드
- **Framework**: Vue.js 3
- **UI Library**: Vuetify 3
- **Language**: TypeScript
- **Build Tool**: Vite
- **State Management**: Pinia

### 백엔드
- **Language**: Go
- **Framework**: Fiber v3
- **Database**: MySQL
- **Authentication**: JWT
- **Image Processing**: libvips

## 🚀 빠른 시작

### 필수 요구사항
- Node.js (v16 이상)
- Go (v1.19 이상)
- MySQL (v8.0 이상)
- libvips (이미지 처리용)

### 설치

1. **저장소 클론**
```bash
git clone https://github.com/hwiery/bulletin-boarad-test.git
cd bulletin-boarad-test
```

2. **의존성 설치**
```bash
# 프론트엔드 의존성
npm install

# macOS에서 libvips 설치
brew install vips pkg-config
```

3. **데이터베이스 설정**
```bash
# MySQL 설치 및 시작
brew install mysql
brew services start mysql

# 데이터베이스 생성
mysql -u root -p
CREATE DATABASE tsboard;
CREATE USER 'tsboard'@'127.0.0.1' IDENTIFIED BY 'tsboard123';
GRANT ALL PRIVILEGES ON tsboard.* TO 'tsboard'@'127.0.0.1';
FLUSH PRIVILEGES;
```

4. **환경 설정**
```bash
# .env 파일이 이미 포함되어 있습니다
# 필요시 데이터베이스 설정을 수정하세요
```

5. **서버 시작**
```bash
# 백엔드 서버 시작 (포트 3003)
./goapi-mac &

# 프론트엔드 서버 시작 (포트 3000)
npm run dev
```

6. **접속 및 로그인**
- 브라우저에서 `http://localhost:3000` 접속
- 관리자 계정: `admin@example.com` / `admin123`

## 📁 프로젝트 구조

```
tsboard/
├── src/                    # Vue.js 프론트엔드 소스
│   ├── components/         # Vue 컴포넌트
│   ├── pages/             # 페이지 컴포넌트
│   ├── store/             # Pinia 스토어
│   ├── router/            # Vue Router 설정
│   └── styles/            # 스타일 파일
├── goapi.git/             # Go 백엔드 소스
│   ├── cmd/               # 메인 애플리케이션
│   ├── internal/          # 내부 패키지
│   └── pkg/               # 공용 패키지
├── goapi-mac              # 컴파일된 Go 바이너리 (macOS)
├── public/                # 정적 파일
└── tsboard.config.ts      # 설정 파일
```

## 🔧 설정

### API 설정
`tsboard.config.ts` 파일에서 API 엔드포인트 및 기타 설정을 수정할 수 있습니다:

```typescript
export const TSBOARD = {
  API: "http://localhost:3003/goapi",
  API_PORT: 3003,
  // ... 기타 설정
}
```

### 데이터베이스 설정
`.env` 파일에서 데이터베이스 연결 정보를 수정할 수 있습니다.

## 📚 사용법

### 게시글 작성
1. 로그인 후 원하는 게시판으로 이동
2. 우측 하단의 ➕ 버튼 클릭
3. 제목, 내용 작성 후 등록

### 관리자 기능
- 관리자로 로그인 후 `/admin` 경로에서 관리자 패널 접근
- 게시판 생성/관리, 사용자 권한 설정, 콘텐츠 관리 가능

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🙏 감사의 말

- 원본 TSBOARD 프로젝트: [sirini/tsboard](https://github.com/sirini/tsboard)
- Vue.js 및 Vuetify 커뮤니티
- Go 및 Fiber 프레임워크 기여자들

## 📞 지원

문제가 발생하거나 질문이 있으시면 [Issues](https://github.com/hwiery/bulletin-boarad-test/issues)에 등록해주세요.

---

⭐ **이 프로젝트가 도움이 되셨다면 스타를 눌러주세요!**
