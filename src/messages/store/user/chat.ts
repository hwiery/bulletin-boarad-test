/**
 * messages/store/user/chat
 *
 * 채팅 관련 텍스트 모음
 */

export const TEXT = [
  /* LANG.KO */ {
    NO_RESPONSE: "서버로부터 응답을 받을 수 없습니다. 관리자에게 문의해 주세요.",
    FAILED_LOAD_HISTORY: "지난 채팅 기록을 가져올 수 없었습니다.",
    LOADED_HISTORY: "이전 채팅 기록을 성공적으로 가져왔습니다.",
    FAILED_ADD_CHAT: "채팅 메시지를 전달하지 못했습니다.",
  },
  /* LANG.EN */ {
    NO_RESPONSE: "Unable to receive a response from the server. Please contact the administrator.",
    FAILED_LOAD_HISTORY: "Failed to load past chat history.",
    LOADED_HISTORY: "Successfully loaded previous chat history.",
    FAILED_ADD_CHAT: "Failed to deliver the chat message.",
  },
  /* LANG.CN */ {
    NO_RESPONSE: "无法收到服务器的响应。请联系管理员。",
    FAILED_LOAD_HISTORY: "加载过去的聊天记录失败。",
    LOADED_HISTORY: "成功加载了以前的聊天记录。",
    FAILED_ADD_CHAT: "发送聊天消息失败。",
  },
]
Object.freeze(TEXT)
