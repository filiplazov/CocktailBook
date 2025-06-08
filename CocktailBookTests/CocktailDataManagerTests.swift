import XCTest

@testable import CocktailBook
import CocktailsKit

@MainActor
final class CocktailDataManagerTests: XCTestCase {
    var dataManager: CocktailDataManager!
    var mockAPI: MockCocktailsAPI!
    var mockUserDefaults: MockUserDefaults!

    override func setUp() async throws {
        try await super.setUp()
        mockAPI = MockCocktailsAPI()
        mockUserDefaults = MockUserDefaults()

        dataManager = CocktailDataManager(
            cocktailsAPI: mockAPI,
            userDefaults: mockUserDefaults
        )
    }

    override func tearDown() async throws {
        dataManager = nil
        mockAPI = nil
        mockUserDefaults = nil
        try await super.tearDown()
    }

    // MARK: - Loading Tests

    func testLoadDataSuccess() async throws {
        // Given
        mockAPI.shouldFail = false
        XCTAssertTrue(dataManager.allCocktails.isEmpty)

        // When
        await dataManager.loadData()

        // Then
        XCTAssertFalse(dataManager.isLoading)
        XCTAssertNil(dataManager.errorMessage)
        XCTAssertEqual(dataManager.allCocktails.count, 3)
        XCTAssertEqual(dataManager.filteredCocktails.count, 3)
    }

    func testLoadDataFailure() async throws {
        // Given
        mockAPI.shouldFail = true

        // When
        await dataManager.loadData()

        // Then
        XCTAssertFalse(dataManager.isLoading)
        XCTAssertNotNil(dataManager.errorMessage)
        XCTAssertTrue(dataManager.allCocktails.isEmpty)
        XCTAssertTrue(dataManager.filteredCocktails.isEmpty)
    }

    func testLoadDataEmptyResponse() async throws {
        // Given
        mockAPI.shouldReturnEmptyData = true

        // When
        await dataManager.loadData()

        // Then
        XCTAssertFalse(dataManager.isLoading)
        XCTAssertNil(dataManager.errorMessage)
        XCTAssertTrue(dataManager.allCocktails.isEmpty)
        XCTAssertTrue(dataManager.filteredCocktails.isEmpty)
    }

    // MARK: - Filtering Tests

    func testFilteringByType() async throws {
        // Given
        await dataManager.loadData()
        XCTAssertEqual(dataManager.filteredCocktails.count, 3)

        // When filtering to alcoholic
        dataManager.filterType = .alcoholic

        // Then
        let alcoholicCocktails = dataManager.filteredCocktails.filter { $0.type == .alcoholic }
        XCTAssertEqual(dataManager.filteredCocktails.count, alcoholicCocktails.count)
        XCTAssertEqual(dataManager.filteredCocktails.count, 2) // Margarita and Manhattan

        // When filtering to non-alcoholic  
        dataManager.filterType = .nonAlcoholic

        // Then
        let nonAlcoholicCocktails = dataManager.filteredCocktails.filter { $0.type == .nonAlcoholic }
        XCTAssertEqual(dataManager.filteredCocktails.count, nonAlcoholicCocktails.count)
        XCTAssertEqual(dataManager.filteredCocktails.count, 1) // Mojito

        // When filtering to all
        dataManager.filterType = .all

        // Then
        XCTAssertEqual(dataManager.filteredCocktails.count, 3)
    }

    // MARK: - Favorites Tests

    func testToggleFavorite() async throws {
        // Given
        await dataManager.loadData()
        let cocktailID = dataManager.allCocktails.first!.id
        XCTAssertFalse(dataManager.isFavorite(cocktailID: cocktailID))

        // When adding to favorites
        dataManager.toggleFavorite(cocktailID: cocktailID)

        // Then
        XCTAssertTrue(dataManager.isFavorite(cocktailID: cocktailID))
        XCTAssertTrue(dataManager.favoriteCocktailIDs.contains(cocktailID))

        // When removing from favorites
        dataManager.toggleFavorite(cocktailID: cocktailID)

        // Then
        XCTAssertFalse(dataManager.isFavorite(cocktailID: cocktailID))
        XCTAssertFalse(dataManager.favoriteCocktailIDs.contains(cocktailID))
    }

