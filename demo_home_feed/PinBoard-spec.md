# PinBoard - Photo Feed Demo

## Overview

An iOS demo app showcasing a photo feed using MVVM with Coordinators. Built to demonstrate architecture patterns — coordinator hierarchy, folder-based module boundaries, DiffableDataSource, CompositionalLayout waterfall grid, and Nuke for image loading. Uses the Unsplash API as a real data source.

## Architecture

```
SceneDelegate
  └─ AppDependencyContainer (owns shared services: APIClient, ImageLoader)
  └─ AppCoordinator (root)
       └─ MainTabCoordinator
            ├─ HomeFeedCoordinator → HomeFeedVC (waterfall grid)
            │    └─ PinDetailCoordinator → PinDetailVC (pushed on pin tap)
            └─ (Search tab - stub/placeholder, not implemented)
```

### Folder Structure (single Xcode target, module-like boundaries)

```
PinBoard/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift              # Creates container + AppCoordinator
│   ├── AppDependencyContainer.swift     # Composition root — owns all shared services
│   └── Coordinators/
│       ├── Coordinator.swift            # Protocol + child coordinator helpers
│       ├── AppCoordinator.swift         # Root — decides main flow
│       └── MainTabCoordinator.swift     # Tab bar, creates per-tab coordinators
│
├── Features/
│   ├── HomeFeed/
│   │   ├── HomeFeedCoordinator.swift    # Creates HomeFeedVC, implements HomeFeedDelegate
│   │   ├── HomeFeedDelegate.swift       # Protocol: didSelectPhoto(id:), didRequestRefresh completed
│   │   ├── HomeFeedViewModel.swift      # Pagination state machine, transforms models → cell VMs
│   │   ├── HomeFeedViewController.swift # CollectionView + CompositionalLayout + DiffableDataSource
│   │   ├── PhotoCellViewModel.swift     # Display-ready struct (title, imageURL, aspectRatio, authorName)
│   │   ├── PhotoCell.swift              # UICollectionViewCell — Nuke image loading, prepareForReuse cancellation
│   │   ├── WaterfallLayout.swift        # CompositionalLayout factory for waterfall grid
│   │   └── HomeFeedService.swift        # Calls APIClient with Unsplash /photos endpoint
│   │
│   └── PinDetail/
│       ├── PinDetailCoordinator.swift   # Creates PinDetailVC
│       ├── PinDetailViewModel.swift     # Formats detail data (date, description, exif, author)
│       ├── PinDetailViewController.swift# Scrollable detail view — full image, metadata, author info
│       └── PinDetailService.swift       # Calls APIClient with Unsplash /photos/:id endpoint
│
├── Core/
│   ├── Networking/
│   │   ├── APIClient.swift              # URLSession wrapper, generic request<T: Decodable>
│   │   ├── APIClientProtocol.swift      # Protocol for injection/testing
│   │   ├── Endpoint.swift               # Protocol: path, method, queryItems
│   │   ├── UnsplashEndpoints.swift      # Concrete endpoints: .photos(page:), .photo(id:)
│   │   └── APIError.swift               # Error enum
│   │
│   └── Models/
│       ├── UnsplashPhoto.swift          # Decodable: id, description, urls, width, height, user, etc.
│       └── UnsplashUser.swift           # Decodable: name, username, profileImageURL
│
├── DesignSystem/
│   ├── Colors.swift                     # Semantic colors: primary, secondary, background, surface, onSurface, error, divider
│   ├── Fonts.swift                      # Semantic text styles using Dynamic Type: heading, subheading, body, caption, label
│   └── LoadingFooterView.swift          # Reusable spinner for pagination footer
│
└── Resources/
    ├── Assets.xcassets
    ├── LaunchScreen.storyboard
    └── Info.plist
```

## Data Source: Unsplash API

**Base URL:** `https://api.unsplash.com`

**Auth:** `Authorization: Client-ID <ACCESS_KEY>` header on every request. Access Key only (no Secret Key needed for read-only).

