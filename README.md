# TestableApp

This app is set up to demonstrate XCTestCase (unit & logic tests) and XCUITestCase (UI tests) patterns. It also includes CI/CD implementation guidance for running tests on GitHub Actions and producing test artifacts.

---

## Table of Contents

- Overview
- XCTest (Unit & Integration) — scenarios and best practices
- XCUITest (UI) — scenarios and best practices
- Test organization and patterns
- Running tests locally
- CI/CD implementation (GitHub Actions)
- Advanced topics & notes

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

- Persistence (UserDefaults, CoreData, File)
  - test_UserDefaultsStore_savesAndRetrievesValue
    - Arrange: in-memory user defaults or cleared sandbox
    - Act: save value
    - Assert: retrieved value equals saved

- Input validation
  - test_EmailValidator_withInvalidEmail_returnsFalse
    - Arrange: invalid string
    - Act: validate
    - Assert: returns false

- Edge cases & error handling
  - test_FileLoader_whenFileMissing_throwsNotFoundError
  - test_ConcurrentAccess_toSharedResource_remainsThreadSafe

- Async / concurrency (Combine / async-await)
  - test_AsyncFetcher_returnsDataWithinTimeout
    - Use `XCTestExpectation` or `async` tests with `await`

- Performance
  - test_Performance_ExpensiveOperation_runsUnder50ms
    - Use `measure` block

- Snapshot testing (if used)
  - test_LoginView_snapshot_matchesGolden
    - Use third-party snapshot frameworks (e.g. iOSSnapshotTestCase, SnapshotTesting)

Fixtures and test data:
- Keep JSON fixtures under Tests/Fixtures
- Use builder/factory helpers to create models for tests

---

## XCUITest (UI) — Scenarios

General guidance:
- Make UI tests deterministic: set initial app state, clear data between runs
- Prefer accessibility identifiers (accessibilityIdentifier) for locating elements
- Keep UI tests at the flow level — core logic belongs in unit tests
- Use test-specific launch arguments/environment to stub network and use deterministic data

Example scenarios (with suggested test names):

- App Launch & Onboarding
  - test_AppLaunch_showsWelcomeScreen
    - Start app with onboarding not completed
    - Assert welcome screen elements exist

  - test_Onboarding_complete_proceedsToMainScreen

- Login flow
  - test_LoginFlow_withValidCredentials_entersMainScreen
    - Launch with network stub that returns success
    - Fill username/password and tap Sign In
    - Assert main screen visible

  - test_LoginFlow_withInvalidCredentials_showsErrorAlert

- Navigation flows
  - test_Navigation_openSettings_andBack
    - Tap through tabs and ensure correct screens are displayed

- Form input and validation
  - test_ProfileForm_showsValidationErrorsForEmptyFields

- Deep linking
  - test_DeepLink_opensSpecificDetailScreen
    - Launch the app with a deep link argument

- Background/Foreground
  - test_AppHandlesBackgroundAndForegroundWithoutLosingState

- Orientation & Layout
  - test_MainScreen_layoutStableOnRotation

- Accessibility
  - test_MainScreen_elements_haveAccessibilityLabels
    - Ensure critical UI elements have accessibility identifiers and labels

- Permissions and System Alerts
  - test_PermissionsFlow_allowsUserToGrantLocation
    - Use simulator permissions commands / launch arguments to pre-grant or deny as needed

- Performance & Launch Time
  - test_AppLaunch_performsUnderThreshold
    - Measure launch time with `measure(metrics:)` where appropriate

- Screenshot & Attachment
  - Capture screenshots at important steps (useful as test artifacts in CI)

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

## CI/CD Implementation (GitHub Actions)

This section provides an example GitHub Actions workflow to run unit and UI tests on macOS runners and upload test artifacts (xcresult and junit).

