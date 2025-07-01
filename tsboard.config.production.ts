export const IS_DEV = false // 운영환경에서는 false
export const VITE_PORT = 3000
export const DEV_DOMAIN = "http://localhost"
const dev_url = `${DEV_DOMAIN}:${VITE_PORT}`
const production_url = "https://yourdomain.com" // 실제 도메인으로 변경 필요

// TSBOARD 기본 설정값 : 운영환경에 맞게 수정하세요
export const TSBOARD = {
  API: (IS_DEV ? `${DEV_DOMAIN}:3003` : production_url) + "/goapi",
  API_PORT: 3003,
  MAX_UPLOAD_SIZE: 1024 * 1024 * 100, // 100MB
  PREFIX: "",
  SITE: {
    HOME: {
      CATEGORIES: [
        { id: "free", limit: 8 },
        { id: "photo", limit: 4 },
      ],
      COLUMNS: {
        COLS: 6,
        BOARDS: [
          { id: "free", limit: 10 },
        ],
        GALLERY: { id: "photo", limit: 6 },
      },
    },
    MOBILE: { WRITE: "free", PHOTO: "photo" },
    NAME: "게시판", // 실제 사이트명으로 변경
    OAUTH: {
      GOOGLE: false, // 필요시 true로 변경 후 .env.production에 OAuth 설정 추가
      NAVER: false,
      KAKAO: false,
    },
    URL: IS_DEV ? dev_url : production_url,
  },
  VERSION: "v1.0.6",
}

// 운영환경에 맞는 컬러 테마 (필요시 수정)
export const COLOR = {
  HOME: {
    THEME: "light",
    MAIN: "#1976D2", // 브랜드 컬러로 변경
    TOOLBAR: "#1976D2",
    FOOTER: "#F5F5F5",
    BACKGROUND: "#F5F5F5",
  },
  ADMIN: {
    THEME: "light",
    MAIN: "#795548",
    TOOLBAR: "#EFEBE9",
    FOOTER: "#EFEBE9",
    BACKGROUND: "#EFEBE9",
  },
  BLOG: {
    THEME: "dark",
    MAIN: "#121212",
    TOOLBAR: "#121212",
    FOOTER: "#121212",
    BACKGROUND: "#121212",
  },
  GALLERY: {
    THEME: "light",
    MAIN: "#121212",
    TOOLBAR: "#121212",
    FOOTER: "#121212",
    BACKGROUND: "#121212",
  },
  COMMENT: {
    TOOLBAR: { BLOG: "#1c1c1c", HOME: "#f1f1f1", BOARD_WRITER: "#FFF3E0", BLOG_WRITER: "#121212" },
    NAMETAG: { BLOG: "#9E9E9E", HOME: "#616161", BOARD_WRITER: "#EF6C00", BLOG_WRITER: "#525252" },
  },
}

// 브라우저 크기 별 사이즈 정의 (수정 불필요)
export const SCREEN = {
  MOBILE: { WIDTH: 480, COLS: 12 },
  TABLET: { WIDTH: 768, COLS: 6 },
  PC: { WIDTH: 1024, COLS: 4 },
  LARGE: { WIDTH: 1440, COLS: 3 },
}

// EXIF 정보 가공용 상수값들 정의 (수정 금지)
export const EXIF = { APERTURE: 100, EXPOSURE: 1000 }

// 사이트 관리자/책임자 정보 (반드시 실제 정보로 변경)
export const POLICY = { 
  NAME: "관리자", // 실제 관리자 이름으로 변경
  EMAIL: "admin@yourdomain.com" // 실제 관리자 이메일로 변경
}

// 기본 화폐 단위
export const CURRENCY = "krw"

Object.freeze(TSBOARD)
Object.freeze(COLOR)
Object.freeze(SCREEN)
Object.freeze(POLICY) 