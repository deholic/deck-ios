# AGENTS.md

Project guidelines for Swift/SwiftUI using Clean Swift and Swift Package Manager (SPM).

## Stack
- Language: Swift
- UI: SwiftUI
- Architecture: Clean Swift (VIP)
- Build/Deps: Swift Package Manager

## Architecture (Clean Swift / VIP)
- Each feature uses VIP modules: `Interactor`, `Presenter`, `Worker`, `View` (SwiftUI).
- Models: `Request`, `Response`, `ViewModel` live near the feature.
- Keep Interactors pure and testable; push I/O into Workers.
- Presenter maps Response to ViewModel; Views render only ViewModel.
- Routing (if needed) is handled via SwiftUI navigation or a dedicated Router type.
- Follow SOLID principles in all layers.
- Swift 6 strict concurrency rules must be satisfied across all code.

## Project Structure (suggested)
- `Sources/App`: App entry, root composition.
- `Sources/Features/<Feature>`: Feature modules (VIP types).
- `Sources/Shared`: Reusable UI, extensions, utilities.
- `Tests`: Unit tests per module.

## SwiftUI Conventions
- Views are value types; avoid side effects in body.
- Prefer `@StateObject` for owned view models and `@ObservedObject` for injected ones.
- Use `Task {}` or `.task {}` for async work; keep data fetching in Interactors/Workers.
- Keep view models immutable when possible; update via Interactor outputs.

## SPM Conventions
- Prefer small, focused targets.
- Use `testTarget` alongside each feature target.
- Keep `Package.swift` minimal; avoid ad-hoc scripts.

## Naming
- Feature folder names in UpperCamelCase.
- Types: `FeatureInteractor`, `FeaturePresenter`, `FeatureWorker`, `FeatureView`.
- Tests: `FeatureInteractorTests`, etc.

## Testing
- Unit test Interactors, Presenters, and Workers.
- Use mocks/spies for VIP boundaries.
- Keep UI tests minimal; prefer snapshot tests if needed.

## Collaboration
- When creating PR bodies, use valid Markdown and avoid malformed line breaks.
- Follow the git-flow branch strategy.
- For new features, branch off from develop using the format `feature/{feature-name}`.
