# TestableApp

This app is set up to demonstrate XCTestCase (unit & logic tests) and XCUITestCase (UI tests) patterns. It also includes CI/CD implementation guidance for running tests on GitHub Actions and producing test artifacts.

---

## Table of Contents

- Overview
- XCTest (Unit & Integration) — scenarios and best practices
- XCUITest (UI) — scenarios and best practices
- Test organization and patterns
- Running tests locally
- CI/CD implementation (Jenkins/Fastlane)

---

## Overview

This document lists recommended test scenarios for both XCTest and XCUITest, provides best practices, and gives a reproducible CI configuration so tests run automatically on pull requests and merges.

---

## XCTest (Unit & Integration) — Scenarios

These are example test cases / scenarios you should cover with XCTestCase based tests.

General guidance:
- Follow AAA (Arrange, Act, Assert)
- Use small, focused tests (one logical assertion per test)
- Use dependency injection; replace network/filesystem/database with test doubles
- Name tests descriptively: test_<Unit>_<Condition>_<ExpectedResult>

Example scenarios (with suggested test names):

- ViewModel / Presenter logic
  - test_LoginViewModel_withValidCredentials_emitsSuccess
    - Arrange: Valid username/password injected network mock responds 200
    - Act: call login()
    - Assert: view model publishes success state, token stored

  - test_CounterViewModel_incrementFromZero_resultsOne
    - Arrange: initial value 0
    - Act: call increment()
    - Assert: value == 1

- Networking layer
  - test_APIClient_onServerError_returnsAppropriateError
    - Arrange: network mock returns 500
    - Act: perform request
    - Assert: error type is .serverError

  - test_APIClient_parsesValidJSONResponse_intoModel
    - Arrange: mock response with JSON fixture
    - Act: decode
    - Assert: model fields match fixture

- Input validation
  - test_EmailValidator_withInvalidEmail_returnsFalse
    - Arrange: invalid string
    - Act: validate
    - Assert: returns false

- Performance
  - test_Performance_ExpensiveOperation_runsUnder50ms
    - Use `measure` block

---

## XCUITest (UI) — Scenarios

General guidance:
- Make UI tests deterministic: set initial app state, clear data between runs
- Prefer accessibility identifiers (accessibilityIdentifier) for locating elements
- Keep UI tests at the flow level — core logic belongs in unit tests
- Use test-specific launch arguments/environment to stub network and use deterministic data

UI Test tips:
- Use `XCUIApplication().launchArguments` and `.launchEnvironment` to configure app for tests (mock servers, use in-memory DB)
- Use `addUIInterruptionMonitor` to handle system alerts if needed
- Reset state between tests: delete app data or use fresh simulator boots

---

## Test Organization & Patterns

Suggested structure:
- Tests/
  - UnitTests/
    - AppNameTests.swift
    - Fixtures/
  - UITests/
    - AppNameUITests.swift
    - Helpers/

Test doubles:
- Mocks, Stubs, Spies implemented as classes conforming to protocols
- Use URLProtocol to stub HTTP requests in unit tests
- For UI tests, provide a mock server or use local JSON fixtures injected via launchEnvironment

Common patterns:
- Dependency Injection (constructor or property injection)
- Use feature flags / launch args to enable test-only code paths
- Use `@testable import AppModule` for unit tests when necessary

Naming conventions:
- test_<Unit>_<State>_<ExpectedBehavior>
- Keep test methods short and focused

---

## Running Tests Locally

Using Xcode:
- Open the workspace/project in Xcode
- Select the appropriate scheme (unit tests or UI tests)
- Product → Test (⌘U)

Using xcodebuild (example):
- Run unit tests:
  - xcodebuild test -scheme TestableApp -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.4' -resultBundlePath TestResults/UnitTests.xcresult | xcpretty
- Run UI tests:
  - xcodebuild test -scheme TestableAppUITests -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.4' -resultBundlePath TestResults/UITests.xcresult | xcpretty

Generate JUnit-style reports (using xcpretty):
- xcodebuild test ... | xcpretty -r junit --output test-reports/report.xml

Notes:
- `xcpretty` is helpful for readable output and producing junit/xunit reports used by CI.
- Make sure required simulators are installed locally for the destination OS version.

---

## CI/CD Implementation (Jenkins + Fastlane)

