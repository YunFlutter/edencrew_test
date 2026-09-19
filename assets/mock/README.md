# Naver API mock 응답

2026-09-19에 `docs/NAVER_API.md`의 요청 규격으로 확보한 파서 개발용 응답이다.
인증 헤더, 쿠키, 개인정보는 포함하지 않는다.

| 파일 | 요청 | 인코딩 | 비고 |
| --- | --- | --- | --- |
| `search_autocomplete_samsung.json` | `q=삼성`, `target=stock,ipo,index,marketindicator` | UTF-8 | 검색 자동완성 |
| `realtime_quotes_005930_000660.json` | `query=SERVICE_ITEM:005930,000660` | EUC-KR | 배치 실시간 시세 |
| `stock_metadata_005930.json` | `symbol=005930` | UTF-8 | 삼성전자 메타데이터 |
| `daily_prices_005930_page_1_20240424.html` | `code=005930`, `page=1` | EUC-KR | 2024-04-24에 보존된 실제 HTML 응답 |

일별 시세 endpoint는 2026-09-19 현재 HTTP 410과
`이 페이지는 더 이상 제공되지 않습니다`를 반환한다. 현재의 종료 안내 페이지는
일별 시세 파서 fixture로 쓸 수 없어 Internet Archive에 보존된 Naver의
원본 응답을 저장했다. Wayback 도구 마크업이 삽입되지 않은 원문이며,
10개 거래일과 `lastPage=698`에 해당하는 맨 뒤 페이지 링크를 포함한다.
