# PinBoard Teaching Plan

## Overview

Build a Pinterest-style photo feed app from scratch using UIKit, MVVM, and Coordinators. The project uses the Unsplash API as a real data source and demonstrates production-level iOS architecture patterns.

**Learner profile**: Experienced engineer who knows UIKit. Minimal scaffolding — learner does almost all work.

**Format**: 14 exercises in bottom-up build order. Each exercise is feature-scoped (touches multiple files). Each step within an exercise is a logical change that leaves the project buildable. Tests are integrated into each exercise. A complete solution is provided per step in a separate folder.

**Tooling**: Learner uses Xcode. AI uses `xcodegen generate` and `xcodebuild test` to verify builds and tests pass.

**Git**: One commit per exercise with a suggested commit message.

---

## Topics → Exercises Map

| # | Topic | Exercise | Key Concepts |
|---|-------|----------|-------------|
| 1 | Project Setup & Build Tools | Project Scaffold & Design System | XcodeGen, UIKit lifecycle, asset catalogs, semantic tokens |
| 2 | Protocol-Oriented Networking | Networking Layer | Protocol design, URLSession, async/await, generics, error types |
| 3 | Data Modeling | Data Models & JSON Fixtures | Codable, CodingKeys, nested decoding, test fixtures |
| 4 | Navigation Architecture | Coordinator Pattern & DI Container | Coordinator protocol, child management, composition root |
| 5 | MVVM & State Machines | Home Feed Service & ViewModel | Service layer, FeedState enum, ViewModel outputs, mocking |
| 6 | Collection Views | Home Feed UI | CompositionalLayout, DiffableDataSource, custom cells, delegation |
| 7 | Image Loading | Nuke Integration & Caching | SPM, Nuke, prefetching, caching protocol |
| 8 | Pagination | Infinite Scroll & Pull-to-Refresh | State machine extensions, loading indicators, scroll detection |
| 9 | Feature Composition | Pin Detail (Full Vertical Slice) | Applying all patterns to a new feature end-to-end |
| 10 | Tab Navigation | Tab Bar & Coordinator Hierarchy | UITabBarController, multi-coordinator wiring |
| 11 | Reactive Bindings | Combine Integration | @Published, sink, AnyCancellable, replacing closures |
| 12 | UX Polish | State & Error Handling | Empty states, inline errors, cell failure placeholders |
| 13 | Deep Linking | URL Routing & Scoped DI | URL schemes, route parsing, scoped DI containers |
| 14 | Testing Modernization | Swift Testing Migration | @Suite, @Test, #expect, XCTest coexistence |

---

## Exercise Details

---

### E1: Project Scaffold & Design System

**Topic**: Project Setup & Build Tools

**Prerequisites**: Xcode installed, `brew install xcodegen`

**Problem**: You're starting a new iOS app called PinBoard. Set up the project with XcodeGen (not Xcode's GUI), create the app lifecycle files, and establish a design system with semantic color tokens and typography that support light/dark mode.

**Solution**: A `project.yml` that generates a working Xcode project. AppDelegate/SceneDelegate that launch a window with a themed background. Color and font enums backed by asset catalog colors.

**Steps**:

1. **Create project.yml and directory structure** — Define an iOS app target (PinBoard, iOS 16+, Swift 5.9), a test target (PinBoardTests), and the folder structure (`App/`, `Features/`, `Core/`, `DesignSystem/`, `Resources/`). Run `xcodegen generate` and verify it opens in Xcode.

2. **Create AppDelegate and SceneDelegate** — Minimal app lifecycle. SceneDelegate creates a UIWindow with a UINavigationController as root. App should launch showing an empty themed screen.

3. **Create the design system** — Add asset catalog color sets (Primary, Secondary, Background, Surface, OnSurface, OnSurfaceSecondary, Error, Divider) with light/dark variants. Create `AppColors` enum with static properties. Create `AppFonts` enum using `UIFont.preferredFont(forTextStyle:)` for heading, subheading, body, caption, label.

**Success Criteria**:
- *Minimal*: App builds, launches, shows empty screen with correct background color
- *Extended*: All color tokens defined with light/dark variants, fonts use Dynamic Type

**Tests**: None (visual verification only)

