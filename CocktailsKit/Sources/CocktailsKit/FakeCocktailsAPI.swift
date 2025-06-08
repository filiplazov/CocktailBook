import Foundation
import Combine

public class FakeCocktailsAPI: CocktailsAPI {
    
    public enum CocktailAPIFailure {
        case never
        case count(UInt)
    }
    
    private let queue = DispatchQueue(label: "CocktailsAPI")
    private let jsonData: Data
    private var failure: CocktailAPIFailure
    
    public init(withFailure failure: CocktailAPIFailure = .never) {
        guard let file = Bundle.module.url(forResource: "sample", withExtension: "json") else {
            fatalError("sample.json can not be found")
        }
        guard let data = try? Data(contentsOf: file) else {
            fatalError("can not load contents of sample.json")
        }
        jsonData = data
        self.failure = failure
    }
    
    public var cocktailsPublisher: AnyPublisher<Data, CocktailsAPIError> {
        if case let .count(count) = failure {
            failure = count - 1 == 0 ? .never : .count(count - 1)
            return Future<Data, CocktailsAPIError> { [weak self] promise in
                self?.queue.async {
                    sleep(3)
                    return promise(.failure(.unavailable))
                }
            }
            .eraseToAnyPublisher()
        }
        let data = jsonData
        return Future<Data, CocktailsAPIError> { [weak self] promise in
            self?.queue.async {
                sleep(3)
                return promise(.success(data))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func fetchCocktails(_ handler: @escaping (Result<Data, CocktailsAPIError>) -> Void) {
        if case let .count(count) = failure {
            failure = count - 1 == 0 ? .never : .count(count - 1)
            queue.async {
                sleep(3)
                handler(.failure(.unavailable))
            }
            return
        }
        let data = jsonData
        queue.async {
            sleep(3)
            handler(.success(data))
        }
    }
} 