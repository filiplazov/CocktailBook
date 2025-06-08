import Foundation
import Combine

public protocol CocktailsAPI: AnyObject {
    
    var cocktailsPublisher: AnyPublisher<Data, CocktailsAPIError> { get }
    func fetchCocktails(_ handler: @escaping (Result<Data, CocktailsAPIError>) -> Void)
} 