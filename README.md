# HJMemo

HJMemo는 질문과 답변을 메모하고, 기억 정도에 따라 다음 복습 시각을 자동으로 조정하는 개인 학습용 Rails 웹 애플리케이션입니다.

## 현재 지원하는 기능

- 이메일과 비밀번호를 이용한 회원가입, 로그인, 로그아웃
- 사용자별 주제 생성, 수정, 삭제
- 주제 안의 메모 생성, 수정, 삭제
- 질문과 텍스트 답변 작성
- 답변에 JPEG, PNG, WebP 이미지 첨부
- 답변 이미지 최대 5개, 파일당 최대 5MB 검증
- 복습할 메모 수와 다음 복습 시각 표시
- `다시`, `어려움`, `좋음`, `쉬움` 평가에 따른 복습 일정 계산
- 다른 사용자의 주제와 메모 접근 차단

알림, 공개, 공유, 검색, 통계와 비밀번호 재설정 이메일은 현재 범위에 포함하지 않습니다.

## 기술 구성

- Ruby 4.0.6
- Rails 8.1.3.1
- PostgreSQL
- Devise
- Hotwire(Turbo, Stimulus)
- Tailwind CSS
- Active Storage
- Minitest, Capybara, Selenium

애플리케이션 시간대는 `Seoul`입니다. 데이터베이스의 시각은 UTC 기준으로 저장하고 Rails가 서울 시간으로 변환해 표시합니다.

## 준비물

로컬 컴퓨터에 다음 프로그램이 필요합니다.

- [mise](https://mise.jdx.dev/)
- PostgreSQL
- Chrome: 시스템 테스트 실행 시 필요

현재 프로젝트의 Ruby 버전은 [mise.toml](mise.toml)에 고정되어 있습니다.

## 처음 설치하기

프로젝트 디렉터리로 이동합니다.

```bash
cd ~/Projects/hjmemo
```

mise가 프로젝트에 지정된 Ruby를 설치하도록 합니다.

```bash
mise install
```

의존성을 설치하고 개발용 데이터베이스를 준비합니다.

```bash
mise exec -- bin/setup --skip-server
```

`bin/setup`은 다음 작업을 수행합니다.

- 필요한 Ruby gem 확인 및 설치
- `hjmemo_development`, `hjmemo_test` 데이터베이스 준비
- 아직 적용되지 않은 마이그레이션 실행
- 기존 로그와 임시 파일 정리

PostgreSQL 서버가 실행 중이어야 데이터베이스 준비가 성공합니다.

## 개발 서버 실행하기

```bash
mise exec -- bin/dev
```

브라우저에서 다음 주소로 접속합니다.

```text
http://localhost:3000
```

서버를 종료하려면 서버를 실행한 터미널에서 `Control + C`를 누릅니다.

## 주요 화면

- `/` — 홈과 오늘의 복습 개수
- `/topics` — 주제 관리
- `/review` — 현재 복습할 메모
- `/users/sign_up` — 회원가입
- `/users/sign_in` — 로그인

주제별 메모 주소에는 해당 주제의 ID가 포함되므로 주제 목록에서 이동하는 것이 가장 간단합니다.

## 복습 규칙

새 메모는 생성 직후 복습 대상이 됩니다.

- `다시` — 반복 횟수를 초기화하고 10분 뒤 다시 복습
- 첫 번째 성공 평가 — 1일 뒤 복습
- 두 번째 성공 평가 — 6일 뒤 복습
- 이후 성공 평가 — 이전 간격과 난이도 계수를 이용해 계산

평가 버튼 아래에는 저장하기 전에 예상 간격이 표시됩니다. 실제 계산은 [ReviewScheduler](app/services/review_scheduler.rb)가 담당합니다.

## 이미지 저장

개발 환경의 첨부 이미지는 프로젝트의 `storage/` 디렉터리에 저장됩니다. 테스트 이미지는 `tmp/storage/`에 저장됩니다.

이 방식은 로컬 개발용입니다. 실제 배포에서는 서버 교체 시 이미지가 사라지지 않도록 Amazon S3 또는 Cloudflare R2 같은 영구 객체 저장소를 연결해야 합니다.

## 테스트와 품질 검사

모델과 컨트롤러 테스트를 실행합니다.

```bash
mise exec -- bin/rails test
```

Chrome을 이용해 실제 사용자 흐름과 모바일 화면을 검사합니다.

```bash
mise exec -- bin/rails test:system
```

설정, 코드 스타일, 보안, 모든 테스트를 한 번에 검사합니다.

```bash
mise exec -- bin/ci
```

`bin/ci`에는 다음 검사가 포함됩니다.

- RuboCop 코드 스타일 검사
- Bundler Audit gem 취약점 검사
- Importmap 패키지 취약점 검사
- Brakeman Rails 보안 검사
- Minitest 모델·컨트롤러 테스트
- 데이터베이스 seed 검사
- Capybara·Selenium 시스템 테스트

## 주요 코드 위치

- `app/models/` — 사용자, 주제, 메모 데이터 규칙
- `app/controllers/` — 요청 처리와 사용자별 접근 제한
- `app/services/review_scheduler.rb` — 복습 간격 계산
- `app/views/` — 화면 HTML과 Tailwind CSS 클래스
- `test/` — 자동 테스트
- `db/migrate/` — 데이터베이스 구조 변경 기록

## 로컬 MVP 이후 작업

실제 웹서비스로 배포하려면 다음 작업이 추가로 필요합니다.

- 운영 서버와 도메인 설정
- 운영용 PostgreSQL 연결과 백업
- S3 호환 이미지 저장소 연결
- 운영 비밀값과 HTTPS 설정
- 이메일 발송 서비스 연결 후 비밀번호 재설정 활성화
- 운영 오류 기록과 모니터링
