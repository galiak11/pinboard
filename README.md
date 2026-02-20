# PinBoard — iOS Architecture Course

Build a photos feed app from scratch using UIKit, MVVM, and Coordinators. 14 exercises, bottom-up build order, real Unsplash API.

## Getting Started

1. Fork this repo
2. Clone your fork
3. Open `exercises/index.html` in a browser to see the course overview
4. Enter your GitHub repo URL in the settings bar (used for solution links)
5. Follow the exercises in order — each one builds on the previous

## Prerequisites

- Xcode 26+
- Free [Unsplash developer account](https://unsplash.com/developers) (Access Key only)

## Workflow

1. Read the exercise page
2. Implement the feature
3. Run tests: Cmd+U in Xcode (or `xcodebuild test -scheme PinBoard -destination 'platform=iOS Simulator,name=iPhone 16'`)
4. Commit and push
5. Move to the next exercise

## Solution Branches

Each exercise has a solution branch you can browse:

| Exercise | Branch |
|----------|--------|
| E1: Project Scaffold & Design System | `solution/e01-scaffold` |
| E2: Networking Layer | `solution/e02-networking` |
| E3: Data Models & JSON Fixtures | `solution/e03-models` |
| E4: Coordinator Pattern & DI Container | `solution/e04-coordinators` |
| E5: Home Feed Service & ViewModel | `solution/e05-feed-viewmodel` |
| E6: Home Feed UI | `solution/e06-feed-ui` |
| E7: Image Loading & Caching | `solution/e07-image-loading` |
| E8: Pagination | `solution/e08-pagination` |
| E9: Pin Detail (Full Vertical Slice) | `solution/e09-pin-detail` |
| E10: Tab Bar Navigation | `solution/e10-tab-bar` |
| E11: Combine Bindings | `solution/e11-combine` |
| E12: State & Error Handling | `solution/e12-state-errors` |
| E13: Deep Linking & Scoped DI | `solution/e13-deep-linking` |
| E14: Swift Testing Migration | `solution/e14-swift-testing` |

To see what an exercise adds, compare branches:
```
# Example: what does E6 add on top of E5?
git diff solution/e05-feed-viewmodel..solution/e06-feed-ui
```
