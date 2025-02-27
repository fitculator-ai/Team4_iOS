# 🚀 Team4_iOS Tuist 프로젝트 설정 방법

## 1️⃣ 프로젝트 클론
```
git clone https://github.com/fitculator-ai/Team4_iOS.git
cd Team4_iOS
```
2️⃣ Tuist 설치 (최초 1회만 실행)<br/>
둘 중 하나만 선택 brew를 사용한다면 아래 실행
```
curl -Ls https://install.tuist.io | bash
brew install tuist
```
3️⃣ 의존성 패키지 설치
```
tuist install
```
4️⃣ Xcode 프로젝트 생성
```
tuist generate
```
정상적으로 완료됐다면 생성된 fitculator.xcworkspace 실행 후 개발하면 됩니다.

만약 brew나 tuist를 실행할 때 command not found가 나온다면
1. Homebrew가 설치되어 있는지 확인
```
which brew
```
만약 아무 결과도 나오지 않는다면, 아래 명령어로 Homebrew를 설치
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
2. Tuist가 설치된 경로 확인
```
which tuist
```
3. 다시 Tuist 설치(brew로 할거면)
```
brew install tuist
```
4. Tuist가 설치되었지만 command not found가 발생한다면, 환경 변수 문제일 수 있음 명령어 실행 후, tuist가 정상적으로 실행되는지 확인
```
export PATH="$HOME/.tuist/bin:$PATH"
tuist version
```
5. 만약 시뮬레이터를 실행해도 아무 반응이 없을 경우 Cmd + Shift + , -> Info -> Executable을 Fitculator.app으로 설정하면 시뮬레이터가 실행됩니다.