🧱 STEP 0 — What You’ll Have at the End

✔ Jenkins automatically builds your iOS app
✔ Runs XCTest / XCUITest
✔ Signs using Fastlane Match
✔ Uploads to TestFlight
✔ Triggered by GitHub push / PR


**🖥 STEP 1 — Set Up Jenkins on macOS
**

brew install jenkins-lts
brew services start jenkins-lts


Open:
http://localhost:8080

//
If Safari can’t open http://localhost:8080 even after running:
brew services start jenkins-lts
this is a very common Jenkins-on-macOS issue. 
Then
brew services list
ps aux | grep jenkins
jenkins-lts 

//


//

**🔐 Reset Jenkins Username / Password (macOS)
**
brew services stop jenkins-lts
nano ~/.jenkins/config.xml
//


**2️⃣ Install Required Jenkins Plugins
**
From Manage Jenkins → Plugins:

✔ Git
✔ Pipeline
✔ GitHub Integration
✔ Credentials Binding
✔ Workspace Cleanup

**🍎 STEP 2 — Install iOS Dependencies on Jenkins Mac
**
# Xcode

xcode-select --install


# Ruby & Bundler
sudo gem install bundler fastlane

# CocoaPods (if used)

sudo gem install cocoapods

Verify:
fastlane —version

//
**🔹 Step 2: Install Fastlane via Bundler (BEST PRACTICE)
**
cd your-ios-project
nano Gemfile
Paste:

source "https://rubygems.org"

gem “fastlane"

gem install bundler
bundle install
//

xcodebuild -version

**📂 STEP 3 — Prepare iOS Project
**
Create Gemfile:
and paste
source "https://rubygems.org"
gem "fastlane"
gem “cocoapods"


bundle install
bundle exec fastlane init
Manual setup
app_identifier("Bhupesh.TestableApp")

apple_id("*****@gmail.com")

team_id("*******")

**Paste to fastfile:
**
default_platform(:ios)

platform :ios do

  before_all do
    setup_ci
  end

  desc "Run unit and UI tests"
  lane :tests do
    scan(
      scheme: "MyApp",
      clean: true,
      devices: ["iPhone 15"]
    )
  end

  desc "Build app"
  lane :build do
    build_app(
      scheme: "MyApp",
      export_method: "app-store"
    )
  end

  desc "Upload to TestFlight"
  lane :beta do
    match(type: "appstore")
    increment_build_number
    build_app(scheme: "MyApp")
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
end

**🔐 STEP 5 — Code Signing Using Match (CRITICAL)
**

bundle exec fastlane match init

and choose git
Create private repo for certificates.

Jenkins Needs Access to Match Repo

✔ Add SSH key
✔ Store repo password in Jenkins credentials


 On the first run for each environment it will create the provisioning profiles and
[23:34:16]: certificates for you. From then on, it will automatically import the existing profiles.

**STEP 6 — App Store Connect API Key (Recommended)
**

Create API key in App Store Connect.

Store these in Jenkins Credentials:

Key	Type
ASC_KEY_ID	Secret Text
ASC_ISSUER_ID	Secret Text
ASC_KEY_CONTENT	Secret File
STEP 7 — Verify Locally

Run:

bundle exec fastlane tests // It worked 
bundle exec fastlane beta // Check the process of match repo aand how to store

STEP 8 — Create Jenkinsfile (MOST IMPORTANT)
Create Jenkinsfile at repo root:

pipeline {
    agent any

    environment {
        LANG = "en_US.UTF-8"
        LC_ALL = "en_US.UTF-8"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                  bundle install
                  pod install
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh 'bundle exec fastlane tests'
            }
        }

        stage('Build & Upload') {
            steps {
                sh 'bundle exec fastlane beta'
            }
        }
    }

    post {
        success {
            echo "✅ Build uploaded to TestFlight"
        }
        failure {
            echo "❌ Build failed"
        }
    }
}

🔗 STEP 9 — Create Jenkins Pipeline Job


1️⃣ New Item → Pipeline
2️⃣ Choose Pipeline from SCM
3️⃣ Select Git
4️⃣ Add repo URL + credentials
5️⃣ Jenkinsfile path:

🔁 STEP 10 — GitHub Webhook Trigger

GitHub repo → Settings → Webhooks