**Commit**: `feat: scaffold project with XcodeGen and design system`

---

### E2: Networking Layer

**Topic**: Protocol-Oriented Networking

**Prerequisites**: E1

**Problem**: Build a protocol-oriented networking layer that constructs URLs from endpoint definitions, makes authenticated requests to the Unsplash API, and handles errors. Design it so every piece is testable in isolation.

**Solution**: An `Endpoint` protocol that describes API calls declaratively. An `APIClient` that takes any Endpoint, builds a URLRequest, and decodes the response generically. A `MockURLProtocol` for testing real URLSession behavior without the network. A `MockAPIClient` for use in higher-layer tests.

**Steps**:

1. **Define Endpoint protocol and APIError** — `Endpoint` has `path`, `method`, `queryItems`, and can build a `URLRequest` given a base URL and access key. `APIError` enum covers httpError, decodingError, networkError, unknown.

2. **Implement Unsplash endpoints** — `UnsplashEndpoint` enum with cases `.photos(page: Int)` and `.photo(id: String)`. Each case provides the correct path and query items per the Unsplash API.

3. **Create APIClient with protocol** — `APIClientProtocol` with `func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T`. `APIClient` implements it using URLSession, injecting the auth header (`Client-ID <key>`).

4. **Add Secrets** — Create `Secrets.swift` (gitignored) and `Secrets.example.swift` with the access key.

5. **Write tests** — `UnsplashEndpointsTests`: verify paths, query items, HTTP methods. `APIClientTests` (XCTest, URLProtocol stubbing): test success decoding, HTTP errors, invalid JSON, network errors, auth header injection. Create `MockURLProtocol` and `MockAPIClient`.

**Success Criteria**:
- *Minimal*: All endpoint tests pass, APIClient compiles
- *Extended*: APIClient integration tests pass with MockURLProtocol, auth header verified

**Tests**: UnsplashEndpointsTests, APIClientTests

**Commit**: `feat: add protocol-oriented networking layer with tests`

---

### E3: Data Models & JSON Fixtures

**Topic**: Data Modeling

**Prerequisites**: E2

**Problem**: Create Decodable models for the Unsplash API responses. Use real API responses as test fixtures to ensure models decode correctly and handle optional fields gracefully.

**Solution**: `UnsplashPhoto` and `UnsplashUser` structs with CodingKeys for snake_case mapping. JSON fixture files with sanitized real API responses. Tests that decode fixtures and verify every field.

**Steps**:

1. **Create UnsplashPhoto and UnsplashUser** — Model all fields from the API: id, description (optional), urls (nested object with raw/full/regular/small/thumb), width, height, likes, user, created_at, exif (optional, detail only), location (optional). UnsplashUser: name, username, profile image URLs.

2. **Create JSON fixtures** — Add `photos_page1.json` (array of 3-5 photo objects) and `photo_detail.json` (single photo with exif/location) to `PinBoardTests/Fixtures/`. Create `Fixtures.swift` helper with `loadFixture(_:)` for loading fixture data from the test bundle.

3. **Write decoding tests** — `ModelDecodingTests`: decode both fixtures, verify all fields including optionals, nested URLs, user data, exif when present and when absent.

**Success Criteria**:
- *Minimal*: Models decode from fixtures without errors
- *Extended*: All fields verified including optionals, edge cases (nil description, nil exif)

**Tests**: ModelDecodingTests

**Commit**: `feat: add Unsplash data models with JSON fixture tests`

---

### E4: Coordinator Pattern & Dependency Injection

**Topic**: Navigation Architecture

**Prerequisites**: E1

**Problem**: Implement the Coordinator pattern to manage navigation outside of view controllers. Create a root DI container (composition root) that owns all shared services and a root coordinator that manages the app's main flow.

**Solution**: A `Coordinator` protocol with `start()`, `childCoordinators` array, and helper methods for adding/removing children. `AppDependencyContainer` as the composition root owning the APIClient. `AppCoordinator` that sets the window's root and manages children.

**Steps**:

1. **Define the Coordinator protocol** — `start()` method, `childCoordinators` array, `navigationController` property. Add `addChild(_:)` and `removeChild(_:)` helper methods.

