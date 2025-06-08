import Foundation

@testable import CocktailBook
import CocktailsKit

final class MockCocktailsAPI: CocktailsAPI, @unchecked Sendable {
    var shouldFail = false
    var shouldReturnEmptyData = false

    func fetchCocktails() async throws -> Data {
        if shouldFail {
            throw CocktailsAPIError.unavailable
        }

        if shouldReturnEmptyData {
            return Data("[]".utf8)
        }

        // Return mock JSON data
        let mockCocktails = [
            MockData.mockMargarita,
            MockData.mockMojito,
            MockData.mockManhattan
        ]

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(mockCocktails)
            return jsonData
        } catch {
            throw CocktailsAPIError.unavailable
        }
    }
}
