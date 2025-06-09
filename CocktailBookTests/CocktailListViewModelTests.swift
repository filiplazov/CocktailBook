import XCTest

@testable import CocktailBook
import CocktailsKit

@MainActor
final class CocktailListViewModelTests: XCTestCase {
    var viewModel: CocktailListViewModel!
    var mockAPI: MockCocktailsAPI!
    var mockUserDefaults: MockUserDefaults!

    override func setUp() async throws {
        try await super.setUp()
        mockAPI = MockCocktailsAPI()
        mockUserDefaults = MockUserDefaults()

        viewModel = CocktailListViewModel(
            cocktailsAPI: mockAPI,
            userDefaults: mockUserDefaults
        )
    }

    override func tearDown() async throws {
        viewModel = nil
        mockAPI = nil
        mockUserDefaults = nil
        try await super.tearDown()
    }

    // MARK: - Loading Tests

    func testLoadData_Success_ReturnsExpectedCocktails() async throws {
        // Given
        mockAPI.shouldFail = false
        XCTAssertTrue(viewModel.allCocktails.isEmpty)

        // When
        await viewModel.loadData()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.allCocktails.count, 3)
        XCTAssertEqual(viewModel.filteredCocktails.count, 3)
    }

    func testLoadData_Failure_SetsErrorMessage() async throws {
        // Given
        mockAPI.shouldFail = true

        // When
        await viewModel.loadData()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.allCocktails.isEmpty)
        XCTAssertTrue(viewModel.filteredCocktails.isEmpty)
    }

    func testLoadData_EmptyResponse_ReturnsEmptyArray() async throws {
        // Given
        mockAPI.shouldReturnEmptyData = true

        // When
        await viewModel.loadData()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.allCocktails.isEmpty)
        XCTAssertTrue(viewModel.filteredCocktails.isEmpty)
    }

    // MARK: - Filtering Tests

    func testFilteredCocktails_ByType_ReturnsCorrectResults() async throws {
        // Given
        await viewModel.loadData()
        XCTAssertEqual(viewModel.filteredCocktails.count, 3)

        // When filtering to alcoholic
        viewModel.filterType = .alcoholic

        // Then
        let alcoholicCocktails = viewModel.filteredCocktails.filter { $0.type == .alcoholic }
        XCTAssertEqual(viewModel.filteredCocktails.count, alcoholicCocktails.count)
        XCTAssertEqual(viewModel.filteredCocktails.count, 2) // Margarita and Manhattan

        // When filtering to non-alcoholic  
        viewModel.filterType = .nonAlcoholic

        // Then
        let nonAlcoholicCocktails = viewModel.filteredCocktails.filter { $0.type == .nonAlcoholic }
        XCTAssertEqual(viewModel.filteredCocktails.count, nonAlcoholicCocktails.count)
        XCTAssertEqual(viewModel.filteredCocktails.count, 1) // Mojito

        // When filtering to all
        viewModel.filterType = .all

        // Then
        XCTAssertEqual(viewModel.filteredCocktails.count, 3)
    }

    // MARK: - Favorites Tests

    func testToggleFavorite_AddAndRemove_UpdatesFavoriteStatus() async throws {
        // Given
        await viewModel.loadData()
        let cocktailID = try XCTUnwrap(viewModel.allCocktails.first).id
        XCTAssertFalse(viewModel.isFavorite(cocktailID: cocktailID))

        // When adding to favorites
        viewModel.toggleFavorite(cocktailID: cocktailID)

        // Then
        XCTAssertTrue(viewModel.isFavorite(cocktailID: cocktailID))
        XCTAssertTrue(viewModel.favoriteCocktailIDs.contains(cocktailID))

        // When removing from favorites
        viewModel.toggleFavorite(cocktailID: cocktailID)

        // Then
        XCTAssertFalse(viewModel.isFavorite(cocktailID: cocktailID))
        XCTAssertFalse(viewModel.favoriteCocktailIDs.contains(cocktailID))
    }

    func testToggleFavorite_PersistsToUserDefaults_SavesFavoriteID() async throws {
        // Given
        await viewModel.loadData()
        let cocktailID = try XCTUnwrap(viewModel.allCocktails.first).id

        // When
        viewModel.toggleFavorite(cocktailID: cocktailID)

        // Then
        let savedFavorites = try XCTUnwrap(mockUserDefaults.array(forKey: "FavoriteCocktailIDs") as? [String])
        XCTAssertTrue(savedFavorites.contains(cocktailID))
    }

    func testFilteredCocktails_FavoritesFirst_SortsCorrectly() async throws {
        // Given
        await viewModel.loadData()
        let firstCocktail = try XCTUnwrap(viewModel.allCocktails.first)
        let lastCocktail = try XCTUnwrap(viewModel.allCocktails.last)

        // When marking last cocktail as favorite
        viewModel.toggleFavorite(cocktailID: lastCocktail.id)

        // Then - favorite should appear first in filtered list
        XCTAssertEqual(viewModel.filteredCocktails.first?.id, lastCocktail.id)
        XCTAssertTrue(viewModel.filteredCocktails.first?.isFavorite == true)
    }

    func testFilteredCocktails_MultipleFavorites_SortsAlphabetically() async throws {
        // Given
        await viewModel.loadData()
        let cocktails = viewModel.allCocktails

        // When marking multiple as favorites
        viewModel.toggleFavorite(cocktailID: cocktails[0].id)
        viewModel.toggleFavorite(cocktailID: cocktails[2].id)

        // Then - favorites should be sorted alphabetically among themselves
        let favoriteCocktails = viewModel.filteredCocktails.filter { $0.isFavorite }
        XCTAssertEqual(favoriteCocktails.count, 2)

        // Check that favorites come first
        let firstTwoItems = Array(viewModel.filteredCocktails.prefix(2))
        XCTAssertTrue(firstTwoItems.allSatisfy { $0.isFavorite })
    }

    // MARK: - Filter + Favorites Integration Tests

    func testFilteredCocktails_WithFavoritesAndTypeFilter_ReturnsCorrectResults() async throws {
        // Given
        await viewModel.loadData()
        let alcoholicCocktail = try XCTUnwrap(viewModel.allCocktails.first { $0.type == .alcoholic })
        let nonAlcoholicCocktail = try XCTUnwrap(viewModel.allCocktails.first { $0.type == .nonAlcoholic })

        // When marking both types as favorites
        viewModel.toggleFavorite(cocktailID: alcoholicCocktail.id)
        viewModel.toggleFavorite(cocktailID: nonAlcoholicCocktail.id)

        // Then when filtering to alcoholic, only alcoholic favorite should show
        viewModel.filterType = .alcoholic
        let filteredFavorites = viewModel.filteredCocktails.filter { $0.isFavorite }
        XCTAssertEqual(filteredFavorites.count, 1)
        XCTAssertEqual(filteredFavorites.first?.type, .alcoholic)

        // And when filtering to non-alcoholic, only non-alcoholic favorite should show
        viewModel.filterType = .nonAlcoholic
        let filteredNonAlcoholicFavorites = viewModel.filteredCocktails.filter { $0.isFavorite }
        XCTAssertEqual(filteredNonAlcoholicFavorites.count, 1)
        XCTAssertEqual(filteredNonAlcoholicFavorites.first?.type, .nonAlcoholic)
    }

    // MARK: - UserDefaults Integration Tests

    func testInit_WithExistingFavorites_LoadsSavedFavorites() async throws {
        // Given - pre-existing favorites in UserDefaults
        let existingFavoriteID = "existing-favorite"
        mockUserDefaults.set([existingFavoriteID], forKey: "FavoriteCocktailIDs")

        // When creating a new data manager
        let newDataManager = CocktailListViewModel(
            cocktailsAPI: mockAPI,
            userDefaults: mockUserDefaults
        )

        // Then
        XCTAssertTrue(newDataManager.isFavorite(cocktailID: existingFavoriteID))
        XCTAssertEqual(newDataManager.favoriteCocktailIDs, [existingFavoriteID])
    }

    func testInit_WithNoFavorites_StartsWithEmptyFavorites() async throws {
        // Given - no existing favorites
        mockUserDefaults.removeObject(forKey: "FavoriteCocktailIDs")

        // When creating a new data manager
        let newDataManager = CocktailListViewModel(
            cocktailsAPI: mockAPI,
            userDefaults: mockUserDefaults
        )

        // Then
        XCTAssertTrue(newDataManager.favoriteCocktailIDs.isEmpty)
    }

    // MARK: - Ingredient Display String Tests

    func testIngredientDisplayString_WithImperialSystem_ReturnsImperialAmount() {
        // Given
        let ingredient = Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml")

        // When
        let displayString = viewModel.ingredientDisplayString(for: ingredient, measurementSystem: .imperial)

        // Then
        XCTAssertEqual(displayString, "2 oz Tequila")
    }

    func testIngredientDisplayString_WithMetricSystem_ReturnsMetricAmount() {
        // Given
        let ingredient = Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml")

        // When
        let displayString = viewModel.ingredientDisplayString(for: ingredient, measurementSystem: .metric)

        // Then
        XCTAssertEqual(displayString, "60 ml Tequila")
    }

    func testIngredientDisplayString_WithEmptyAmounts_ReturnsNameOnly() {
        // Given
        let ingredient = Ingredient(imperialAmount: "", name: "Salt", metricAmount: "")

        // When - Imperial system
        let imperialDisplayString = viewModel.ingredientDisplayString(for: ingredient, measurementSystem: .imperial)

        // Then
        XCTAssertEqual(imperialDisplayString, "Salt")

        // When - Metric system
        let metricDisplayString = viewModel.ingredientDisplayString(for: ingredient, measurementSystem: .metric)

        // Then
        XCTAssertEqual(metricDisplayString, "Salt")
    }

    func testIngredientDisplayString_WithEmptyMetricAmount_FallsBackToName() {
        // Given
        let ingredient = Ingredient(imperialAmount: "1 pinch", name: "Black pepper", metricAmount: "")

        // When - Imperial system
        let imperialDisplayString = viewModel.ingredientDisplayString(for: ingredient, measurementSystem: .imperial)

        // Then
        XCTAssertEqual(imperialDisplayString, "1 pinch Black pepper")

        // When - Metric system (should fallback to just name when metric is empty)
        let metricDisplayString = viewModel.ingredientDisplayString(for: ingredient, measurementSystem: .metric)

        // Then
        XCTAssertEqual(metricDisplayString, "Black pepper")
    }
}