**Endpoints used:**

| Endpoint | Method | Purpose | Key response fields |
|---|---|---|---|
| `GET /photos?page=N&per_page=20&order_by=popular` | GET | Home feed pagination | `[{id, description, urls.regular, width, height, user.name, likes}]` |
| `GET /photos/:id` | GET | Pin detail | `{id, description, urls.full, width, height, user, exif, location, created_at, likes}` |

**Rate limit:** 50 requests/hour (demo tier). Sufficient for development/demo.

**Image URLs from response:** Unsplash provides multiple sizes per photo — `urls.raw`, `urls.full`, `urls.regular` (1080px wide), `urls.small` (400px), `urls.thumb` (200px). Use `urls.small` in the feed grid, `urls.regular` in detail.

**Aspect ratio:** Calculated from `width` / `height` in the response. Available before image download — enables smooth waterfall layout with no content jumps.

## Key Implementation Details

### Coordinator Hierarchy

- **AppCoordinator** — created by SceneDelegate, owns the UIWindow. Calls `start()` which creates MainTabCoordinator.
- **MainTabCoordinator** — creates UITabBarController with two tabs (Home, placeholder Search). Creates HomeFeedCoordinator for the home tab with its own UINavigationController.
- **HomeFeedCoordinator** — implements `HomeFeedDelegate`. Calls `container.homeFeedService` + `container.apiClient` to create the HomeFeedViewModel and HomeFeedViewController. When `homeFeedDidSelectPhoto(id:)` is called, creates PinDetailCoordinator as a child and starts it.
- **PinDetailCoordinator** — creates PinDetailViewModel + PinDetailViewController and pushes onto the nav stack. On dismissal/pop, parent removes it from child coordinators.

### HomeFeedViewModel — Pagination State Machine

```
States: idle → loading → loaded(hasMore) → loadingMore → loaded(hasMore)
                                         → error
Pull-to-refresh: loaded/error → loading (resets page to 0, clears data)
```

- Exposes outputs via closures: `onStateChanged`, `onPhotosUpdated`
- Input methods: `viewDidLoad()`, `didPullToRefresh()`, `loadNextPage()`
- Transforms `UnsplashPhoto` → `PhotoCellViewModel` (imageURL, aspectRatio, title, authorName, likesText)
- Page size: 20 items per request

### Waterfall Layout (CompositionalLayout)

- 2-column waterfall grid
- Item width: (collectionView width - spacing) / 2
- Item height: width / aspectRatio (from API metadata)
- Inter-item spacing: 8pt, section insets: 8pt
- Supplementary footer view for pagination spinner

### DiffableDataSource

- Section enum: `.main`
- Item identifier: photo ID (`String`)
- Cell provider closure captures Nuke's image pipeline for loading
- Pagination: get current snapshot → append new IDs → apply with animation
- Pull-to-refresh: new snapshot from scratch → apply without animation

### Image Loading (Nuke)

- Nuke added via SPM: `https://github.com/kean/Nuke`
- Use `ImagePipeline.shared` (default config includes memory + disk cache)
- In `PhotoCell.configure()`: use `Nuke.loadImage(with:into:)` which auto-cancels on reuse
- Nuke handles `prepareForReuse` cancellation automatically when using `loadImage(with:into:imageView)`
- Prefetching: implement `UICollectionViewDataSourcePrefetching` → `ImagePrefetcher` from Nuke

### PinDetail Screen

- Pushed by coordinator when a photo is tapped in the feed
- Shows: full-resolution image (urls.regular), photo description, author name + avatar, likes count, created date, EXIF data if available
- PinDetailViewModel fetches full photo data via `/photos/:id` (more fields than the list endpoint)
- Back navigation pops the VC; coordinator cleans up child reference

### DesignSystem

**Colors.swift** — semantic color tokens backed by asset catalog colors (auto light/dark):