    func testFavoritesPersistedInUserDefaults() async throws {
        // Given
        await dataManager.loadData()
        let cocktailID = dataManager.allCocktails.first!.id

        // When
        dataManager.toggleFavorite(cocktailID: cocktailID)

        // Then
        let savedFavorites = mockUserDefaults.array(forKey: "FavoriteCocktailIDs") as? [String]
        XCTAssertNotNil(savedFavorites)
        XCTAssertTrue(savedFavorites!.contains(cocktailID))
    }

    func testFavoritesSortedFirst() async throws {
        // Given
        await dataManager.loadData()
        let firstCocktail = dataManager.allCocktails.first!
        let lastCocktail = dataManager.allCocktails.last!

        // When marking last cocktail as favorite
        dataManager.toggleFavorite(cocktailID: lastCocktail.id)

        // Then - favorite should appear first in filtered list
        XCTAssertEqual(dataManager.filteredCocktails.first?.id, lastCocktail.id)
        XCTAssertTrue(dataManager.filteredCocktails.first?.isFavorite == true)
    }

    func testMultipleFavoritesAreSorted() async throws {
        // Given
        await dataManager.loadData()
        let cocktails = dataManager.allCocktails

        // When marking multiple as favorites
        dataManager.toggleFavorite(cocktailID: cocktails[0].id)
        dataManager.toggleFavorite(cocktailID: cocktails[2].id)

        // Then - favorites should be sorted alphabetically among themselves
        let favoriteCocktails = dataManager.filteredCocktails.filter { $0.isFavorite }
        XCTAssertEqual(favoriteCocktails.count, 2)
        
        // Check that favorites come first
        let firstTwoItems = Array(dataManager.filteredCocktails.prefix(2))
        XCTAssertTrue(firstTwoItems.allSatisfy { $0.isFavorite })
    }

    // MARK: - Filter + Favorites Integration Tests

    func testFavoritesWithFiltering() async throws {
        // Given
        await dataManager.loadData()
        let alcoholicCocktail = dataManager.allCocktails.first { $0.type == .alcoholic }!
        let nonAlcoholicCocktail = dataManager.allCocktails.first { $0.type == .nonAlcoholic }!

        // When marking both types as favorites
        dataManager.toggleFavorite(cocktailID: alcoholicCocktail.id)
        dataManager.toggleFavorite(cocktailID: nonAlcoholicCocktail.id)

        // Then when filtering to alcoholic, only alcoholic favorite should show
        dataManager.filterType = .alcoholic
        let filteredFavorites = dataManager.filteredCocktails.filter { $0.isFavorite }
        XCTAssertEqual(filteredFavorites.count, 1)
        XCTAssertEqual(filteredFavorites.first?.type, .alcoholic)

        // And when filtering to non-alcoholic, only non-alcoholic favorite should show
        dataManager.filterType = .nonAlcoholic
        let filteredNonAlcoholicFavorites = dataManager.filteredCocktails.filter { $0.isFavorite }
        XCTAssertEqual(filteredNonAlcoholicFavorites.count, 1)
        XCTAssertEqual(filteredNonAlcoholicFavorites.first?.type, .nonAlcoholic)
    }

    // MARK: - UserDefaults Integration Tests

    func testLoadingExistingFavorites() async throws {
        // Given - pre-existing favorites in UserDefaults
        let existingFavoriteID = "existing-favorite"
        mockUserDefaults.set([existingFavoriteID], forKey: "FavoriteCocktailIDs")

        // When creating a new data manager
        let newDataManager = CocktailDataManager(
            cocktailsAPI: mockAPI,
            userDefaults: mockUserDefaults
        )

        // Then
        XCTAssertTrue(newDataManager.isFavorite(cocktailID: existingFavoriteID))
        XCTAssertEqual(newDataManager.favoriteCocktailIDs, [existingFavoriteID])
    }

    func testEmptyFavoritesFromUserDefaults() async throws {
        // Given - no existing favorites
        mockUserDefaults.removeObject(forKey: "FavoriteCocktailIDs")

        // When creating a new data manager
        let newDataManager = CocktailDataManager(
            cocktailsAPI: mockAPI,
            userDefaults: mockUserDefaults
        )

        // Then
        XCTAssertTrue(newDataManager.favoriteCocktailIDs.isEmpty)
    }
}
