import Foundation

@testable import CocktailBook
import CocktailsKit

final class MockCocktailsAPI: CocktailsAPI, @unchecked Sendable {
    var shouldFail = false
    var shouldReturnEmptyData = false

    func fetchCocktails() async throws -> [Cocktail] {
        if shouldFail {
            throw CocktailsAPIError.unavailable
        }

        if shouldReturnEmptyData {
            return []
        }

        // Return mock cocktails directly
        return [
            MockData.mockMargarita,
            MockData.mockMojito,
            MockData.mockManhattan
        ]
    }
}