| Token | Purpose | Example |
|---|---|---|
| `AppColors.primary` | Brand accent, interactive elements | Tint on buttons, links |
| `AppColors.secondary` | Secondary accent | Author name, metadata |
| `AppColors.background` | Screen/page background | Collection view background |
| `AppColors.surface` | Card/cell background | Photo cell container |
| `AppColors.onSurface` | Primary text on surface | Photo title |
| `AppColors.onSurfaceSecondary` | Secondary text on surface | Likes count, date |
| `AppColors.error` | Error states | Error banner text |
| `AppColors.divider` | Separators, borders | Thin lines between sections |

Implemented as `static` properties on an `AppColors` enum, returning `UIColor` from the asset catalog (which provides automatic light/dark variants):
```swift
enum AppColors {
    static let primary = UIColor(named: "Primary")!
    static let background = UIColor(named: "Background")!
    // ...
}
```

**Fonts.swift** — semantic text styles using `UIFont.TextStyle` for Dynamic Type:

| Token | UIFont.TextStyle | Usage |
|---|---|---|
| `AppFonts.heading` | `.title2` | Detail screen title |
| `AppFonts.subheading` | `.headline` | Section headers, author name |
| `AppFonts.body` | `.body` | Descriptions, main content |
| `AppFonts.caption` | `.caption1` | Likes count, date, EXIF |
| `AppFonts.label` | `.footnote` | Cell overlay text, metadata |

Implemented via `UIFont.preferredFont(forTextStyle:)` so text scales with the user's accessibility settings:
```swift
enum AppFonts {
    static let heading = UIFont.preferredFont(forTextStyle: .title2)
    static let subheading = UIFont.preferredFont(forTextStyle: .headline)
    static let body = UIFont.preferredFont(forTextStyle: .body)
    static let caption = UIFont.preferredFont(forTextStyle: .caption1)
    static let label = UIFont.preferredFont(forTextStyle: .footnote)
}
```

All labels/text views in the app set `adjustsFontForContentSizeCategory = true` to respond to Dynamic Type changes at runtime.

### API Key Handling

- Access Key stored in a `Secrets.swift` file (gitignored)
- Template file `Secrets.example.swift` committed with placeholder:
  ```swift
  enum Secrets {
      static let unsplashAccessKey = "YOUR_ACCESS_KEY_HERE"
  }
  ```
- APIClient reads `Secrets.unsplashAccessKey` and injects it as a header

## Dependencies

| Dependency | Version | Purpose | Added via |
|---|---|---|---|
| Nuke | 12.x | Image loading, caching, prefetching | SPM |

No other external dependencies. Networking is a thin URLSession wrapper.

## Build & Run Requirements

- Xcode 16.x
- iOS 16+ deployment target (CompositionalLayout improvements, modern UICollectionView APIs)
- Free Unsplash developer account → Access Key

## Unit Tests

**Target:** 100% coverage on ViewModels, Services, Coordinators, and Models. VC/Cell coverage via limited integration tests.

**Test target:** `PinBoardTests` (standard XCTest bundle)

### Folder Structure