Create `.github/workflows/ci.yml` with content like:

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: macos-latest
    strategy:
      matrix:
        xcode: [ "14.3" ] # adjust per needs; GitHub macOS runner chooses the latest matching Xcode
        simulator: [ "iPhone 14" ]
        os_version: [ "16.4" ]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Ruby (for xcpretty if needed)
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.x

      - name: Install xcpretty
        run: gem install xcpretty

      - name: Install dependencies (CocoaPods / Carthage / SwiftPM)
        run: |
          # Example for CocoaPods:
          if [ -f Podfile ]; then
            sudo gem install cocoapods
            pod install --repo-update
          fi
          # Add other package managers as needed

      - name: Boot simulator
        run: |
          xcrun simctl boot "${{ matrix.simulator }}"
          xcrun simctl list

      - name: Run unit tests
        run: |
          xcodebuild test \
            -workspace TestableApp.xcworkspace \
            -scheme "TestableApp" \
            -destination "platform=iOS Simulator,name=${{ matrix.simulator }},OS=${{ matrix.os_version }}" \
            -resultBundlePath TestResults/UnitTests.xcresult | xcpretty -r junit --output TestResults/unit-junit.xml
        continue-on-error: false

      - name: Run UI tests
        run: |
          xcodebuild test \
            -workspace TestableApp.xcworkspace \
            -scheme "TestableAppUITests" \
            -destination "platform=iOS Simulator,name=${{ matrix.simulator }},OS=${{ matrix.os_version }}" \
            -resultBundlePath TestResults/UITests.xcresult | xcpretty -r junit --output TestResults/ui-junit.xml
        continue-on-error: false

      - name: Upload xcresult (Unit)
        uses: actions/upload-artifact@v4
        with:
          name: unit-xcresult
          path: TestResults/UnitTests.xcresult

      - name: Upload xcresult (UI)
        uses: actions/upload-artifact@v4
        with:
          name: ui-xcresult
          path: TestResults/UITests.xcresult

      - name: Upload junit reports
        uses: actions/upload-artifact@v4
        with:
          name: junit-reports
          path: TestResults/*.xml
```

Notes and best practices for CI:
- Use macOS runners since iOS builds need Xcode.
- Matrix testing helps cover multiple simulator types and OS versions — but be mindful of time/cost.
- Use caching for dependencies (CocoaPods/SwiftPM) to speed up builds.
- Upload `xcresult` bundles as artifacts so they can be inspected after failure.
- Use `xcpretty` to produce junit XML for test reporting in CI.
- Optionally, integrate with Codecov/test coverage uploading or a test-reporting GitHub app.

Code signing for shipping/adhoc builds:
- For running unit and UI tests on simulator, code signing is typically not required.
- If you need to run on physical devices or archive, store certificates and provisioning profiles as GitHub Secrets and use actions like `apple-actions/import-codesign-certs` to install them securely.

Fastlane integration (optional):
- Use Fastlane lanes to standardize build + test + upload steps.
- Example lane in `Fastfile`:
```ruby
lane :ci_tests do
  run_tests(
    workspace: "TestableApp.xcworkspace",
    scheme: "TestableApp",
    devices: ["iPhone 14"],
    output_directory: "fastlane/test_output",
    output_types: "junit",
  )
end
```

---

## Test Reporting & Flaky Tests

- Mark flaky tests as skipped or add retries only after investigating root cause.
- Capture logs, screen recordings, and screenshots from UI tests and upload as CI artifacts.
- Use `xcodebuild`'s `-resultBundlePath` to produce `.xcresult`, which can be opened locally with Xcode for detailed failure information.
- Consider integrating test analytics or flakiness tracking to prioritize fixes.

---

## Advanced Topics

- Headless simulators and parallel test execution using multiple simulators (requires additional orchestration)
- Running tests on real devices via services (e.g., Bitrise, BrowserStack, Firebase Test Lab—note: these services may require additional config)
- Using test-specific mocks and local servers to emulate network conditions (latency, errors)
- Security: never commit secrets (certs, profiles, API keys); use GitHub Secrets

---

## Summary

This repository is configured to demonstrate:
- Clear XCTest and XCUITest scenarios
- Best practices for organizing tests and test doubles
- A reproducible CI workflow using GitHub Actions that runs unit and UI tests on macOS runners, uploads xcresult bundles, and provides junit reports

