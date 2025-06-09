import Foundation
import CocktailsModels

public protocol CocktailsAPI: AnyObject, Sendable {
    func fetchCocktails() async throws -> [Cocktail]
} 