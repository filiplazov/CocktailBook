import XCTest
@testable import CocktailBook
import Combine

// MARK: - Mock Classes

class MockUserDefaults: UserDefaultsProtocol {
    private var storage: [String: Any] = [:]
    
    func array(forKey defaultName: String) -> [Any]? {
        return storage[defaultName] as? [Any]
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }
}

class MockCocktailDataManagerDelegate: CocktailDataManagerDelegate {
    var onDataUpdate: ((CocktailDataManager) -> Void)?
    var onDataFailure: ((CocktailDataManager, Error) -> Void)?
    
    func dataManagerDidUpdateCocktails(_ manager: CocktailDataManager) {
        onDataUpdate?(manager)
    }
    
    func dataManagerDidFailToLoadCocktails(_ manager: CocktailDataManager, error: Error) {
        onDataFailure?(manager, error)
    }
}

class MockCocktailsAPI: CocktailsAPI {
    var shouldFail = false
    var mockData: [Cocktail] = [
        Cocktail(
            id: "mock-1",
            name: "Mock Margarita",
            type: .alcoholic,
            shortDescription: "A mock margarita for testing",
            longDescription: "This is a mock margarita cocktail used for unit testing purposes.",
            preparationMinutes: 5,
            imageName: "mock_margarita",
            ingredients: ["Tequila", "Lime juice", "Triple sec"]
        ),
        Cocktail(
            id: "mock-2",
            name: "Mock Mojito",
            type: .alcoholic,
            shortDescription: "A mock mojito for testing",
            longDescription: "This is a mock mojito cocktail used for unit testing purposes.",
            preparationMinutes: 7,
            imageName: "mock_mojito",
            ingredients: ["White rum", "Sugar", "Lime juice", "Soda water", "Mint"]
        ),
        Cocktail(
            id: "mock-3",
            name: "Mock Virgin Colada",
            type: .nonAlcoholic,
            shortDescription: "A mock virgin colada for testing",
            longDescription: "This is a mock virgin colada cocktail used for unit testing purposes.",
            preparationMinutes: 3,
            imageName: "mock_virgin_colada",
            ingredients: ["Pineapple juice", "Coconut cream", "Ice"]
        )
    ]
    
    var cocktailsPublisher: AnyPublisher<Data, CocktailsAPIError> {
        if shouldFail {
            return Fail(error: CocktailsAPIError.unavailable)
                .eraseToAnyPublisher()
        } else {
            do {
                let jsonData = try JSONEncoder().encode(mockData)
                return Just(jsonData)
                    .setFailureType(to: CocktailsAPIError.self)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: CocktailsAPIError.unavailable)
                    .eraseToAnyPublisher()
            }
        }
    }
    
    func fetchCocktails(_ handler: @escaping (Result<Data, CocktailsAPIError>) -> Void) {
        if shouldFail {
            handler(.failure(.unavailable))
        } else {
            do {
                let jsonData = try JSONEncoder().encode(mockData)
                handler(.success(jsonData))
            } catch {
                handler(.failure(.unavailable))
            }
        }
    }
}

// MARK: - Tests

class CocktailDataManagerTests: XCTestCase {
    
    var dataManager: CocktailDataManager!
    var mockDelegate: MockCocktailDataManagerDelegate!
    var mockAPI: MockCocktailsAPI!
    var mockUserDefaults: MockUserDefaults!
    
    override func setUpWithError() throws {
        mockDelegate = MockCocktailDataManagerDelegate()
        mockAPI = MockCocktailsAPI()
        // Create a fresh MockUserDefaults for each test to ensure no state leakage
        mockUserDefaults = MockUserDefaults()
        dataManager = CocktailDataManager(cocktailsAPI: mockAPI, userDefaults: mockUserDefaults)
        dataManager.delegate = mockDelegate
    }

