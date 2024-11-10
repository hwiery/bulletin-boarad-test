/**
 * messages/components/board/write/board-write-editor-others
 *
 * language pack
 */

export const TEXT = [
  /* LANG.KO */ {
    CHOOSE_CATEGORY: "카테고리를 선택해 주세요.",
    SELECT_ATTACHMENTS: "첨부할 파일들을 선택해 주세요.",
    TITLE_INSERT_IMAGE_UPLOAD: "본문 삽입용 이미지 업로드",
    INFO_INSERT_IMAGE_UPLOAD:
      "본문에 삽입되는 이미지는 자동으로 크기를 줄여서 저장합니다. 원본 크기로 첨부가 필요할 경우 파일 첨부 기능을 이용하세요!",
    SELECT_IMAGES: "본문에 추가할 이미지 파일들을 선택해 주세요.",
    UPLOAD_AND_INSERT: "위 사진들을 업로드하고 본문에 추가하기",
    TITLE_YOUTUBE: "유튜브 URL 추가",
    VIDEO_WIDTH: "비디오 가로(폭) 지정",
    VIDEO_HEIGHT: "비디오 세로(높이) 지정",
    CLOSE: "닫기",
    ADD_TO_CONTENT: "본문에 추가하기",
    TITLE_TABLE: "표 추가하기",
    ROW_COUNT: "행 개수",
    COLUMN_COUNT: "열 개수",
    CHECK_INCLUDE_HEADER: "표 상단에 헤더 영역 포함",
    INVALID_COUNT: "잘못된 개수 지정입니다.",
    TITLE_MANAGE_IMAGE: "기존 이미지를 본문에 추가 혹은 관리",
    CHECK_BEFORE_REMOVE_IMAGE: `정말로 삭제하시겠습니까? 이전에 사용한 적이 없거나 앞으로도 사용할 계획이 없을 경우에만 삭제해 주세요! 
만약 이전 게시글들에 이미 사용하셨다면, 해당 게시글들은 더 이상 이미지가 나타나지 않게 됩니다. 계속 진행하시겠습니까?`,
    CANCEL_REMOVE: "아니요, 삭제하지 않겠습니다",
    CONFIRM_REMOVE: "삭제하기",
    EMPTY_IMAGE_LIST: "이 게시판에 아직 업로드하신 이미지가 없습니다.",
    LOAD_PREV_IMAGE: "이전 이미지들 가져오기",
    REMOVED_IMAGE: "이미지가 정상적으로 삭제되었습니다.",
    TITLE_EXTERNAL_IMAGE: "외부 이미지 URL 추가",
    INVALID_IMAGE_URL: "올바른 이미지 URL 형식이 아닙니다.",
    TITLE_CONFIRM: "확인",
    CHECK_BEFORE_REMOVE:
      "본문 작성란 내부에서 이미 업로드하신 이미지들을 제외하고 나머지 입력 항목들은 모두 초기화됩니다. 계속 진행하시겠습니까?",
    REMOVE_WHEN_CLICK: "클릭하시면 삭제합니다.",
    ADD_TAG: "태그를 입력해 보세요! (space/enter 혹은 , 로 추가)",
    ADD_TAG_TOOLTIP: "이 태그를 추가합니다: ",
    NEW_TAG_TOOLTIP: "새로운 태그입니다: ",
  },
  /* LANG.EN */ {
    CHOOSE_CATEGORY: "Please choose a category.",
    SELECT_ATTACHMENTS: "Please select files to attach.",
    TITLE_INSERT_IMAGE_UPLOAD: "Upload Image for Insertion into Content",
    INFO_INSERT_IMAGE_UPLOAD:
      "Images inserted into the content are automatically resized for storage. Use the file attachment feature if you need to attach images in their original size!",
    SELECT_IMAGES: "Please select image files to add to the content.",
    UPLOAD_AND_INSERT: "Upload and insert the above photos into the content",
    TITLE_YOUTUBE: "Add YouTube URL",
    VIDEO_WIDTH: "Width",
    VIDEO_HEIGHT: "Height",
    CLOSE: "Close",
    ADD_TO_CONTENT: "Add to content",
    TITLE_TABLE: "Add Table",
    ROW_COUNT: "Rows",
    COLUMN_COUNT: "Columns",
    CHECK_INCLUDE_HEADER: "Include a header area at the top of the table",
    INVALID_COUNT: "Invalid number for row/column",
    TITLE_MANAGE_IMAGE: "Add or manage existing images in content",
    CHECK_BEFORE_REMOVE_IMAGE: `Are you sure you want to delete? 
Please delete only if you have never used this image before or have no plans to use it in the future! 
If this image has been used in previous posts, those posts will no longer display the image. Do you wish to proceed?`,
    CANCEL_REMOVE: "No, I will not delete",
    CONFIRM_REMOVE: "Delete",
    EMPTY_IMAGE_LIST: "There are no images uploaded to this board yet.",
    LOAD_PREV_IMAGE: "Load previous images",
    REMOVED_IMAGE: "The image has been successfully deleted.",
    TITLE_EXTERNAL_IMAGE: "Add External Image URL",
    INVALID_IMAGE_URL: "Invalid url of image.",
    TITLE_CONFIRM: "Confirm",
    CHECK_BEFORE_REMOVE:
      "Except for the images you've already uploaded within the content editor, all other inputs will be reset. Do you wish to proceed?",
    REMOVE_WHEN_CLICK: "Click to delete.",
    ADD_TAG: "Try entering a tag! (Add with space/enter or ,)",
    ADD_TAG_TOOLTIP: "Add this tag: ",
    NEW_TAG_TOOLTIP: "This is a new tag: ",
  },
]
Object.freeze(TEXT)