2. **Create AppDependencyContainer** — Composition root that creates and owns the `APIClient` (using `Secrets.unsplashAccessKey`). Factory methods for creating feature-level dependencies.

3. **Create AppCoordinator** — Takes a UIWindow, navigation controller, and container. `start()` sets the window's rootViewController and makes it key/visible. (For now, it just shows an empty nav controller — features come later.)

4. **Wire SceneDelegate** — SceneDelegate creates the container and coordinator, calls `start()`.

5. **Write tests** — `AppCoordinatorTests`: verify `start()` sets window root, creates proper hierarchy.

**Success Criteria**:
- *Minimal*: App launches via coordinator chain, tests pass
- *Extended*: Clean child coordinator add/remove lifecycle

**Tests**: AppCoordinatorTests

**Commit**: `feat: add coordinator pattern and DI container`

---

### E5: Home Feed Service & ViewModel

**Topic**: MVVM & State Machines

**Prerequisites**: E2, E3, E4

**Problem**: Build the business logic for the home feed. The service fetches photos from the API. The ViewModel manages a state machine (idle → loading → loaded/error) and transforms raw models into display-ready view models. Design everything to be testable with mocks.

**Solution**: `HomeFeedService` fetching from the `.photos(page:)` endpoint. `PhotoCellViewModel` as a display-ready struct. `HomeFeedViewModel` with a `FeedState` enum driving all outputs via closures. Mock service for VM testing.

**Steps**:

1. **Create HomeFeedService** — Protocol (`HomeFeedServiceProtocol`) and implementation. `fetchPhotos(page:)` calls `apiClient.request` with the photos endpoint. Returns `[UnsplashPhoto]`.

2. **Create PhotoCellViewModel** — Display-ready struct with `id`, `imageURL`, `title`, `authorName`, `aspectRatio` (CGFloat), `likesText` (formatted string). Factory method `init(photo: UnsplashPhoto)` that transforms the model. Formatting: 0 → "No likes yet", 1 → "1 like", 500 → "500 likes", 14500 → "14.5K likes".

3. **Create HomeFeedViewModel** — FeedState enum: `.idle`, `.loading`, `.loaded(hasMore: Bool)`, `.error(String)`. Input methods: `viewDidLoad()`, `didPullToRefresh()`. Output closures: `onStateChanged`, `onPhotosUpdated`. On viewDidLoad: transition idle → loading, call service, on success → `.loaded(hasMore:)` with cell view models, on error → `.error(message)`.

4. **Write tests** — Create `MockHomeFeedService`. `HomeFeedViewModelTests`: all state transitions (load success, load failure, empty response). `HomeFeedServiceTests`: correct endpoint called, response mapped, error propagated. `PhotoCellViewModelTests`: likes formatting, aspect ratio, nil description fallback.

**Success Criteria**:
- *Minimal*: VM transitions through states correctly, all tests pass
- *Extended*: Edge cases covered (empty response → hasMore false, nil descriptions, large like counts)

**Tests**: HomeFeedViewModelTests, HomeFeedServiceTests, PhotoCellViewModelTests

**Commit**: `feat: add home feed service and viewmodel with state machine`

---

### E6: Home Feed UI

**Topic**: Collection Views

**Prerequisites**: E5

**Problem**: Build the Home Feed screen. Start with a basic collection view showing text cells, then progressively upgrade to a custom photo cell, diffable data source, and a waterfall compositional layout. Wire it into the app via a coordinator.

**Solution**: `HomeFeedViewController` with a compositional layout waterfall grid, diffable data source, and a custom `PhotoCell`. `HomeFeedCoordinator` that creates the VC and implements `HomeFeedDelegate` for navigation events.

**Steps**:

1. **Basic VC with collection view** — `HomeFeedViewController` with a `UICollectionView` using a simple flow layout. Use a basic `UICollectionViewCell` registration that just shows the photo title in a label. Wire to ViewModel: on `onPhotosUpdated`, reload with `reloadData()`. On `onStateChanged`, start/stop a `UIActivityIndicatorView`.

2. **Custom PhotoCell** — Replace the basic cell with `PhotoCell`: a `UICollectionViewCell` subclass with a `UIImageView` (fills the cell) and an overlay label for the title. `configure(with: PhotoCellViewModel)` sets the title. Image loading comes in E7 (for now, use a placeholder color based on aspect ratio). Implement `prepareForReuse()`.

