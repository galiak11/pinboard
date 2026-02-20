# PinBoard

A photo feed demo app demonstrating MVVM with Coordinators, UICollectionView waterfall layout, DiffableDataSource, and Nuke for image loading. Uses the Unsplash API.

## Setup (first time)

### 1. Install XcodeGen

```bash
brew install xcodegen
```

### 2. Add your Unsplash API key

Copy the template and add your key:

```bash
cp PinBoard/Core/Networking/Secrets.example.swift PinBoard/Core/Networking/Secrets.swift
```

Edit `Secrets.swift` and replace `YOUR_ACCESS_KEY_HERE` with your key from [Unsplash Developers](https://unsplash.com/developers).

### 3. Generate the Xcode project

```bash
cd Study/projects/demo_home_feed
xcodegen generate
```

### 4. Open and run

```bash
open PinBoard.xcodeproj
```

Select an iPhone simulator and run (Cmd+R).

## Regenerating the project

After adding/removing source files, regenerate:

```bash
xcodegen generate
```

## Architecture

See [PinBoard-spec.md](PinBoard-spec.md) for full architecture documentation.

```
SceneDelegate
  └─ AppDependencyContainer
  └─ AppCoordinator
       └─ MainTabCoordinator
            ├─ HomeFeedCoordinator → HomeFeedVC (waterfall grid)
            │    └─ PinDetailCoordinator → PinDetailVC
            └─ (Search tab - placeholder)
```

## Requirements

- Xcode 16.x
- iOS 16+
- Free Unsplash developer account (Access Key only)


create a teaching plan to build the projdcts/demo_home_feed project.
The learner will use xcode to build this project one exercise as a time. 
the teaching plan will go in order of teaching topics order, where each teaching topic will provide exercise(s) the student will follow that will build this project that teach the topic. each step of the exercise leaves the project in a runnable state (a step may modify multiple files). 

Top-down approach:
Topics -> implement features -> create exercises -> make steps.
completing steps will finish the exercise. completion the exercises will implement the feature. Multiple features may be needed to cover a topic.

Exercises have a visible or testable feature success criteria (seeing an item in the ui, network is sending info X, etc.). The exercise may have multiple steps in order to get to a point where a sub-feature is implemented, however each excercise (or even steps?) should leave the project in a buildable/runnable state.

first stuggest a list of topics that can be taught and the exercises and steps.

Then list exercisses in a bottom-up order (infrastructue first, dependencies first, ui later, etc) - in the order they can be built and run with no build/run errors.

Create rubric for success for different exercises (minimal to implement, then extended criteria)

Once approved, these will be used to create a comprehensive lesson plan that lists all execrises, where each exercise/feature can be marked as complete when its done.

suggest a framework for this and ask clarifying questions


this is a good start. lessons within features may change more than one feil. lessons are not on file bounday - but rather on feature bounday, ie: a feature may need chagnes to multiple files to work. for eaxample, the basic networking lesson implements a basic feed, but adding some featues later will require addint to the feed. this should simulate real world work, so multiple files may change as features are added.

each exercise should include a full decription of the problem, and what a solution should look like (with optional/ hidden hints when relevant). each step includes logical changes to implement the feature - not in the order of files or the order they appear in the file. For example, E8 can start with creating a basic VC with a default CV and a default CV cell. then add other features over multiple steps, example steps: adding a custom cell, using a diffable data source, etc.
Also:
- Skip the accessibility topic.
answers to your questions:
1- learner is experienced and knows uikit
2-minimum scaffolding - the learner should do almost all work. provide a complete solution for each step in a separate foler.
3-tests should be part of each exercise (testing the logic that was built)
4- learner will use xcode. ai can use xcodegen to test the project works (and can run the tests to ensure they pass)
5-api key exist in one of the files somewhere in Study/ - can you find out where it is
6 - yes to both
7-a single page for the full plan (in high level), and then pages for each topic/exercises - could be in HTML.

You may ask clarifying questions



Example teaching lesson:
feature goal: writing a unit test.
prerequisites: a given program that implemented feature x (that should already get implemented in previous lessons).
Steps: 
1) ask the user how they would test feature X.
2) ask the user what is needed in order to write a test (what libararies, mocks, etc). 
3) list the actual steps needed to write the test. explain the steps (assume an advanced engineer in your explanations)
4) the user creates the necessary files or adds to an existing file. All changes for the feature are added to a single commit or are all in the working directory - so it's easy to tell what has been done for a given feature.
5) you evaluate the feature implement - using an appropriate rubric. 
6) user fixes if need to.
7) you mark the feature as done in the lessons plan.

