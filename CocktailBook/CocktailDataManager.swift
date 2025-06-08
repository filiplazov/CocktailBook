import Combine
import CombineSchedulers
import Foundation

import CocktailsKit

class CocktailDataManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var allCocktails: [Cocktail] = []
    @Published var filteredCocktails: [Cocktail] = []
    @Published var filterType: FilterType = .all

    // MARK: - Private Properties
    private let cocktailsAPI: CocktailsAPI
    private let userDefaults: UserDefaultsProtocol
    private let favoritesKey = "FavoriteCocktailIDs"
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var favoriteCocktailIDs: [String] {
        userDefaults.array(forKey: favoritesKey) as? [String] ?? []
    }

    // MARK: - Initialization
    init(
        cocktailsAPI: CocktailsAPI = FakeCocktailsAPI(),
        userDefaults: UserDefaultsProtocol = UserDefaults.standard,
        scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
    ) {
        self.cocktailsAPI = cocktailsAPI
        self.userDefaults = userDefaults
        self.scheduler = scheduler

        // Set up automatic filtering when allCocktails or filterType changes
        Publishers.CombineLatest($allCocktails, $filterType)
            .map { [weak self] allCocktails, filterType in
                self?.filterCocktails(allCocktails, by: filterType) ?? []
            }
            .assign(to: &$filteredCocktails)
    }

    // MARK: - Public Methods

    /// Sets the filter type and triggers filtering
    func setFilterType(_ filterType: FilterType) {
        self.filterType = filterType
    }

    /// Loads all cocktails from the API
    func loadData() {
        isLoading = true
        errorMessage = nil

        cocktailsAPI.cocktailsPublisher
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] data in
                    self?.parseCocktailsData(data)
                }
            )
            .store(in: &cancellables)
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

        // Trigger filtering update by re-assigning filterType
        let currentFilter = filterType
        filterType = currentFilter

        // Notify view to update by triggering objectWillChange
        objectWillChange.send()
    }

    /// Checks if a cocktail is marked as favorite
    func isFavorite(cocktailID: String) -> Bool {
        favoriteCocktailIDs.contains(cocktailID)
    }

    // MARK: - Private Methods

    private func parseCocktailsData(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            allCocktails = try decoder.decode([Cocktail].self, from: data)
            updateCocktailFavoriteStatus()
        } catch {
            handleError(CocktailsAPIError.unavailable)
        }
    }

    private func updateCocktailFavoriteStatus() {
        let favoriteIDs = favoriteCocktailIDs

        // Update allCocktails
        allCocktails = allCocktails.map { cocktail in
            var updatedCocktail = cocktail
            updatedCocktail.isFavorite = favoriteIDs.contains(cocktail.id)
            return updatedCocktail
        }
    }

    private func handleError(_ error: Error) {
        if let apiError = error as? CocktailsAPIError {
            errorMessage = apiError.errorDescription
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    /// Filters cocktails based on the given filter type
    private func filterCocktails(_ allCocktails: [Cocktail], by filterType: FilterType) -> [Cocktail] {
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
