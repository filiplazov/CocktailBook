import Foundation

public struct Ingredient: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let imperialAmount: String
    public let name: String
    public let metricAmount: String
    
    public init(imperialAmount: String, name: String, metricAmount: String) {
        self.id = UUID()
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
        case imperialAmount, name, metricAmount
    }
    
    // Custom decoding to generate UUID for id field since it's not in JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.imperialAmount = try container.decode(String.self, forKey: .imperialAmount)
        self.name = try container.decode(String.self, forKey: .name)
        self.metricAmount = try container.decode(String.self, forKey: .metricAmount)
    }
    
    // Custom encoding to exclude id field from JSON
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imperialAmount, forKey: .imperialAmount)
        try container.encode(name, forKey: .name)
        try container.encode(metricAmount, forKey: .metricAmount)
        // id is not encoded to JSON
    }
} 