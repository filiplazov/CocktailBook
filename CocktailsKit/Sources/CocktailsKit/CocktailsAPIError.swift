import Foundation

public enum CocktailsAPIError: Error, LocalizedError, Sendable {
    case unavailable
    case invalidResponse
    
    public var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Unable to retrieve cocktails, API unavailable"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
} 