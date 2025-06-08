import Foundation

public actor FakeCocktailsAPI: CocktailsAPI {
    
    public enum CocktailAPIFailure: Sendable {
        case never
        case count(UInt)
    }
    
    private let failure: CocktailAPIFailure
    private var callCount: UInt = 0
    
    public init(withFailure failure: CocktailAPIFailure = .never) {
        self.failure = failure
    }
    
    private nonisolated func loadJSONData() throws -> Data {
        guard let file = Bundle.module.url(forResource: "sample", withExtension: "json") else {
            fatalError("sample.json can not be found")
        }
        guard let data = try? Data(contentsOf: file) else {
            fatalError("can not load contents of sample.json")
        }
        return data
    }
    
    public func fetchCocktails() async throws -> Data {
        // Simulate network delay (3 seconds)
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        if case let .count(maxFailures) = failure {
            if callCount < maxFailures {
                callCount += 1
                throw CocktailsAPIError.unavailable
            }
        }
        
        return try loadJSONData()
    }
} 