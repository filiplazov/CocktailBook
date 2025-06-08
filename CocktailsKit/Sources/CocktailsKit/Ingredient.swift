import Foundation

public struct Ingredient: Codable, Hashable, Identifiable, Sendable {
    public let id = UUID()
    public let imperialAmount: String
    public let name: String
    public let metricAmount: String
    
    public init(imperialAmount: String, name: String, metricAmount: String) {
        self.imperialAmount = imperialAmount
        self.name = name
        self.metricAmount = metricAmount
    }
    
    /// Returns the display string in imperial format (default)
    public var displayString: String {
        if imperialAmount.isEmpty {
            return name
        }
        return "\(imperialAmount) \(name)"
    }
    
    /// Returns the display string in metric format
    public var metricDisplayString: String {
        if metricAmount.isEmpty {
            return name
        }
        return "\(metricAmount) \(name)"
    }
    
    private enum CodingKeys: String, CodingKey {
        case imperialAmount = "amount", name, metricAmount
    }
} 