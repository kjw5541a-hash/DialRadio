# CHANGELOG

## v1.0 (2026-08-12)

첫 배포 버전. PWA 형태로 GitHub Pages 배포: https://kjw5541a-hash.github.io/DialRadio/

### 기능
- Radio Browser API 연동 (3서버 라운드로빈 fallback), 채널 검색/국가별 필터
- 즐겨찾기 (localStorage 저장)
- 전체/즐겨찾기 탭
- 채널 재생/일시정지, 실제 audio 이벤트 기반 상태 동기화
  - 연결 중 "...", 재생 중 "스트리밍중", 실패 시 "접속불가"
- 재생 중 채널 깊이(오목 그림자)로 표시, 하단 플레이어 바는 별도 배경색으로 구분
- 재생/정지 아이콘 단일 SVG 토글, 흰색 단색
- 뉴모피즘 UI 전면 적용
- 채널 리스트만 스크롤, 헤더/컨트롤 고정
- radio.png 기반 앱 아이콘 (icons/icon-192.png, icon-512.png)
- 서비스워커 캐시 자동 버전 관리 (pre-commit 훅이 커밋마다 sw.js VERSION 갱신 → 캐시 무효화)

### 미착수 (다음 후보)
- Phase 2: 아날로그 다이얼 스킨
- PlayerView/FavoritesView 분리된 화면
- README / DoD 문서화
