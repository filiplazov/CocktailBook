import Foundation
import CocktailsModels

public struct NetworkCocktailsAPI: CocktailsAPI, Sendable {
    
    private let baseURL: URL
    private let session: URLSession
    
    public init(baseURL: URL = URL(string: "http://localhost:8080")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        print("🌐 NetworkCocktailsAPI initialized with baseURL: \(baseURL)")
    }
    
    public func fetchCocktails() async throws -> [Cocktail] {
        let url = baseURL.appendingPathComponent("api/v1/cocktails")
        print("🌐 Making request to: \(url)")
        
        do {
            let (data, response) = try await session.data(from: url)
            print("🌐 Received response with \(data.count) bytes")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw CocktailsAPIError.invalidResponse
            }
            
            print("🌐 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ HTTP Error: \(httpResponse.statusCode)")
                throw CocktailsAPIError.unavailable
            }
            
            let decoder = JSONDecoder()
            let cocktails = try decoder.decode([Cocktail].self, from: data)
            print("🌐 Successfully decoded \(cocktails.count) cocktails")
            return cocktails
        } catch {
            print("❌ NetworkCocktailsAPI error: \(error)")
            throw error
        }
    }
}