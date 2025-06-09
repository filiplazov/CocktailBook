# Claude Project Rules

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
- **Run main app tests:** `xcodebuild test -scheme CocktailBook -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2" -only-testing:CocktailBookTests -quiet`

### Linting
- **SwiftLint:** Runs automatically during build, or manually via `scripts/swiftlint.sh`