    override func tearDownWithError() throws {
        dataManager = nil
        mockDelegate = nil
        mockAPI = nil
        mockUserDefaults = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(dataManager.cocktails.count, 0)
        XCTAssertEqual(dataManager.filteredCocktails(for: .all).count, 0)
        XCTAssertEqual(dataManager.filteredCocktails(for: .alcoholic).count, 0)
        XCTAssertEqual(dataManager.filteredCocktails(for: .nonAlcoholic).count, 0)
    }
    
    // MARK: - Data Loading Tests
    
    func testLoadDataLoadsDataWithPreexistingFavorites() {
        // First, set up some favorites in UserDefaults to test loading favorites correctly
        mockUserDefaults.set(["mock-1", "mock-3"], forKey: "FavoriteCocktailIDs")
        
        let expectation = XCTestExpectation(description: "Load data with pre-existing favorites")
        
        mockDelegate.onDataUpdate = { manager in
            let cocktails = manager.cocktails
            
            // Verify cocktails were loaded
            XCTAssertTrue(cocktails.count > 0, "Should load cocktails from mock data")
            
            // Verify favorites were loaded from UserDefaults before API call
            let favoriteCocktails = cocktails.filter { $0.isFavorite }
            XCTAssertEqual(favoriteCocktails.count, 2, "Should have 2 favorites from UserDefaults")
            
            // Verify the correct cocktails are marked as favorites
            let favoriteIDs = Set(favoriteCocktails.map { $0.id })
            XCTAssertEqual(favoriteIDs, Set(["mock-1", "mock-3"]), "Correct cocktails should be marked as favorites")
            
            expectation.fulfill()
        }
        
        mockDelegate.onDataFailure = { _, error in
            XCTFail("Loading should not fail: \(error)")
        }
        
        dataManager.loadData()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLoadDataSuccess() {
        let expectation = XCTestExpectation(description: "Load data successfully")
        
        mockDelegate.onDataUpdate = { manager in
            XCTAssertTrue(manager.cocktails.count > 0, "Should load cocktails from mock data")
            XCTAssertTrue(manager.cocktails.allSatisfy { !$0.isFavorite }, "Initially no cocktails should be favorites")
            expectation.fulfill()
        }
        
        mockDelegate.onDataFailure = { _, error in
            XCTFail("Loading should not fail: \(error)")
        }
        
        dataManager.loadData()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLoadDataValidatesData() {
        let expectation = XCTestExpectation(description: "Validate loaded cocktail data")
        
        mockDelegate.onDataUpdate = { manager in
            let cocktails = manager.cocktails
            
            // Verify all cocktails have required fields
            for cocktail in cocktails {
                XCTAssertFalse(cocktail.id.isEmpty, "Cocktail ID should not be empty")
                XCTAssertFalse(cocktail.name.isEmpty, "Cocktail name should not be empty")
                XCTAssertFalse(cocktail.shortDescription.isEmpty, "Short description should not be empty")
                XCTAssertFalse(cocktail.longDescription.isEmpty, "Long description should not be empty")
                XCTAssertFalse(cocktail.imageName.isEmpty, "Image name should not be empty")
                XCTAssertGreaterThan(cocktail.preparationMinutes, 0, "Preparation time should be positive")
                XCTAssertFalse(cocktail.ingredients.isEmpty, "Ingredients should not be empty")
            }
            
            expectation.fulfill()
        }
        
        dataManager.loadData()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLoadDataFailure() {
        let expectation = XCTestExpectation(description: "Handle load failure")
        
        // Configure mock to return failure
        mockAPI.shouldFail = true
        
        mockDelegate.onDataFailure = { _, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        mockDelegate.onDataUpdate = { _ in
            XCTFail("Should not succeed when configured to fail")
        }
        
        dataManager.loadData()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Filtering Tests
    
    func testFilteredCocktailsAllTypes() {
        let expectation = XCTestExpectation(description: "Test filtering for all types")
        
        mockDelegate.onDataUpdate = { manager in
            let allCocktails = manager.filteredCocktails(for: .all)
            let alcoholicCocktails = manager.filteredCocktails(for: .alcoholic)
            let nonAlcoholicCocktails = manager.filteredCocktails(for: .nonAlcoholic)
            
            XCTAssertTrue(allCocktails.count > 0)
            XCTAssertTrue(alcoholicCocktails.count > 0)
            XCTAssertTrue(nonAlcoholicCocktails.count > 0)
            
            // Verify filtering logic
            XCTAssertTrue(alcoholicCocktails.allSatisfy { $0.type == .alcoholic })
            XCTAssertTrue(nonAlcoholicCocktails.allSatisfy { $0.type == .nonAlcoholic })
            
            // Verify totals match
            XCTAssertEqual(allCocktails.count, alcoholicCocktails.count + nonAlcoholicCocktails.count)
            
            expectation.fulfill()
        }
        
        dataManager.loadData()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFilteredCocktailsPreservesOrder() {
        let expectation = XCTestExpectation(description: "Test filtering preserves alphabetical order")
        
        mockDelegate.onDataUpdate = { manager in
            // Test each filter type maintains order
            for filterType in FilterType.allCases {
                let filteredCocktails = manager.filteredCocktails(for: filterType)
                let nonFavorites = filteredCocktails.filter { !$0.isFavorite }
                let favoriteNames = filteredCocktails.filter { $0.isFavorite }.map { $0.name }
                let nonFavoriteNames = nonFavorites.map { $0.name }
                
                // Favorites should be alphabetically ordered
                XCTAssertEqual(favoriteNames, favoriteNames.sorted())
                
                // Non-favorites should be alphabetically ordered
                XCTAssertEqual(nonFavoriteNames, nonFavoriteNames.sorted())
            }
            
            expectation.fulfill()
        }
        
        dataManager.loadData()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - DEBUG Test

    
    // MARK: - Favorites Tests
    
    func testToggleFavorite() {
        let loadExpectation = XCTestExpectation(description: "Load cocktails")
        var firstCocktailID: String?
        
        // Phase 1: Load cocktails and verify initial state
        mockDelegate.onDataUpdate = { manager in
            guard let cocktail = manager.cocktails.first else {
                XCTFail("No cocktails loaded")
                return
            }
            
            firstCocktailID = cocktail.id
            // Initially should not be favorite (since we have clean mock UserDefaults)
            XCTAssertFalse(cocktail.isFavorite, "Cocktail should not be favorite initially")
            
            loadExpectation.fulfill()
        }
        
        dataManager.loadData()
        wait(for: [loadExpectation], timeout: 5.0)
        
        // Phase 2: Toggle favorite and verify
        guard let cocktailID = firstCocktailID else {
            XCTFail("No cocktail ID captured")
            return
        }
        
        let toggleExpectation = XCTestExpectation(description: "Toggle favorite")
        
        mockDelegate.onDataUpdate = { manager in
            let updatedCocktail = manager.cocktails.first { $0.id == cocktailID }
            XCTAssertNotNil(updatedCocktail)
            XCTAssertTrue(updatedCocktail!.isFavorite, "Cocktail should be favorite after toggle")
            
            toggleExpectation.fulfill()
        }
        
        // Perform the toggle
        dataManager.toggleFavorite(for: cocktailID)
        wait(for: [toggleExpectation], timeout: 5.0)
    }
    
    func testMultipleFavorites() {
        let loadExpectation = XCTestExpectation(description: "Load cocktails")
        var testCocktailIDs: [String] = []
        
        // Phase 1: Load cocktails and capture IDs
        mockDelegate.onDataUpdate = { manager in
            let cocktails = manager.cocktails
            guard cocktails.count >= 3 else {
                XCTFail("Need at least 3 cocktails for this test")
                return
            }
            
            // Capture the first 3 cocktail IDs
            testCocktailIDs = Array(cocktails.prefix(3).map { $0.id })
            
            // Verify none are favorites initially
            XCTAssertTrue(cocktails.allSatisfy { !$0.isFavorite }, "No cocktails should be favorites initially")
            
            // Clear the callback to prevent further assertions during toggleFavorite calls
            self.mockDelegate.onDataUpdate = { _ in }
            
            loadExpectation.fulfill()
        }
        
        dataManager.loadData()
        wait(for: [loadExpectation], timeout: 5.0)
        
        // Phase 2: Make multiple favorites synchronously (toggleFavorite is synchronous)
        dataManager.toggleFavorite(for: testCocktailIDs[0])
        dataManager.toggleFavorite(for: testCocktailIDs[2])
        dataManager.toggleFavorite(for: testCocktailIDs[1])
        
        // Phase 3: Verify the results immediately (since toggleFavorite is synchronous)
        let allFiltered = dataManager.filteredCocktails(for: .all)
        let favorites = allFiltered.filter { $0.isFavorite }
        
        // Should have 3 favorites
        XCTAssertEqual(favorites.count, 3, "Should have exactly 3 favorites")
        
        // All favorites should appear before non-favorites
        let firstNonFavoriteIndex = allFiltered.firstIndex { !$0.isFavorite }
        let lastFavoriteIndex = allFiltered.lastIndex { $0.isFavorite }
        
        if let firstNonFav = firstNonFavoriteIndex, let lastFav = lastFavoriteIndex {
            XCTAssertLessThan(lastFav, firstNonFav, "All favorites should appear before non-favorites")
        }
        
        // Favorites should be alphabetically ordered among themselves
        let favoriteNames = favorites.map { $0.name }
        XCTAssertEqual(favoriteNames, favoriteNames.sorted(), "Favorites should be alphabetically ordered")
    }
    
    func testFavoritesAppearFirstInAllFilters() {
        let loadExpectation = XCTestExpectation(description: "Load cocktails")
        var alcoholicCocktailID: String?
        var nonAlcoholicCocktailID: String?
        
        // Phase 1: Load cocktails and identify test subjects
        mockDelegate.onDataUpdate = { manager in
            let cocktails = manager.cocktails
            guard let alcoholicCocktail = cocktails.first(where: { $0.type == .alcoholic }),
                  let nonAlcoholicCocktail = cocktails.first(where: { $0.type == .nonAlcoholic }) else {
                XCTFail("Need both alcoholic and non-alcoholic cocktails")
                return
            }
            
            alcoholicCocktailID = alcoholicCocktail.id
            nonAlcoholicCocktailID = nonAlcoholicCocktail.id
            
            // Verify none are favorites initially
            XCTAssertTrue(cocktails.allSatisfy { !$0.isFavorite }, "No cocktails should be favorites initially")
            
            // Clear the callback to prevent further assertions during toggleFavorite calls
            self.mockDelegate.onDataUpdate = { _ in }
            
            loadExpectation.fulfill()
        }
        
        dataManager.loadData()
        wait(for: [loadExpectation], timeout: 5.0)
        
        // Phase 2: Make favorites and verify filtering
        guard let alcoholicID = alcoholicCocktailID,
              let nonAlcoholicID = nonAlcoholicCocktailID else {
            XCTFail("Could not capture cocktail IDs")
            return
        }
        
        // Make one of each type favorite (synchronously)
        dataManager.toggleFavorite(for: alcoholicID)
        dataManager.toggleFavorite(for: nonAlcoholicID)
        
        // Phase 3: Verify filtering results immediately
        // Test all filter shows both favorites first
        let allFiltered = dataManager.filteredCocktails(for: .all)
        let firstTwo = Array(allFiltered.prefix(2))
        XCTAssertTrue(firstTwo.allSatisfy { $0.isFavorite }, "First two cocktails in all filter should be favorites")
        
        // Test alcoholic filter shows alcoholic favorite first
        let alcoholicFiltered = dataManager.filteredCocktails(for: .alcoholic)
        XCTAssertTrue(alcoholicFiltered.first?.isFavorite == true, "First alcoholic cocktail should be favorite")
        XCTAssertEqual(alcoholicFiltered.first?.id, alcoholicID, "First alcoholic cocktail should be the one we favorited")
        
        // Test non-alcoholic filter shows non-alcoholic favorite first
        let nonAlcoholicFiltered = dataManager.filteredCocktails(for: .nonAlcoholic)
        XCTAssertTrue(nonAlcoholicFiltered.first?.isFavorite == true, "First non-alcoholic cocktail should be favorite")
        XCTAssertEqual(nonAlcoholicFiltered.first?.id, nonAlcoholicID, "First non-alcoholic cocktail should be the one we favorited")
    }
    
    // MARK: - Persistence Tests
    
    func testFavoritesPersistence() {
        let expectation1 = XCTestExpectation(description: "Initial load and favorite")
        let expectation2 = XCTestExpectation(description: "Reload and verify persistence")
        
        var cocktailID: String?
        var hasToggledFavorite = false
        
        // First load - make a cocktail favorite
        mockDelegate.onDataUpdate = { manager in
            guard let cocktail = manager.cocktails.first else {
                XCTFail("No cocktails loaded")
                return
            }
            
            if !hasToggledFavorite {
                cocktailID = cocktail.id
                hasToggledFavorite = true
                manager.toggleFavorite(for: cocktail.id)
            } else {
                expectation1.fulfill()
            }
        }
        
        dataManager.loadData()
        wait(for: [expectation1], timeout: 5.0)
        
        // Create new data manager with the same mock user defaults to simulate app restart
        let newMockAPI = MockCocktailsAPI()
        let newDataManager = CocktailDataManager(cocktailsAPI: newMockAPI, userDefaults: mockUserDefaults)
        let newMockDelegate = MockCocktailDataManagerDelegate()
        newDataManager.delegate = newMockDelegate
        
        // Second load - check persistence
        newMockDelegate.onDataUpdate = { manager in
            guard let savedCocktailID = cocktailID,
                  let cocktail = manager.cocktails.first(where: { $0.id == savedCocktailID }) else {
                XCTFail("Could not find previously favorited cocktail")
                return
            }
            
            XCTAssertTrue(cocktail.isFavorite, "Favorite should persist across app launches")
            expectation2.fulfill()
        }
        
        newDataManager.loadData()
        wait(for: [expectation2], timeout: 5.0)
    }
    
    func testMultipleFavoritesPersistence() {
        let expectation1 = XCTestExpectation(description: "Initial load and multiple favorites")
        let expectation2 = XCTestExpectation(description: "Reload and verify multiple favorites persistence")
        
        var cocktailIDs: [String] = []
        var hasMadeFavorites = false
        
        // First load - make multiple cocktails favorite
        mockDelegate.onDataUpdate = { manager in
            let cocktails = manager.cocktails
            guard cocktails.count >= 3 else {
                XCTFail("Need at least 3 cocktails")
                return
            }
            
            if !hasMadeFavorites {
                // Make first 3 cocktails favorites
                hasMadeFavorites = true
                for i in 0..<3 {
                    manager.toggleFavorite(for: cocktails[i].id)
                    cocktailIDs.append(cocktails[i].id)
                }
            } else {
                expectation1.fulfill()
            }
        }
        
        dataManager.loadData()
        wait(for: [expectation1], timeout: 5.0)
        
        // Create new data manager with the same mock user defaults
        let newMockAPI = MockCocktailsAPI()
        let newDataManager = CocktailDataManager(cocktailsAPI: newMockAPI, userDefaults: mockUserDefaults)
        let newMockDelegate = MockCocktailDataManagerDelegate()
        newDataManager.delegate = newMockDelegate
        
        // Second load - verify all favorites persist
        newMockDelegate.onDataUpdate = { manager in
            let favorites = manager.cocktails.filter { $0.isFavorite }
            let favoriteIDs = Set(favorites.map { $0.id })
            let expectedIDs = Set(cocktailIDs)
            
            XCTAssertEqual(favoriteIDs, expectedIDs, "All favorites should persist")
            XCTAssertEqual(favorites.count, 3)
            
            expectation2.fulfill()
        }
        
        newDataManager.loadData()
        wait(for: [expectation2], timeout: 5.0)
    }
    
    func testFavoritesRemovedFromPersistence() {
        let expectation1 = XCTestExpectation(description: "Make and remove favorite")
        let expectation2 = XCTestExpectation(description: "Verify removal persists")
        
        var cocktailID: String?
        var hasPerformedToggles = false
        
        // First load - make favorite then remove it
        mockDelegate.onDataUpdate = { manager in
            guard let cocktail = manager.cocktails.first else {
                XCTFail("No cocktails loaded")
                return
            }
            
            if !hasPerformedToggles {
                cocktailID = cocktail.id
                hasPerformedToggles = true
                
                // Make favorite
                manager.toggleFavorite(for: cocktail.id)
                XCTAssertTrue(manager.cocktails.first { $0.id == cocktail.id }!.isFavorite)
                
                // Remove favorite
                manager.toggleFavorite(for: cocktail.id)
                XCTAssertFalse(manager.cocktails.first { $0.id == cocktail.id }!.isFavorite)
            } else {
                expectation1.fulfill()
            }
        }
        
        dataManager.loadData()
        wait(for: [expectation1], timeout: 5.0)
        
        // Create new data manager with the same mock user defaults
        let newMockAPI = MockCocktailsAPI()
        let newDataManager = CocktailDataManager(cocktailsAPI: newMockAPI, userDefaults: mockUserDefaults)
        let newMockDelegate = MockCocktailDataManagerDelegate()
        newDataManager.delegate = newMockDelegate
        
        // Second load - verify it's not favorite
        newMockDelegate.onDataUpdate = { manager in
            guard let savedCocktailID = cocktailID,
                  let cocktail = manager.cocktails.first(where: { $0.id == savedCocktailID }) else {
                XCTFail("Could not find cocktail")
                return
            }
            
            XCTAssertFalse(cocktail.isFavorite, "Favorite removal should persist")
            expectation2.fulfill()
        }
        
        newDataManager.loadData()
        wait(for: [expectation2], timeout: 5.0)
    }
    
    // MARK: - Edge Cases
    
    func testToggleFavoriteNonExistentCocktail() {
        let expectation = XCTestExpectation(description: "Load cocktails first")
        
        mockDelegate.onDataUpdate = { manager in
            expectation.fulfill()
        }
        
        dataManager.loadData()
        wait(for: [expectation], timeout: 5.0)
        
        // Now test with non-existent ID - this should not crash
        dataManager.toggleFavorite(for: "non-existent-id")
        
        // Verify no real cocktails were affected
        XCTAssertTrue(dataManager.cocktails.allSatisfy { !$0.isFavorite }, "No cocktails should be affected by toggling non-existent ID")
    }
    
    func testEmptyFilterResults() {
        // Test empty state filtering
        let emptyMockAPI = MockCocktailsAPI()
        emptyMockAPI.mockData = []
        let emptyMockUserDefaults = MockUserDefaults()
        let emptyDataManager = CocktailDataManager(cocktailsAPI: emptyMockAPI, userDefaults: emptyMockUserDefaults)
        
        XCTAssertEqual(emptyDataManager.filteredCocktails(for: .all).count, 0)
        XCTAssertEqual(emptyDataManager.filteredCocktails(for: .alcoholic).count, 0)
        XCTAssertEqual(emptyDataManager.filteredCocktails(for: .nonAlcoholic).count, 0)
    }

}