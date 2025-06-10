import CocktailsKit
import Foundation

@MainActor
final class CocktailListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var allCocktails: [Cocktail] = [] {
        didSet {
            updateFilteredCocktails()
        }
    }
    @Published var filteredCocktails: [Cocktail] = []
    @Published var filterType: FilterType = .all {
        didSet {
            updateFilteredCocktails()
        }
    }

    // MARK: - Private Properties
    private let cocktailsAPI: CocktailsAPI
    private let userDefaults: UserDefaultsProtocol
    private let favoritesKey = "FavoriteCocktailIDs"

    // MARK: - Computed Properties
    var favoriteCocktailIDs: [String] {
        userDefaults.array(forKey: favoritesKey) as? [String] ?? []
    }

    // MARK: - Initialization
    init(
        cocktailsAPI: CocktailsAPI = FakeCocktailsAPI(),
        userDefaults: UserDefaultsProtocol = UserDefaults.standard
    ) {
        self.cocktailsAPI = cocktailsAPI
        self.userDefaults = userDefaults
    }

    // MARK: - Public Methods

    /// Sets the filter type and triggers filtering
    func setFilterType(_ filterType: FilterType) {
        self.filterType = filterType
    }

    /// Loads all cocktails from the API
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            allCocktails = try await cocktailsAPI.fetchCocktails()
            updateCocktailFavoriteStatus()
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    /// Toggles the favorite status of a cocktail
    func toggleFavorite(cocktailID: String) {
        var favoriteIDs = favoriteCocktailIDs

        if favoriteIDs.contains(cocktailID) {
            favoriteIDs.removeAll { $0 == cocktailID }
        } else {
            favoriteIDs.append(cocktailID)
        }

        userDefaults.set(favoriteIDs, forKey: favoritesKey)

        // Update the displayed cocktails to reflect favorite status
        updateCocktailFavoriteStatus()
        updateFilteredCocktails()
    }

    /// Checks if a cocktail is marked as favorite
    func isFavorite(cocktailID: String) -> Bool {
        favoriteCocktailIDs.contains(cocktailID)
    }

    /// Returns the appropriate display string for an ingredient based on measurement system
    func ingredientDisplayString(for ingredient: Ingredient, measurementSystem: MeasurementSystem) -> String {
        switch measurementSystem {
        case .imperial:
            return ingredient.displayString
        case .metric:
            return ingredient.metricDisplayString
        }
    }
}

// MARK: - Private Methods

private extension CocktailListViewModel {
    func updateCocktailFavoriteStatus() {
        let favoriteIDs = favoriteCocktailIDs

        // Update allCocktails
        allCocktails = allCocktails.map { cocktail in
            var updatedCocktail = cocktail
            updatedCocktail.isFavorite = favoriteIDs.contains(cocktail.id)
            return updatedCocktail
        }
    }

    func handleError(_ error: Error) {
        if let apiError = error as? CocktailsAPIError {
            errorMessage = apiError.errorDescription
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    /// Updates filtered cocktails based on current filter type
    func updateFilteredCocktails() {
        filteredCocktails = filterCocktails(allCocktails, by: filterType)
    }

    /// Filters cocktails based on the given filter type
    func filterCocktails(_ allCocktails: [Cocktail], by filterType: FilterType) -> [Cocktail] {
        // Add favorite status to cocktails
        let cocktailsWithFavorites = allCocktails.map { cocktail in
            var mutableCocktail = cocktail
            mutableCocktail.isFavorite = isFavorite(cocktailID: cocktail.id)
            return mutableCocktail
        }

        // Filter by type
        let filteredByType: [Cocktail]
        switch filterType {
        case .all:
            filteredByType = cocktailsWithFavorites
        case .alcoholic:
            filteredByType = cocktailsWithFavorites.filter { $0.type == .alcoholic }
        case .nonAlcoholic:
            filteredByType = cocktailsWithFavorites.filter { $0.type == .nonAlcoholic }
        }

        // Sort with favorites first, then alphabetically within each section
        let favorites = filteredByType.filter { $0.isFavorite }.sorted { $0.name < $1.name }
        let nonFavorites = filteredByType.filter { !$0.isFavorite }.sorted { $0.name < $1.name }

        return favorites + nonFavorites
    }
}
