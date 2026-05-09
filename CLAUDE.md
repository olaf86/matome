# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test

Build and run via Xcode (open `Matome.xcodeproj`). CLI equivalents:

```bash
# Build
xcodebuild -project Matome.xcodeproj -scheme Matome -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests
xcodebuild test -project Matome.xcodeproj -scheme Matome -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test (Swift Testing uses -only-testing with the test function name)
xcodebuild test -project Matome.xcodeproj -scheme Matome -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MatomeTests/MatomeTests/example
```

Tests use the **Swift Testing** framework (`@Test`, `#expect`), not XCTest.

## Architecture

**Matome** is an iOS diary/activity-log app that aggregates data from multiple sources (manual logs, photos, HealthKit, GitHub) and generates AI summaries as Markdown reports.

### Layer structure

```
Domain/
  Entities/LogEntry.swift          — SwiftData @Model (the only persisted entity)
  Services/ContextService.swift    — SwiftData CRUD wrapper
  Services/GitHubService.swift     — OAuth via ASWebAuthenticationSession
  Services/GitHubCredentials.swift — Reads GITHUB_CLIENT_ID/SECRET from Info.plist (set via Config.xcconfig)

Presentation/
  ContentView.swift     — TabView root (Source | Log | Report)
  Logs/                 — Manual log entry list with infinite scroll
  Sources/              — Permission/connection management for each data source
  Reports/              — Aggregated metrics view + Markdown report generation sheet
```

### MVVM conventions

- **LogViewModel** uses `@Observable` (Swift Observation framework), injected as `@State` in the view.
- **All other ViewModels** (`ReportViewModel`, `GitHubSectionViewModel`, `MediaPermissionSectionViewModel`, `HealthPermissionSectionViewModel`) use `ObservableObject`/`@Published` and are injected as `@StateObject`.
- Views receive `ModelContext` via `@Environment(\.modelContext)` and pass it down to ViewModels on demand — ViewModels do not hold a persistent context reference except `ContextService`.

### Data flow for logs

`LogView` owns `LogViewModel`, which does cursor-based pagination (page size 10, `fetchOffset`). On scroll-to-last-item `loadMore` is triggered. New entries are inserted optimistically via `insertNewLog(_:)` without a full reload. The view groups entries into `LogSection` (by calendar day) for display.

### Data sources (Sources tab)

Each source is a self-contained `Section` + `SectionViewModel` pair added to the `Form` in `SourceView`:
- **GitHub** — OAuth token stored in `UserDefaults` under `"github_token"`.
- **Media** — `PHPhotoLibrary` authorization; selected asset IDs persisted in `UserDefaults` under `"media_asset_ids"`.
- **Health** — `HKHealthStore` step count; requires `com.apple.developer.healthkit` entitlement (already set).

### Reports (stub state)

`ReportViewModel.updateMetrics()` and `ReportGenerateView.generateSummary()` are placeholder stubs. Real aggregation from SwiftData + external sources and actual AI summary generation have not been implemented yet.

### GitHub credentials

`Config.xcconfig` is the source of `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET`, which are injected into `Info.plist` at build time. The xcconfig is **not** gitignored — treat it as a dev-only credential file and do not commit production secrets there.

### Test helpers

`MatomeTests/Support/SampleLogDataFactory.swift` provides `seedLogs(context:baseDate:days:logsPerDay:)` for constructing in-memory SwiftData test fixtures. Use an in-memory `ModelContainer` in tests to avoid touching the real store.