3. **Diffable data source** — Replace `reloadData()` with `UICollectionViewDiffableDataSource<Section, String>`. Section enum with `.main`. On `onPhotosUpdated`, build a snapshot from cell view model IDs and apply it.

4. **Waterfall compositional layout** — Create `WaterfallLayout` that builds a `UICollectionViewCompositionalLayout` with 2-column waterfall layout. Item heights calculated from aspect ratios. 8pt spacing, 8pt section insets.

5. **HomeFeedCoordinator and delegate** — `HomeFeedDelegate` protocol with `homeFeedDidSelectPhoto(id:)`. `HomeFeedCoordinator` creates the VM, VC, and sets itself as delegate. Wire `didSelectItemAt` → delegate call. For now, `didSelectPhoto` just prints the ID.

6. **Wire into navigation** — Update `AppCoordinator.start()` to create `HomeFeedCoordinator` as a child and start it. The home feed is now the app's initial screen.

7. **Write tests** — `HomeFeedCoordinatorTests`: verify start pushes HomeFeedVC. Create `MockHomeFeedDelegate` to verify delegate calls.

**Success Criteria**:
- *Minimal*: App shows a waterfall grid of photo titles with colored placeholder cells from real API data
- *Extended*: Smooth diffable data source animations, proper cell reuse, coordinator tests pass

**Tests**: HomeFeedCoordinatorTests

**Commit**: `feat: add home feed UI with waterfall layout and diffable data source`

---

### E7: Image Loading & Caching

**Topic**: Image Loading

**Prerequisites**: E6

**Problem**: Photos currently show placeholder colors. Integrate the Nuke library to load real images, add prefetching for smooth scrolling, and create a caching protocol that abstracts Nuke's implementation.

**Solution**: Nuke added via SPM. `PhotoCell` uses `NukeExtensions.loadImage` for image loading with automatic cancellation. Prefetching via `UICollectionViewDataSourcePrefetching` + Nuke's `ImagePrefetcher`. `ImageCaching` protocol wrapping Nuke's cache.

**Steps**:

1. **Add Nuke as SPM dependency** — Update `project.yml` to add Nuke (github.com/kean/Nuke, from 12.0.0). Regenerate project. Verify import works.

2. **Load images in PhotoCell** — In `configure()`, use `NukeExtensions.loadImage(with: url, into: imageView)`. This handles cancellation on reuse automatically. Set `contentMode = .scaleAspectFill` and `clipsToBounds = true`.

3. **Add prefetching** — Make `HomeFeedViewController` conform to `UICollectionViewDataSourcePrefetching`. Create an `ImagePrefetcher` instance. In `prefetchItemsAt`, start prefetching image URLs. In `cancelPrefetchingForItemsAt`, cancel them.

4. **Create ImageCaching protocol** — `ImageCaching` protocol with `cachedImage(for:)`, `store(_:for:)`, `removeAll()`. `NukeImageCache` implementation wrapping `ImagePipeline.cache`. Add `imageCache` property to `AppDependencyContainer`.

5. **Write tests** — `ImageCachingTests`: store and retrieve, removeAll clears, miss returns nil.

**Success Criteria**:
- *Minimal*: Real photos load in the grid, caching tests pass
- *Extended*: Prefetching works (smooth scrolling), cache protocol tested

**Tests**: ImageCachingTests

**Commit**: `feat: integrate Nuke for image loading with caching protocol`

---

### E8: Pagination

**Topic**: Pagination

**Prerequisites**: E6, E7

**Problem**: The feed only shows the first page of photos. Add infinite scroll pagination — when the user scrolls near the bottom, load the next page and append results. Add a loading footer spinner and pull-to-refresh.

**Solution**: Extend `HomeFeedViewModel` with `loadNextPage()` and a `.loadingMore` state. The VC detects scroll position via `willDisplay` and triggers the next page. A `LoadingFooterView` shows during loads. Pull-to-refresh resets to page 1.

**Steps**:

