# Claude Project Rules

## Code Organization

### Private Functions in Extensions
Place all private functions in private extensions at the end of the file for all types (structs, classes, enums, actors). Keep all properties (stored and computed) in the main type definition.

**Example:**
```swift
struct MyView: View {
    @State private var isActive = false
    private var computedValue: String { "value" }
    
    var body: some View { 
        // View content
    }
}

// MARK: - Private Methods
private extension MyView {
    func privateMethod() { }
}
```

## Unit Test Naming Convention

**Format:** `test[Component]_[Scenario]_[ExpectedOutcome]()`

**Examples:**
- `testCocktailListViewModel_LoadDataWithSuccess_ReturnsExpectedCocktails()`
- `testIngredient_DisplayString_ReturnsFormattedString()`
- `testFilterType_AllCases_ContainsExpectedValues()`

This format clearly identifies what's being tested, under what conditions, and what should happen.

## Development Commands

### Testing
- **Run CocktailsKit tests:** `swift test` (from CocktailsKit directory)
- **Run main app tests:** `cd app && xcodebuild test -scheme CocktailBook -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2" -only-testing:CocktailBookTests -quiet`

### Linting
- **SwiftLint:** Runs automatically during build, or manually via `scripts/swiftlint.sh`