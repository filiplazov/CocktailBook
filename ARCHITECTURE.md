# CocktailBook iOS App - Architecture & Technology Summary

## 📱 Project Overview

**CocktailBook** is a modern iOS application built with SwiftUI and Swift Concurrency, showcasing a clean architecture approach for displaying and managing cocktail recipes. The app demonstrates best practices in iOS development including async/await programming, dependency injection, comprehensive testing, and clean code organization.

## 🏗 Architecture Pattern

### MVVM + Swift Concurrency (Model-View-ViewModel)
- **View Layer**: SwiftUI views (`CocktailListView`, `CocktailDetailView`)
- **ViewModel Layer**: `CocktailListViewModel` (@MainActor ObservableObject)
- **Model Layer**: `Cocktail` struct and related data models (Sendable conforming)
- **Async Programming**: Swift Concurrency with async/await for data flow and state management

### Key Architectural Principles
- **Separation of Concerns**: Clear boundaries between UI, business logic, and data
- **Dependency Injection**: Constructor injection for testability
- **Single Responsibility**: Each class/struct has a focused purpose
- **Protocol-Oriented Programming**: `CocktailsAPI`, `UserDefaultsProtocol`
- **Thread Safety**: @MainActor for UI updates, Sendable types, and actor isolation

---

## 🛠 Technology Stack

### Core Technologies
- **Language**: Swift 6.0
- **Minimum iOS Version**: iOS 18.0
- **UI Framework**: SwiftUI
- **Concurrency Framework**: Swift Concurrency (async/await)
- **Package Manager**: Swift Package Manager (SPM)

### Dependencies
- **CocktailsKit** (Local Swift Package): Core API layer and data abstractions
  - Contains `CocktailsAPI` protocol and `CocktailsAPIError` definitions
  - Includes `FakeCocktailsAPI` actor for development and testing
  - Provides sample cocktail data (JSON) for realistic testing
  - Thread-safe actor-based implementation with Swift Concurrency

### Development Tools
- **Xcode**: 16.4.0
- **Testing Framework**: XCTest with async/await support
- **Code Organization**: MARK comments for section organization
- **SwiftLint**: v0.59.1 for automated code style enforcement
  - Configuration: `.swiftlint.yml` with project-specific rules
  - Shell script: `scripts/swiftlint.sh` for easy CLI usage
  - Auto-correction support for formatting violations
  - Integration ready for Xcode build phases

---

## 📁 Project Structure

```
CocktailBook/
├── 📱 App Entry Point
│   └── CocktailBookApp.swift
├── 🎨 Views (SwiftUI)
│   ├── CocktailListView.swift
│   └── CocktailDetailView.swift
├── 🧠 Business Logic
│   └── CocktailListViewModel.swift
├── 📊 Models
│   └── Cocktail.swift
├── 🔧 Utilities
│   └── UserDefaultsProtocol.swift
└── 📦 Resources
    ├── Assets.xcassets/
    ├── Base.lproj/
    └── Info.plist

CocktailBookTests/
├── 🧪 Test Files
│   ├── CocktailListViewModelTests.swift
│   └── CocktailModelTests.swift
└── 🎭 Test Mocks
    ├── MockCocktailsAPI.swift
    ├── MockUserDefaults.swift
    └── MockData.swift

CocktailsKit/ (Swift Package)
├── 📦 Package.swift
├── 🌐 Sources/CocktailsKit/
│   ├── CocktailsAPI.swift (Protocol)
│   ├── CocktailsAPIError.swift (Error Types)
│   └── FakeCocktailsAPI.swift (Actor Implementation)
└── 📊 Resources/
    └── sample.json (Test Data)

Documentation/
├── 📝 README.md
└── 📋 ARCHITECTURE.md (this file)
```

---

## 🏛 Core Components

### 1. CocktailsKit Swift Package (API Layer)
**Purpose**: Modular API abstraction layer providing network protocols and implementations

**Key Components**:
- **CocktailsAPI Protocol**: Defines async API contract for fetching cocktail data
- **CocktailsAPIError**: Sendable error types for API failures (`unavailable`)
- **FakeCocktailsAPI Actor**: Thread-safe mock implementation for development/testing
- **sample.json**: Realistic test data with complete cocktail information