```
PinBoardTests/
├── Mocks/
│   ├── MockAPIClient.swift              # Stubbed APIClientProtocol — returns preset Result, tracks calls
│   ├── MockHomeFeedService.swift        # Stubbed HomeFeedServiceProtocol
│   ├── MockPinDetailService.swift       # Stubbed PinDetailServiceProtocol
│   ├── MockHomeFeedDelegate.swift       # Records delegate calls (didSelectPhoto, etc.)
│   ├── MockCoordinatorDelegate.swift    # Records coordinator lifecycle callbacks
│   └── Fixtures.swift                   # Factory methods for test UnsplashPhoto/User objects
│
├── Core/
│   ├── APIClientTests.swift             # URLProtocol-based tests for real URLSession behavior
│   ├── UnsplashEndpointsTests.swift     # Verify path, method, queryItems for each endpoint
│   └── ModelDecodingTests.swift         # Decode real Unsplash JSON fixtures → verify all fields
│
├── Features/
│   ├── HomeFeed/
│   │   ├── HomeFeedViewModelTests.swift # State machine: all transitions, edge cases, output assertions
│   │   ├── HomeFeedServiceTests.swift   # Verify correct endpoint called, response mapped properly
│   │   ├── HomeFeedCoordinatorTests.swift # Child coordinator lifecycle, delegate forwarding
│   │   └── PhotoCellViewModelTests.swift  # Formatting: likes text, aspect ratio, fallback values
│   │
│   └── PinDetail/
│       ├── PinDetailViewModelTests.swift  # State transitions, formatting (date, EXIF, description)
│       ├── PinDetailServiceTests.swift    # Correct endpoint, response mapping
│       └── PinDetailCoordinatorTests.swift # Push/pop lifecycle, cleanup
│
├── App/
│   ├── AppCoordinatorTests.swift        # Starts correct flow, child management
│   └── MainTabCoordinatorTests.swift    # Creates tabs, wires child coordinators
│
└── Fixtures/
    ├── photos_page1.json               # Real Unsplash API response (sanitized), 3-5 items
    └── photo_detail.json               # Single photo detail response
```

### What Each Test File Covers

**HomeFeedViewModelTests** (highest priority — most logic lives here):
- `testViewDidLoad_triggersLoading` — state transitions idle → loading, closure fires
- `testViewDidLoad_success_transitionsToLoaded` — mock service returns photos, cellViewModels populated, state = loaded(hasMore: true)
- `testViewDidLoad_emptyResponse_loadsWithNoMore` — state = loaded(hasMore: false)
- `testViewDidLoad_failure_transitionsToError` — mock service returns error, state = error, error message exposed
- `testLoadNextPage_whenLoaded_triggersLoadingMore` — state loaded → loadingMore, page incremented
- `testLoadNextPage_whenAlreadyLoading_ignored` — no duplicate fetch
- `testLoadNextPage_whenNoMore_ignored` — loaded(hasMore: false) rejects pagination
- `testDidPullToRefresh_resetsAndReloads` — clears data, page = 0, state → loading
- `testDidPullToRefresh_duringLoading_ignored` — no double-refresh
- `testDidPullToRefresh_fromError_reloads` — error state allows refresh
- `testCellViewModels_correctlyFormatted` — likesText formatting (0, 1, 500, 14500 → "14.5K")
- `testCellViewModels_aspectRatioCalculated` — width/height from API → correct aspect ratio
- `testCellViewModels_nilDescription_fallback` — missing description handled gracefully

**PhotoCellViewModelTests:**
- `testLikesFormatting_zero` → "No likes yet"
- `testLikesFormatting_singular` → "1 like"
- `testLikesFormatting_hundreds` → "500 likes"
- `testLikesFormatting_thousands` → "14.5K likes"
- `testAspectRatio_landscape` — width > height
- `testAspectRatio_portrait` — height > width
- `testAspectRatio_square` — 1.0
- `testNilDescription_usesEmptyString`

**HomeFeedServiceTests:**
- `testFetchPhotos_callsCorrectEndpoint` — verifies page number, per_page, order_by params
- `testFetchPhotos_decodesResponse` — mock APIClient returns JSON data, service returns [UnsplashPhoto]
- `testFetchPhotos_propagatesError` — APIClient throws → service throws same error

**PinDetailViewModelTests:**
- `testLoadDetail_success_formatsAllFields` — date formatting, EXIF string, description, author
- `testLoadDetail_failure_showsError`
- `testDateFormatting_relativeDate` — "2 days ago" style or "Jan 15, 2025" style
- `testExifFormatting_allFieldsPresent` — "Canon EOS R5 - f/2.8 - 1/500s - ISO 400"
- `testExifFormatting_partialFields` — graceful handling of nil aperture/shutter/ISO
- `testNilDescription_fallback`

**PinDetailServiceTests:**
- `testFetchPhoto_callsCorrectEndpoint` — verifies photo ID in path
- `testFetchPhoto_decodesResponse`
- `testFetchPhoto_propagatesError`

