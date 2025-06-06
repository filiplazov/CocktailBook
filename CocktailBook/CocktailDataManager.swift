import Foundation

protocol CocktailDataManagerDelegate: AnyObject {
    func dataManagerDidUpdateCocktails(_ manager: CocktailDataManager)
    func dataManagerDidFailToLoadCocktails(_ manager: CocktailDataManager, error: Error)
}

class CocktailDataManager {
    
    weak var delegate: CocktailDataManagerDelegate?
    
    private let cocktailsAPI: CocktailsAPI
    private let favoritesKey = "FavoriteCocktailIDs"
    
    private var allCocktails: [Cocktail] = []
    private var favoriteCocktailIDs: Set<String> = []
    
    var cocktails: [Cocktail] {
        return allCocktails.map { cocktail in
            var updatedCocktail = cocktail
            updatedCocktail.isFavorite = favoriteCocktailIDs.contains(cocktail.id)
            return updatedCocktail
        }
    }
    
    init(cocktailsAPI: CocktailsAPI) {
        self.cocktailsAPI = cocktailsAPI
        loadFavorites()
    }
    
    func loadCocktails() {
        cocktailsAPI.fetchCocktails { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decodedCocktails = try JSONDecoder().decode([Cocktail].self, from: data)
                    self?.allCocktails = decodedCocktails
                    DispatchQueue.main.async {
                        self?.delegate?.dataManagerDidUpdateCocktails(self!)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.delegate?.dataManagerDidFailToLoadCocktails(self!, error: error)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.delegate?.dataManagerDidFailToLoadCocktails(self!, error: error)
                }
            }
        }
    }
    
    func filteredCocktails(for filterType: FilterType) -> [Cocktail] {
        let cocktailsToFilter = cocktails
        
        let filtered: [Cocktail]
        switch filterType {
        case .all:
            filtered = cocktailsToFilter
        case .alcoholic:
            filtered = cocktailsToFilter.filter { $0.type == .alcoholic }
        case .nonAlcoholic:
            filtered = cocktailsToFilter.filter { $0.type == .nonAlcoholic }
        }
        
        // Sort with favorites first, then alphabetically within each group
        return filtered.sorted { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite {
                return lhs.isFavorite
            }
            return lhs.name < rhs.name
        }
    }
    
    func toggleFavorite(for cocktailID: String) {
        if favoriteCocktailIDs.contains(cocktailID) {
            favoriteCocktailIDs.remove(cocktailID)
        } else {
            favoriteCocktailIDs.insert(cocktailID)
        }
        saveFavorites()
        delegate?.dataManagerDidUpdateCocktails(self)
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteCocktailIDs = Set(data)
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteCocktailIDs), forKey: favoritesKey)
    }
} 