**Architecture Benefits**:
```swift
// Protocol-based abstraction
protocol CocktailsAPI: Sendable {
    func fetchCocktails() async throws -> Data
}

// Actor-based implementation
actor FakeCocktailsAPI: CocktailsAPI {
    // Thread-safe failure simulation
    // On-demand JSON loading
    // Immutable configuration
}
```

**Key Features**:
- Swift Concurrency with actor isolation for thread safety
- On-demand JSON data loading (no stored properties)
- Configurable failure simulation for testing edge cases
- Clean separation from main app logic
- Reusable across different targets (app, tests, previews)

### 2. CocktailListViewModel (ViewModel)
**Purpose**: Central business logic controller implementing the ViewModel pattern with @MainActor

**Key Responsibilities**:
- Data loading and caching with async/await
- State management (`@Published` properties)
- Filtering and sorting logic
- Favorites management with UserDefaults persistence
- Error handling and loading states

### 3. SettingsManager (Settings ViewModel)
**Purpose**: User preferences management with @MainActor for UI binding

**Key Responsibilities**:
- Measurement system preference management
- UserDefaults persistence with automatic synchronization
- Observable state updates for UI binding
- Default value handling (Imperial as default)

**Key Features**:
```swift
@MainActor
final class CocktailListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var allCocktails: [Cocktail] = []
    @Published var filteredCocktails: [Cocktail] = []
    @Published var filterType: FilterType = .all
    
    // MARK: - Async Methods
    func loadData() async {
        // Swift Concurrency implementation
    }
}
```

**Async Data Flow**:
- Uses `Task` blocks for async operations
- Implements dependency injection for testability
- @MainActor ensures UI updates happen on main thread
- Sendable conformance for thread-safe data models

**SettingsManager Implementation**:
```swift
@MainActor
final class SettingsManager: ObservableObject {
    @Published var measurementSystem: MeasurementSystem {
        didSet {
            userDefaults.set(measurementSystem.rawValue, forKey: UserDefaultsKeys.measurementSystem)
        }
    }
    
    private let userDefaults: UserDefaultsProtocol
    
    init(userDefaults: UserDefaultsProtocol = UserDefaults.standard) {
        // Auto-loads saved preference or defaults to imperial
    }
}
```

### 4. SwiftUI Views

#### CocktailListView
- **Purpose**: Main screen displaying filtered cocktail list
- **Features**: Search filtering, category segmented control, favorites indicator, settings navigation
- **Navigation**: NavigationStack with detail view navigation and settings modal presentation
- **Settings Access**: Top-left gear icon button for accessing user preferences

#### CocktailDetailView  
- **Purpose**: Detailed cocktail information display
- **Features**: Image display, ingredients list (with measurement system support), preparation time, favorite toggle
- **Layout**: ScrollView with proper text wrapping and responsive design
- **Measurement Display**: Dynamic ingredient amounts based on user's measurement system preference

#### SettingsView
- **Purpose**: User preferences configuration with Apple-style settings UI
- **Features**: Measurement system toggle (Imperial/Metric), native Form styling
- **Persistence**: Settings automatically saved to UserDefaults
- **Navigation**: Modal presentation with Done button dismissal

### 5. Data Models

#### Cocktail
- **Type**: `Codable` struct for JSON parsing
- **Properties**: ID, name, type, descriptions, ingredients, preparation time, image
- **Features**: Computed properties, mutable favorite status

#### Ingredient
- **Type**: `Codable` struct with dual measurement system support
- **Properties**: `imperialAmount`, `metricAmount`, `name`
- **Features**: Display string computed properties for both measurement systems
- **Backward Compatibility**: JSON decoding maps legacy "amount" field to "imperialAmount"

#### FilterType
- **Type**: Enum for cocktail categorization
- **Cases**: `.all`, `.alcoholic`, `.nonAlcoholic`

#### MeasurementSystem
- **Type**: Enum for user measurement preferences
- **Cases**: `.imperial` (default), `.metric`
- **Features**: Display names, raw value persistence, Sendable conformance