1. **Extend the ViewModel state machine** — Add `.loadingMore` state to FeedState. Add `loadNextPage()`: only fires from `.loaded(hasMore: true)`, transitions to `.loadingMore`, increments page, fetches, appends results. If fewer items than page size → `hasMore = false`. Add `didPullToRefresh()`: resets page to 1, clears data, transitions to `.loading`.

2. **Create LoadingFooterView** — Reusable `UICollectionReusableView` subclass with a centered `UIActivityIndicatorView`. Register as supplementary view (section footer) in the collection view.

3. **Wire scroll-triggered pagination** — In the diffable data source's `willDisplaySupplementaryView` or in `collectionView(_:willDisplay:forItemAt:)`, check if near the last item. If so and state is `.loaded(hasMore: true)`, call `viewModel.loadNextPage()`. Update snapshot to append new items (not replace).

4. **Add pull-to-refresh** — Add a `UIRefreshControl` to the collection view. On `valueChanged`, call `viewModel.didPullToRefresh()`. End refreshing when state changes from `.loading`.

5. **Update tests** — Add to `HomeFeedViewModelTests`: `testLoadNextPage_triggersLoadingMore`, `testLoadNextPage_whenAlreadyLoading_ignored`, `testLoadNextPage_whenNoMore_ignored`, `testDidPullToRefresh_resetsAndReloads`, `testDidPullToRefresh_duringLoading_ignored`.

**Success Criteria**:
- *Minimal*: Scrolling loads more pages, pull-to-refresh works, tests pass
- *Extended*: Duplicate load prevention, loading spinner visible, smooth append animation

**Tests**: HomeFeedViewModelTests (pagination cases)

**Commit**: `feat: add pagination with infinite scroll and pull-to-refresh`

---

### E9: Pin Detail Feature (Full Vertical Slice)

**Topic**: Feature Composition

**Prerequisites**: E6, E7, E8

**Problem**: Tapping a photo should push a detail screen showing the full-resolution image, description, author info, likes, date, and EXIF data. Build this as a complete vertical slice — service, view model, view controller, coordinator — applying all patterns established in previous exercises.

**Solution**: `PinDetailService` fetching `/photos/:id`. `PinDetailViewModel` with a `DetailState` enum. `PinDetailViewController` with a scroll view layout. `PinDetailCoordinator` pushed by the home feed coordinator on photo selection.

**Steps**:

1. **Create PinDetailService** — Protocol and implementation. `fetchPhoto(id:)` calls the `.photo(id:)` endpoint. Returns `UnsplashPhoto` (the detail response has additional fields like exif, location).

2. **Create PinDetailViewModel** — `DetailState`: `.idle`, `.loading`, `.loaded`, `.error(String)`. Inputs: `viewDidLoad()`. Outputs (closures): `onStateChanged`, plus formatted properties: `imageURL`, `titleText`, `authorName`, `authorImageURL`, `likesText`, `dateText`, `exifText`. Date formatting: relative or "MMM d, yyyy". EXIF: "Canon EOS R5 · f/2.8 · 1/500s · ISO 400" (graceful with missing fields).

3. **Create PinDetailViewController** — Scroll view with: full-width image (aspect ratio from data), title label, description label, author row (avatar + name), metadata section (likes, date, exif). Uses ViewModel closures to update UI on state changes.

4. **Create PinDetailCoordinator** — Takes a navigation controller and photo ID. Creates service, VM, VC. Pushes VC on `start()`. Has `onDismiss` closure called on `deinit` (for parent cleanup).

5. **Wire photo selection** — `HomeFeedCoordinator` implements `homeFeedDidSelectPhoto(id:)` by creating a `PinDetailCoordinator` as a child, starting it, and setting its `onDismiss` to remove it from children.

6. **Write tests** — `PinDetailServiceTests`, `PinDetailViewModelTests` (state transitions, formatting, nil fields), `PinDetailCoordinatorTests` (push, deinit cleanup). Create `MockPinDetailService`.

**Success Criteria**:
- *Minimal*: Tapping a photo pushes detail with image and metadata, back button pops, tests pass
- *Extended*: EXIF formatting handles partial data, date formatting, coordinator cleanup on deinit

**Tests**: PinDetailServiceTests, PinDetailViewModelTests, PinDetailCoordinatorTests

