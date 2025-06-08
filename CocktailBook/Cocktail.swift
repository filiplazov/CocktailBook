import Foundation

import CocktailsKit

struct Cocktail: Identifiable {
    let id: String
    let name: String
    let type: CocktailType
    let shortDescription: String
    let longDescription: String
    let preparationMinutes: Int
    let imageName: String
    let ingredients: [Ingredient]

    var isFavorite: Bool = false

    // Custom coding keys to exclude isFavorite from JSON
    private enum CodingKeys: String, CodingKey {
        case id, name, type, shortDescription, longDescription, preparationMinutes, imageName, ingredients
    }
}

extension Cocktail: Codable {
    init(from decoder: Decoder) throws {
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

    func encode(to encoder: Encoder) throws {
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

enum CocktailType: String, Codable, CaseIterable {
    case alcoholic = "alcoholic"
    case nonAlcoholic = "non-alcoholic"

    var displayName: String {
        switch self {
        case .alcoholic:
            return "Alcoholic"
        case .nonAlcoholic:
            return "Non-Alcoholic"
        }
    }
}

enum FilterType: CaseIterable {
    case all
    case alcoholic
    case nonAlcoholic

    var title: String {
        switch self {
        case .all:
            return "All Cocktails"
        case .alcoholic:
            return "Alcoholic Cocktails"
        case .nonAlcoholic:
            return "Non-Alcoholic Cocktails"
        }
    }
}