---

## 🧪 Testing Strategy

### Testing Philosophy
**Descriptive Test Naming Convention**: Test names clearly state the scenario and expected outcome
```swift
func testLoadData_Success()
func testToggleFavorite_AddToFavorites() 
func testFilteredCocktails_FavoritesFirst()
func testCocktailDecoding_WithValidJSON_ReturnsExpectedCocktail()
```

### Test Architecture
- **Comprehensive Coverage**: 24 unit tests covering all major functionality
- **Mock Objects**: Dedicated mock implementations for external dependencies
- **Async Testing**: Native async/await testing with Swift Concurrency
- **Isolated Testing**: Each test uses fresh mock instances
- **Actor-based Mocks**: Thread-safe mock implementations using actors

### Test Categories

#### Data Manager Tests (`CocktailListViewModelTests`)
- ✅ Data loading success/failure scenarios with async/await
- ✅ Favorites management (add/remove/check)
- ✅ Loading state verification with @MainActor
- ✅ Filtering by type (all/alcoholic/non-alcoholic)
- ✅ Sorting logic (favorites first, then alphabetical)

#### Settings Manager Tests (`SettingsManagerTests`)
- ✅ Default measurement system initialization (Imperial)
- ✅ Persistence across app launches with UserDefaults
- ✅ Invalid data handling and fallback to defaults
- ✅ Observable property publishing with @Published
- ✅ Multiple measurement system updates

#### Model Tests (`CocktailModelTests`)
- ✅ JSON decoding with complete/partial data
- ✅ Error handling for malformed JSON
- ✅ Sendable conformance verification
- ✅ Edge cases and data validation

#### Detail View Tests (`CocktailDetailViewTests`)
- ✅ Measurement system display integration
- ✅ Dynamic ingredient amount switching (Imperial/Metric)
- ✅ Empty amount handling for both measurement systems
- ✅ Real-time measurement system preference updates

### Mock Infrastructure
- **MockCocktailsAPI**: Actor-based API simulation with configurable success/failure
- **MockUserDefaults**: In-memory storage for testing persistence and settings
- **MockData**: Standardized test fixtures with Sendable conformance
- **Test Cocktails**: Comprehensive test data with dual measurement amounts

---

## 🎨 Code Organization Standards

### MARK Comments Convention
All source files use consistent MARK comments for organization:

```swift
// MARK: - Published Properties
// MARK: - Private Properties  
// MARK: - Computed Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Async Methods (for Swift Concurrency methods)
```

### File Naming Conventions
- **Views**: `[Purpose]View.swift` (e.g., `CocktailDetailView.swift`)
- **Business Logic**: `[Domain]Manager.swift` (e.g., `CocktailListViewModel.swift`)
- **Models**: `[Entity].swift` (e.g., `Cocktail.swift`)
- **Protocols**: `[Purpose]Protocol.swift` (e.g., `UserDefaultsProtocol.swift`)
- **Tests**: `[Target]Tests.swift` (e.g., `CocktailListViewModelTests.swift`)
- **Mocks**: `Mock[Type].swift` (e.g., `MockCocktailsAPI.swift`)

### Code Quality Practices
- **Dependency Injection**: Constructor injection for all dependencies
- **Protocol Abstraction**: Interfaces for external dependencies (`CocktailsAPI`, `UserDefaultsProtocol`)
- **Single Responsibility**: Each class/struct has a focused purpose
- **Immutable by Default**: Struct-based models with controlled mutability
- **Error Handling**: Comprehensive error types and user-friendly messages
- **SwiftLint Integration**: Automated code style enforcement with custom configuration

---

## 🔄 Data Flow Architecture

### 1. App Launch
```
CocktailBookApp → CocktailListView → CocktailListViewModel.loadData() async
```

### 2. Async Data Loading Flow
```
CocktailListViewModel → CocktailsKit.CocktailsAPI (actor) → JSON Response → Sendable Cocktail Models → @Published Properties → SwiftUI Update
```

### 3. User Interaction Flow
```
User Tap → SwiftUI Action → CocktailListViewModel Async Method → State Update → UI Refresh
```

