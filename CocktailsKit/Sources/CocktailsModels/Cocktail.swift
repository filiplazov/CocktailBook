import Foundation

public struct Cocktail: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let type: CocktailType
    public let shortDescription: String
    public let longDescription: String
    public let preparationMinutes: Int
    public let imageName: String
    public let ingredients: [Ingredient]

    public var isFavorite: Bool = false

    // Custom coding keys to exclude isFavorite from JSON
    private enum CodingKeys: String, CodingKey {
        case id, name, type, shortDescription, longDescription, preparationMinutes, imageName, ingredients
    }
    
    public init(
        id: String,
        name: String,
        type: CocktailType,
        shortDescription: String,
        longDescription: String,
        preparationMinutes: Int,
        imageName: String,
        ingredients: [Ingredient],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.shortDescription = shortDescription
        self.longDescription = longDescription
        self.preparationMinutes = preparationMinutes
        self.imageName = imageName
        self.ingredients = ingredients
        self.isFavorite = isFavorite
    }
}

extension Cocktail: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(CocktailType.self, forKey: .type)
        shortDescription = try container.decode(String.self, forKey: .shortDescription)
        longDescription = try container.decode(String.self, forKey: .longDescription)
        preparationMinutes = try container.decode(Int.self, forKey: .preparationMinutes)
        imageName = try container.decode(String.self, forKey: .imageName)
        ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        isFavorite = false // Default value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(shortDescription, forKey: .shortDescription)
        try container.encode(longDescription, forKey: .longDescription)
        try container.encode(preparationMinutes, forKey: .preparationMinutes)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(ingredients, forKey: .ingredients)
        // isFavorite is not encoded to JSON
    }
}

public enum CocktailType: String, Codable, CaseIterable, Sendable {
    case alcoholic = "alcoholic"
    case nonAlcoholic = "non-alcoholic"

    public var displayName: String {
        switch self {
        case .alcoholic:
            return "Alcoholic"
        case .nonAlcoholic:
            return "Non-Alcoholic"
        }
    }
}