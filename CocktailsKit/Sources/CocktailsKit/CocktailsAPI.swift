import Foundation

public protocol CocktailsAPI: AnyObject, Sendable {
    func fetchCocktails() async throws -> Data
} 