### 4. Filtering System
```
Filter Selection → FilterType Update → Computed Property → Automatic Filtering → UI Update
```

### 5. Settings & Measurement System Flow
```
Settings Button → SettingsView Modal → Measurement Toggle → SettingsManager Update → UserDefaults Persistence → Detail View Refresh
```

### 6. Ingredient Display Flow
```
CocktailDetailView → SettingsManager.measurementSystem → Ingredient.displayString OR Ingredient.metricDisplayString → Dynamic UI Update
```

---

## 🚀 Key Features Implemented

### ✅ Core Functionality
- [x] Cocktail list display with images and basic info
- [x] Detailed cocktail view with full information
- [x] Category filtering (All/Alcoholic/Non-Alcoholic)
- [x] Favorites system with persistence
- [x] Loading states and error handling
- [x] Responsive UI with proper text wrapping
- [x] Settings screen with Apple-style UI design
- [x] Measurement system toggle (Imperial/Metric)
- [x] Persistent user preferences with UserDefaults
- [x] Dynamic ingredient display based on measurement preference

### ✅ Technical Excellence
- [x] Swift Concurrency with async/await programming
- [x] Comprehensive unit test coverage (30+ tests including settings)
- [x] Clean architecture with separation of concerns
- [x] Dependency injection for testability
- [x] Protocol-oriented design
- [x] Proper error handling and user feedback
- [x] Thread-safe design with @MainActor and Sendable types
- [x] Observable state management for real-time UI updates
- [x] UserDefaults abstraction for testable persistence

### ✅ Code Quality
- [x] Consistent MARK comment organization
- [x] Descriptive test naming convention
- [x] Modular file structure
- [x] Actor-based testing infrastructure
- [x] SwiftUI best practices
- [x] Swift 6.0 strict concurrency compliance

---

## 🔮 Future Enhancement Opportunities

### Potential Architecture Improvements
- **Coordinator Pattern**: Navigation management
- **Repository Pattern**: Data layer abstraction
- **UseCase/Interactor Layer**: Complex business logic separation
- **Advanced Concurrency**: TaskGroup for parallel operations

### Technical Enhancements
- **Core Data Integration**: Local persistence and offline capability
- **Network Layer**: URLSession-based API client with async/await
- **Image Caching**: Efficient image loading and caching with async/await
- **Localization**: Multi-language support
- **Accessibility**: VoiceOver and accessibility improvements

### Testing Enhancements
- **UI Testing**: XCUITest integration with async/await
- **Snapshot Testing**: Visual regression testing
- **Performance Testing**: XCTMetric-based performance validation
- **Integration Testing**: End-to-end workflow testing

---

## 📋 Development Guidelines

### When Adding New Features
1. **Follow MVVM Pattern**: Separate UI, business logic, and data concerns
2. **Use Swift Concurrency**: Implement async/await for all asynchronous operations
3. **Write Tests First**: TDD approach with descriptive test names
4. **Use MARK Comments**: Organize code sections consistently
5. **Implement Protocols**: Abstract external dependencies
6. **Inject Dependencies**: Constructor injection for testability
7. **Ensure Thread Safety**: Use @MainActor for UI updates, Sendable for data models

### Swift Concurrency Guidelines
- Use `@MainActor` for UI-related classes and methods
- Make data models `Sendable` for thread safety
- Prefer `async/await` over completion handlers
- Use actors for shared mutable state
- Use `Task` for bridging sync and async contexts

### Testing Standards
- Write test names that describe scenario and expected outcome
- Use async/await in test methods where appropriate
- Use fresh mock instances for each test
- Test both success and failure scenarios
- Verify state changes and side effects
- Maintain high test coverage

### Code Review Checklist
- [ ] MARK comments properly organized
- [ ] Dependencies injected via constructor
- [ ] Tests written with descriptive names
- [ ] Swift Concurrency patterns correctly implemented
- [ ] Error handling implemented
- [ ] SwiftUI best practices followed
- [ ] Thread safety considerations addressed
- [ ] Sendable conformance where appropriate

---

*Last Updated: June 2025*
*Current Architecture: Swift Concurrency + SwiftUI* 