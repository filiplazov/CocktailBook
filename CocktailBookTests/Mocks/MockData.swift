@testable import CocktailBook
import Foundation

import CocktailsKit

struct MockData {
    static let mockMargarita = Cocktail(
        id: "1",
        name: "Mock Margarita",
        type: .alcoholic,
        shortDescription: "A classic tequila cocktail",
        longDescription: "A refreshing tequila-based cocktail with lime juice and triple sec.",
        preparationMinutes: 5,
        imageName: "https://example.com/margarita.jpg",
        ingredients: [
            Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml"),
            Ingredient(imperialAmount: "1 oz", name: "Lime juice", metricAmount: "30 ml"),
            Ingredient(imperialAmount: "1 oz", name: "Triple sec", metricAmount: "30 ml")
        ],
        isFavorite: false
    )

    static let mockMojito = Cocktail(
        id: "2",
        name: "Mock Mojito",
        type: .alcoholic,
        shortDescription: "A refreshing rum cocktail",
        longDescription: "A Cuban cocktail made with white rum, lime juice, mint, and soda water.",
        preparationMinutes: 7,
        imageName: "https://example.com/mojito.jpg",
        ingredients: [
            Ingredient(imperialAmount: "2 oz", name: "White rum", metricAmount: "60 ml"),
            Ingredient(imperialAmount: "1 oz", name: "Lime juice", metricAmount: "30 ml"),
            Ingredient(imperialAmount: "10", name: "Mint", metricAmount: "10"),
            Ingredient(imperialAmount: "4 oz", name: "Soda water", metricAmount: "120 ml")
        ],
        isFavorite: false
    )

    static let mockManhattan = Cocktail(
        id: "3",
        name: "Mock Manhattan",
        type: .alcoholic,
        shortDescription: "A classic whiskey cocktail",
        longDescription: "A sophisticated cocktail made with whiskey, sweet vermouth, and bitters.",
        preparationMinutes: 3,
        imageName: "https://example.com/manhattan.jpg",
        ingredients: [
            Ingredient(imperialAmount: "2 oz", name: "Whiskey", metricAmount: "60 ml"),
            Ingredient(imperialAmount: "0.5 oz", name: "Sweet vermouth", metricAmount: "15 ml"),
            Ingredient(imperialAmount: "2 dashes", name: "Bitters", metricAmount: "2 dashes")
        ],
        isFavorite: false
    )
}