**Commit**: `feat: add pin detail screen with full vertical slice`

---

### E10: Tab Bar Navigation

**Topic**: Tab Navigation

**Prerequisites**: E6, E9

**Problem**: The app currently launches directly into the home feed. Real apps use tab bars. Create a MainTabCoordinator that manages a UITabBarController with a Home tab (the existing feed) and a Search tab (placeholder).

**Solution**: `MainTabCoordinator` creates a `UITabBarController`, assigns the home feed's nav controller as the first tab, and adds a placeholder second tab. AppCoordinator creates MainTabCoordinator instead of HomeFeedCoordinator directly.

**Steps**:

1. **Create MainTabCoordinator** — Creates a `UITabBarController` with two tabs. First tab: a new `UINavigationController` running `HomeFeedCoordinator`. Second tab: a placeholder `UIViewController` with "Search" title and magnifying glass icon. Sets tab bar items (titles, icons).

2. **Refactor AppCoordinator** — Instead of creating HomeFeedCoordinator, create MainTabCoordinator as a child. MainTabCoordinator pushes the tab bar controller onto the window's nav controller.

3. **Write tests** — `MainTabCoordinatorTests`: verify tab bar created with 2 tabs, first tab is home feed, HomeFeedCoordinator is a child.

**Success Criteria**:
- *Minimal*: App shows tab bar with Home and Search tabs, Home shows the feed, tests pass
- *Extended*: Tab bar items have correct icons and titles

**Tests**: MainTabCoordinatorTests

**Commit**: `feat: add tab bar navigation with MainTabCoordinator`

---

### E11: Combine Bindings

**Topic**: Reactive Bindings

**Prerequisites**: E5, E9

**Problem**: ViewModels currently communicate with ViewControllers via closure callbacks (`onStateChanged`, `onPhotosUpdated`). Replace all closures with Combine's `@Published` properties and subscriber-based bindings. This is a refactoring exercise — external behavior stays the same.

**Solution**: ViewModels expose `@Published` properties. ViewControllers subscribe with `$property.receive(on: DispatchQueue.main).sink {}` and store cancellables. All closure properties and calls are removed.

**Steps**:

1. **Refactor HomeFeedViewModel** — Replace `var onStateChanged: ((FeedState) -> Void)?` with `@Published private(set) var state: FeedState = .idle`. Replace `var onPhotosUpdated: (([PhotoCellViewModel]) -> Void)?` with `@Published private(set) var cellViewModels: [PhotoCellViewModel] = []`. Remove all closure invocations, just assign to properties.

2. **Update HomeFeedViewController bindings** — Add `import Combine` and `private var cancellables = Set<AnyCancellable>()`. Replace closure assignments with: `viewModel.$cellViewModels.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] vms in ... }.store(in: &cancellables)`. Same for `$state`.

3. **Refactor PinDetailViewModel** — Replace `onStateChanged` closure with `@Published` state and output properties (imageURL, titleText, authorName, etc.).

4. **Update PinDetailViewController bindings** — Subscribe to `$state` with Combine sink. Update UI in the subscriber.

5. **Update ViewModel tests** — Replace closure-based assertions with `sut.$state.sink { states.append($0) }`. Use `Task.sleep(for: .milliseconds(200))` (or similar) to wait for async updates. Verify all existing test cases still pass.

**Success Criteria**:
- *Minimal*: All closures replaced with @Published + sink, all tests pass, no behavior change
- *Extended*: Clean cancellable management, dropFirst() used to skip initial values where appropriate

**Tests**: HomeFeedViewModelTests (updated), PinDetailViewModelTests (updated)

**Commit**: `refactor: replace closure callbacks with Combine bindings`

---

### E12: State & Error Handling

**Topic**: UX Polish

**Prerequisites**: E6, E9, E11

**Problem**: The app has no visual feedback for empty states or errors. Network failures show nothing (or a basic alert). Build a reusable overlay view for empty/error states, add inline error views that replace modal alerts, and handle image loading failures in cells.

**Solution**: `StateOverlayView` with empty and error styles (icon, message, optional retry button). Home feed shows empty state when no photos and no more to load. Errors show as full-screen overlay (when empty) or top-level banner (when data exists). PhotoCell shows a placeholder icon on image failure.

