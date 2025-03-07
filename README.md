# 🗣️ 소릿글 - Spech To Text

## 📖 프로젝트 소개
- 스피치툴스AI에서 진행한 프로젝트입니다.
- 스피치툴스AI의 자체 인공지능 STT 모델 개발을 위해 만든 ‘소릿글’의 앱 개발자로 참여했습니다.
  
## 🛠️ 개발 환경

### 🔍 프레임워크 및 언어
- Front-end: Flutter (3.29.0), Dart (3.7.0)
- Back-end: Node.js (20.16.0)

### 🔧 개발 도구
- Android Studio: 2024.2.2
- Xcode: 15.2

### 📱 테스트 환경
- iOS 시뮬레이터: iPhone 15 Pro (iOS 17.2)
- iOS 실제 기기: iPhone 11 (iOS 17.3.1) 
- Android 에뮬레이터: API 레벨 34 (Android 14.0)
- Android 실제 기기: API 레벨 28 (Android 9.0)

### 📚 주요 라이브러리 및 API
- permission_handler: 11.2.0
- path_provider: 2.1.2
- web_socket_channel: 2.4.0
- fluttertoast: 8.2.4
- provider: 6.1.1
- audio_streamer: 4.1.1
- device_info_plus: 9.1.2
- share_plus: 9.0.0

### 🔖 버전 및 이슈 관리
- Git: 2.39.3

### 👥 협업 툴
- 커뮤니케이션: Kakaotalk, Email
- 문서 관리: Notion

### ☁️ 서비스 배포 환경
- 백엔드 서버: 자체 WebSocket 서버 (WSS 프로토콜)
- 배포 방식: 자체 호스팅

## ▶️ 프로젝트 실행 방법

### ⬇️ 필수 설치 사항

#### 기본 환경
- Flutter SDK (최소 3.2.3 버전 필요)
- Dart SDK (3.2.3 이상)
- Android Studio (최신 버전)
- Android SDK: Flutter, Dart 플러그인
- Xcode (iOS 개발용, macOS 필요)
- CocoaPods (iOS 의존성 관리, macOS 필요)

#### 필수 의존성 패키지
- flutter: SDK
- cupertino_icons: 1.0.2
- intl: 0.19.0
- isolate: 2.1.1

### ⿻ 프로젝트 클론 및 설정
- 프로젝트 클론
```bash
git clone https://github.com/sorongosdev/flutter_app.git
```
- 의존성 설치
```bash
flutter pub get
```
- iOS 의존성 반영
```bash
pod install
```

### 🌐 개발 서버 실행
```bash
# iOS
flutter build ios

# Android
flutter build apk
```

## 🌿 브랜치 전략
- 중대한 변경 사항이 생길 때 브랜치에서 작업, 그 이외에는 main에서 작업

## 📁 프로젝트 구조
```
EDIT HERE
```

## 🎭 역할

### 🐚 도소라

- Android(Java) >> Flutter 마이그레이션
- 말마디로 음성을 전송하는 VAD 구현
- 음성 크기에 따른 랜덤 파형 표출
- Task별로 작업내용을 노션에 매뉴얼을 문서화하여 전달
- [앱개발 매뉴얼 노션 링크]([https://www.example.com](https://juicy-dill-e52.notion.site/faff81c8570e4c8bb786913993020d41?pvs=4))

## 📅 개발 기간
2024.01 ~ 2024.06 (5개월)

## 기능 설명
`EDIT HERE`

## 💥 트러블 슈팅

### iOS 시뮬레이터 빌드 멈춤 문제
- Xcode에서 아래와 같은 에러 발생시,
  ```
  [FATAL:flutter/display_list/skia/dl_sk_dispatcher.cc(277)] Check failed: false.
  ```
- 프로젝트의 루트 경로에서 아래 명령어로 실행
  ```bash
  flutter run --no-enable-impeller
  ```

### 맥 안드로이드 에뮬레이터에서 마이크 기능 미동작 문제
- 안드로이드 스튜디오에서 안드로이드 에뮬레이터를 실행하면 녹음 기능을 사용할 수 없음
- 터미널에서 호스트 오디오 권한을 주어 실행해야함
- iOS 시뮬레이터에서는 정상 동작함
- 해결 방법
  1. 터미널에서 emulator 관련 환경 변수 추가
  ```bash
  echo 'export PATH=$PATH:/Users/sora/Library/Android/sdk/emulator' >> ~/.zshrc
  
  source ~/.zshrc
  ```
  
  2. 에뮬레이터 리스트업
  ```bash
  emulator -list-avds
  ```
  
  3. 오디오 권한을 허용하여 에뮬레이터 실행 (Pixel4_API34 부분에 에뮬레이터 이름)
     띄어쓰기 없이 이름 설정할 것. 안드로이드 스튜디오의 Device Manager에서 이름 변경 가능
  ```bash
  emulator -avd Pixel4_API34 -qemu -allow-host-audio
  ```