**APIClientTests** (URLProtocol stubbing):
- `testRequest_success_decodesJSON` — 200 response with valid JSON
- `testRequest_httpError_throwsAPIError` — 4xx/5xx → appropriate APIError case
- `testRequest_invalidJSON_throwsDecodingError`
- `testRequest_networkError_throwsAPIError`
- `testRequest_injectsAuthHeader` — verifies `Client-ID` header present on every request

**UnsplashEndpointsTests:**
- `testPhotosEndpoint_path` — "/photos"
- `testPhotosEndpoint_queryItems` — page, per_page, order_by
- `testPhotoDetailEndpoint_path` — "/photos/{id}"

**ModelDecodingTests:**
- `testDecodePhotoFromJSON` — load photos_page1.json fixture, verify all fields
- `testDecodePhotoDetail_withExif` — EXIF fields parsed
- `testDecodePhotoDetail_withoutExif` — nil EXIF handled
- `testDecodeUser` — name, username, profile image URLs

**HomeFeedCoordinatorTests:**
- `testStart_pushesHomeFeedVC` — nav controller has 1 VC after start()
- `testDidSelectPhoto_createsPinDetailCoordinator` — child coordinator added
- `testDidSelectPhoto_pushesDetailVC` — nav controller has 2 VCs
- `testPinDetailDismissed_removesChildCoordinator` — child array cleaned up

**PinDetailCoordinatorTests:**
- `testStart_pushesDetailVC`
- `testDeinit_cleansUp` — no retain cycles

**AppCoordinatorTests:**
- `testStart_createsMainTabCoordinator` — child coordinator added
- `testStart_setsWindowRootViewController`

**MainTabCoordinatorTests:**
- `testStart_createsTabBarWithTwoTabs`
- `testStart_createsHomeFeedCoordinator` — child coordinator exists

### Testing Approach

**MockAPIClient pattern:**
```swift
final class MockAPIClient: APIClientProtocol {
    var stubbedResult: Result<Any, Error> = .failure(APIError.unknown)
    private(set) var requestedEndpoints: [any Endpoint] = []

    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        requestedEndpoints.append(endpoint)
        switch stubbedResult {
        case .success(let value):
            return value as! T
        case .failure(let error):
            throw error
        }
    }
}
```

**JSON Fixtures:** Real (sanitized) Unsplash responses stored as .json files in the Fixtures/ folder. Loaded in tests via `Bundle(for: type(of: self)).url(forResource:)`. Ensures decoding tests match actual API shape.

**URLProtocol stubbing** for APIClient integration tests:
```swift
final class MockURLProtocol: URLProtocol {
    static var stubbedData: Data?
    static var stubbedResponse: HTTPURLResponse?
    static var stubbedError: Error?
    // ... override startLoading/stopLoading
}
```
Inject a URLSession configured with MockURLProtocol into APIClient to test real URLSession behavior without network.

**Coordinator tests** use a real UINavigationController to verify push/pop behavior. No UIWindow needed — just assert on `navigationController.viewControllers.count` and types.

### Coverage Exclusions

These are intentionally not unit-tested (UI layer):
- `PhotoCell` — Nuke's `loadImage(with:into:)` is Nuke's responsibility; cell just calls it
- `HomeFeedViewController` — layout binding and UIKit lifecycle; tested manually or via UI tests
- `PinDetailViewController` — same as above
- `WaterfallLayout` — CompositionalLayout configuration; verified visually
- `SceneDelegate` / `AppDelegate` — trivial app bootstrap
- `DesignSystem/*` — constants only (Colors, Fonts)
- `LoadingFooterView` — trivial UI

These exclusions keep tests fast and focused on logic. The VC/cell layer is thin by design (MVVM) so untested UI code has minimal logic.

## Out of Scope

- User authentication / OAuth
- Search feature (tab exists as stub)
- Saving/liking photos (write operations)
- Offline mode / persistence
- SwiftUI
- UI tests (snapshot or XCUITest)