**Steps**:

1. **Create StateOverlayView** — Reusable `UIView` subclass with configurable styles: `.empty(message:)` shows a photo icon + message, `.error(message:)` shows exclamation icon + message + "Retry" button. `onRetry` closure. Centered layout with auto-layout.

2. **Add empty state to Home Feed** — When state is `.loaded(hasMore: false)` and `cellViewModels` is empty, show `StateOverlayView` with `.empty(message: "No photos found")`. Hide overlay when data arrives.

3. **Add inline errors to Home Feed** — When state is `.error` and no data exists, show full-screen `StateOverlayView` with `.error` style and retry wired to `viewModel.viewDidLoad()`. When data exists and error occurs, keep existing data visible and show a subtle error (e.g., change footer or log — avoid blocking the content).

4. **Add error state to Pin Detail** — Replace any alert-based error with inline `StateOverlayView` in the detail VC. Retry triggers `viewModel.viewDidLoad()`.

5. **Cell failure placeholder** — In `PhotoCell.configure()`, handle Nuke's image load failure: show `UIImage(systemName: "photo")` with `.scaleAspectFit` and a tinted color as fallback. Reset in `prepareForReuse()`.

**Success Criteria**:
- *Minimal*: Empty state visible when API returns no results, error overlay shows on failure with working retry
- *Extended*: Cell placeholder on image failure, error handling differs based on whether data exists

**Tests**: Visual verification (StateOverlayView is a pure UI component)

**Commit**: `feat: add empty state, inline errors, and cell failure placeholder`

---

### E13: Deep Linking & Scoped DI Containers

**Topic**: Deep Linking

**Prerequisites**: E10, E4

**Problem**: The app should respond to custom URL schemes (`pinboard://home`, `pinboard://photo/<id>`). Additionally, the flat DI container should be split into scoped containers — each feature gets its own container that delegates shared services to the parent.

**Solution**: `AppRoute` enum parses URLs into typed routes. Coordinators implement `navigate(to:)` that cascades from AppCoordinator → MainTabCoordinator → HomeFeedCoordinator. Scoped containers (`HomeFeedDependencyContainer`, `PinDetailDependencyContainer`) hold feature-specific services while accessing shared services via parent reference.

**Steps**:

1. **Create AppRoute** — Enum with cases `.home` and `.photoDetail(id: String)`. Failable `init?(url: URL)` that parses the scheme (`pinboard`), host, and path components.

2. **Create scoped DI containers** — `HomeFeedDependencyContainer` holds `homeFeedService` and references parent's shared services (`apiClient`, `imageCache`). `PinDetailDependencyContainer` holds `photoID`, `pinDetailService`, and parent references. Update `AppDependencyContainer` with factory methods: `makeHomeFeedContainer()`, `makePinDetailContainer(photoID:)`.

3. **Update coordinators for scoped containers** — `HomeFeedCoordinator` takes `HomeFeedDependencyContainer` instead of `AppDependencyContainer`. `PinDetailCoordinator` takes `PinDetailDependencyContainer`. Update factory calls.

4. **Implement navigate chain** — `AppCoordinator.navigate(to:)` delegates to `MainTabCoordinator`. `MainTabCoordinator.navigate(to:)` selects the correct tab and delegates (e.g., `.photoDetail` → select home tab, call `homeFeedCoordinator.showPhotoDetail(id:)`). Extract `showPhotoDetail(id:)` as a public method on `HomeFeedCoordinator`.

5. **Wire SceneDelegate** — Handle URLs at launch (`scene(_:willConnectTo:options:)` → check `connectionOptions.urlContexts`) and at runtime (`scene(_:openURLContexts:)` → parse URL → `appCoordinator.navigate(to:)`).

6. **Write tests** — `AppRouteTests`: valid routes, invalid scheme, unknown host, missing ID. Update coordinator tests to use scoped containers.

**Success Criteria**:
- *Minimal*: `pinboard://photo/abc` opens the detail screen, route parsing tests pass
- *Extended*: Scoped containers properly isolate dependencies, launch-time and runtime deep links both work

**Tests**: AppRouteTests, updated coordinator tests

**Commit**: `feat: add deep linking with URL routing and scoped DI containers`

