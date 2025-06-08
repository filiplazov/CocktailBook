@testable import CocktailBook
import Combine
import CombineSchedulers
import XCTest

final class CocktailDataManagerTests: XCTestCase {
    var dataManager: CocktailDataManager!
    var mockAPI: MockCocktailsAPI!
    var mockUserDefaults: MockUserDefaults!
    var testScheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        mockAPI = MockCocktailsAPI()
        mockUserDefaults = MockUserDefaults()
        testScheduler = DispatchQueue.test

        dataManager = CocktailDataManager(
            cocktailsAPI: mockAPI,
            userDefaults: mockUserDefaults,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
    }

    override func tearDown() {
        dataManager = nil
        mockAPI = nil
        mockUserDefaults = nil
        testScheduler = nil
        super.tearDown()
    }

    // MARK: - Load Data Tests

    func testLoadData_Success() {
        dataManager.loadData()
        testScheduler.advance()

        XCTAssertEqual(dataManager.allCocktails.count, 3)
        XCTAssertFalse(dataManager.isLoading)
        XCTAssertNil(dataManager.errorMessage)
    }

    func testLoadData_Failure() {
        mockAPI.shouldFail = true

        dataManager.loadData()
        testScheduler.advance()

        XCTAssertEqual(dataManager.allCocktails.count, 0)
        XCTAssertFalse(dataManager.isLoading)
        XCTAssertNotNil(dataManager.errorMessage)
        XCTAssertEqual(dataManager.errorMessage, "Unable to retrieve cocktails, API unavailable")
    }

    // MARK: - Favorites Tests

    func testToggleFavorite_AddToFavorites() {
        let cocktailID = "1"

        dataManager.toggleFavorite(cocktailID: cocktailID)

        XCTAssertTrue(dataManager.isFavorite(cocktailID: cocktailID))
        XCTAssertTrue(dataManager.favoriteCocktailIDs.contains(cocktailID))
    }

    func testToggleFavorite_RemoveFromFavorites() {
        let cocktailID = "1"

        // First add to favorites
        dataManager.toggleFavorite(cocktailID: cocktailID)
        XCTAssertTrue(dataManager.isFavorite(cocktailID: cocktailID))

        // Then remove from favorites
        dataManager.toggleFavorite(cocktailID: cocktailID)
        XCTAssertFalse(dataManager.isFavorite(cocktailID: cocktailID))
        XCTAssertFalse(dataManager.favoriteCocktailIDs.contains(cocktailID))
    }

    func testIsFavorite_NotFavorite() {
        let cocktailID = "1"

        XCTAssertFalse(dataManager.isFavorite(cocktailID: cocktailID))
    }

    // MARK: - Loading State Tests

    func testLoadingState_DuringLoadData() {
        dataManager.loadData()

        // Should be loading before scheduler advances
        XCTAssertTrue(dataManager.isLoading)

        // Advance scheduler and check loading is false
        testScheduler.advance()
        XCTAssertFalse(dataManager.isLoading)
    }

    // MARK: - Filtering Tests

    func testFilterType_DefaultIsAll() {
        XCTAssertEqual(dataManager.filterType, .all)
    }

    func testSetFilterType_UpdatesFilterType() {
        dataManager.setFilterType(.alcoholic)
        XCTAssertEqual(dataManager.filterType, .alcoholic)

        dataManager.setFilterType(.nonAlcoholic)
        XCTAssertEqual(dataManager.filterType, .nonAlcoholic)

        dataManager.setFilterType(.all)
        XCTAssertEqual(dataManager.filterType, .all)
    }

    func testFilteredCocktails_ShowsAllByDefault() {
        dataManager.loadData()
        testScheduler.advance()

        XCTAssertEqual(dataManager.filteredCocktails.count, 3)
        XCTAssertEqual(dataManager.filterType, .all)
    }

    func testFilteredCocktails_AlcoholicFilter() {
        dataManager.loadData()
        testScheduler.advance()

        dataManager.setFilterType(.alcoholic)

        // Wait for filtering to complete
        let filteredCocktails = dataManager.filteredCocktails
        XCTAssertEqual(filteredCocktails.count, 3) // All mock cocktails are alcoholic
        XCTAssertTrue(filteredCocktails.allSatisfy { $0.type == .alcoholic })
    }

    func testFilteredCocktails_NonAlcoholicFilter() {
        dataManager.loadData()
        testScheduler.advance()

        dataManager.setFilterType(.nonAlcoholic)

        // All mock cocktails are alcoholic, so should be empty
        let filteredCocktails = dataManager.filteredCocktails
        XCTAssertEqual(filteredCocktails.count, 0)
    }

    func testFilteredCocktails_AlphabeticalOrder() {
        dataManager.loadData()
        testScheduler.advance()

        let filteredCocktails = dataManager.filteredCocktails
        let cocktailNames = filteredCocktails.map { $0.name }

        // Should be sorted alphabetically: Manhattan, Margarita, Mojito
        XCTAssertEqual(cocktailNames, ["Mock Manhattan", "Mock Margarita", "Mock Mojito"])
    }

    func testFilteredCocktails_FavoritesFirst() {
        // Load data first
        dataManager.loadData()
        testScheduler.advance()

        // Mark Mojito as favorite (it would be last alphabetically)
        dataManager.toggleFavorite(cocktailID: "2") // Mojito

        let filteredCocktails = dataManager.filteredCocktails
        let cocktailNames = filteredCocktails.map { $0.name }

        // Mojito (favorite) should come first, then alphabetical order for non-favorites
        XCTAssertEqual(cocktailNames, ["Mock Mojito", "Mock Manhattan", "Mock Margarita"])

        // Verify favorite status
        XCTAssertTrue(filteredCocktails[0].isFavorite) // Mojito
        XCTAssertFalse(filteredCocktails[1].isFavorite) // Manhattan
        XCTAssertFalse(filteredCocktails[2].isFavorite) // Margarita
    }

    func testFilteredCocktails_MultipleFavoritesAlphabetical() {
        // Load data first
        dataManager.loadData()
        testScheduler.advance()

        // Mark Manhattan and Margarita as favorites
        dataManager.toggleFavorite(cocktailID: "1") // Margarita
        dataManager.toggleFavorite(cocktailID: "3") // Manhattan

        let filteredCocktails = dataManager.filteredCocktails
        let cocktailNames = filteredCocktails.map { $0.name }

        // Favorites first in alphabetical order, then non-favorites
        XCTAssertEqual(cocktailNames, ["Mock Manhattan", "Mock Margarita", "Mock Mojito"])

        // Verify favorite status
        XCTAssertTrue(filteredCocktails[0].isFavorite) // Manhattan
        XCTAssertTrue(filteredCocktails[1].isFavorite) // Margarita
        XCTAssertFalse(filteredCocktails[2].isFavorite) // Mojito
    }

    func testFilteredCocktails_UpdatesOnFavoriteToggle() {
        dataManager.loadData()
        testScheduler.advance()

        // Initial state: no favorites
        let initialFiltered = dataManager.filteredCocktails
        XCTAssertTrue(initialFiltered.allSatisfy { !$0.isFavorite })

        // Toggle favorite
        dataManager.toggleFavorite(cocktailID: "1")

        // Check that filtered cocktails updated
        let updatedFiltered = dataManager.filteredCocktails
        let favoriteCount = updatedFiltered.filter { $0.isFavorite }.count
        XCTAssertEqual(favoriteCount, 1)

        // The first cocktail should now be the favorite one
        XCTAssertTrue(updatedFiltered[0].isFavorite)
        XCTAssertEqual(updatedFiltered[0].id, "1")
    }
}
