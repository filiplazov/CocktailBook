import Foundation
import CocktailsModels

public protocol CocktailsAPI: Sendable {
    func fetchCocktails() async throws -> [Cocktail]
} 