---

### E14: Swift Testing Migration

**Topic**: Testing Modernization

**Prerequisites**: E2-E13 (all tests written)

**Problem**: The project uses XCTest throughout. Apple's Swift Testing framework offers a more modern syntax. Migrate all test files to Swift Testing while keeping one file (`APIClientTests`) in XCTest to demonstrate coexistence.

**Solution**: Replace `XCTestCase` classes with `@Suite` structs. Replace `XCTAssertEqual`/`XCTAssertTrue` with `#expect`. Replace `XCTFail` with `Issue.record()`. Keep `APIClientTests` as XCTest (it uses `URLProtocol` stubbing that benefits from XCTest lifecycle).

**Steps**:

1. **Learn the Swift Testing syntax** — `@Suite("Name") struct Tests {}`, `@Test func name()`, `#expect(condition)`, `#expect(throws: ErrorType.self) { ... }`, `@MainActor` for UI tests, `Issue.record("message")`.

2. **Migrate HomeFeedViewModelTests** — Convert from XCTestCase class to @Suite struct. Replace assertions. For async tests, use the Combine `$state.sink` pattern with `Task.sleep` instead of XCTest expectations.

3. **Migrate all remaining test files** — Convert each test file. For coordinator tests that need `@MainActor`, add the annotation. For fixture loading, add a `TestBundleAnchor` class in Fixtures.swift (Swift Testing uses structs, but `Bundle(for:)` needs a class).

4. **Keep APIClientTests as XCTest** — This demonstrates that XCTest and Swift Testing coexist in the same target. APIClientTests uses setUp/tearDown for URLProtocol registration which maps naturally to XCTest.

5. **Verify all tests pass** — Run the full test suite. Both Swift Testing and XCTest tests should pass together.

**Success Criteria**:
- *Minimal*: All tests converted and passing, one XCTest file retained
- *Extended*: Clean Swift Testing idioms (not just mechanical syntax replacement), TestBundleAnchor pattern for fixture loading

**Tests**: All test files (migrated format)

**Commit**: `refactor: migrate tests to Swift Testing, keep APIClientTests as XCTest`

---

## Rubric Summary

| Exercise | Minimal Criteria | Extended Criteria |
|----------|-----------------|-------------------|
| E1 | App builds and launches | Design system with light/dark, Dynamic Type |
| E2 | Endpoint tests pass | APIClient integration tests with URLProtocol |
| E3 | Models decode from fixtures | All optionals and edge cases verified |
| E4 | Coordinator chain launches app | Clean child lifecycle management |
| E5 | VM state transitions, tests pass | Edge cases: empty response, nil fields, large counts |
| E6 | Waterfall grid shows API data | Diffable animations, proper reuse, coordinator tests |
| E7 | Real images load | Prefetching, cache protocol tested |
| E8 | Infinite scroll + pull-to-refresh | Duplicate prevention, loading spinner |
| E9 | Detail screen with metadata | EXIF partial data, date formatting, deinit cleanup |
| E10 | Tab bar with 2 tabs | Correct icons/titles, tests pass |
| E11 | Combine replaces all closures | Clean cancellable management, no behavior change |
| E12 | Empty state + error overlay + retry | Cell placeholder, context-aware error (full vs partial) |
| E13 | Deep link opens detail | Scoped containers, launch + runtime URLs |
| E14 | All tests migrated + passing | Swift Testing idioms, TestBundleAnchor pattern |

---

## Solution Folder Structure

Each exercise has a solution folder containing the complete project state after that exercise:

```
Solutions/
├── E01_scaffold/
│   ├── project.yml
│   └── PinBoard/...
├── E02_networking/
│   ├── project.yml
│   ├── PinBoard/...
│   └── PinBoardTests/...
├── ...
└── E14_swift_testing/
    ├── project.yml
    ├── PinBoard/...
    └── PinBoardTests/...
```

Each solution folder is a complete, buildable project. The learner can compare their work against the solution at any point.

---

## Delivery Format

1. **Overview page** (HTML): High-level plan with exercise list, topic map, and progress tracking checkboxes
2. **Per-exercise pages** (HTML): Full problem description, steps, hints (collapsible), rubric, and links to solution folder
