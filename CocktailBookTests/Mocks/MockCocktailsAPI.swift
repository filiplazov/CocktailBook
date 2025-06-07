import Foundation
import Combine
@testable import CocktailBook

class MockCocktailsAPI: CocktailsAPI {
    var shouldFail = false
    var shouldReturnEmptyData = false
    
    var cocktailsPublisher: AnyPublisher<Data, CocktailsAPIError> {
        if shouldFail {
            return Fail(error: CocktailsAPIError.unavailable)
                .eraseToAnyPublisher()
        }
        
        if shouldReturnEmptyData {
            return Just(Data("[]".utf8))
                .setFailureType(to: CocktailsAPIError.self)
                .eraseToAnyPublisher()
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
            return Just(jsonData)
                .setFailureType(to: CocktailsAPIError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: CocktailsAPIError.unavailable)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchCocktails(_ handler: @escaping (Result<Data, CocktailsAPIError>) -> Void) {
        if shouldFail {
            handler(.failure(.unavailable))
            return
        }
        
        if shouldReturnEmptyData {
            handler(.success(Data("[]".utf8)))
            return
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
            handler(.success(jsonData))
        } catch {
            handler(.failure(.unavailable))
        }
    }
} 