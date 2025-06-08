import Foundation

public enum CocktailsAPIError: Error, LocalizedError {
    case unavailable
    
    public var errorDescription: String? {
        return "Unable to retrieve cocktails, API unavailable"
    }
} 