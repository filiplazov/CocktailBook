@testable import CocktailBook
import Foundation

struct MockData {
    static let mockMargarita = Cocktail(
        id: "1",
        name: "Mock Margarita",
        type: .alcoholic,
        shortDescription: "A classic tequila cocktail",
        longDescription: "A refreshing tequila-based cocktail with lime juice and triple sec.",
        preparationMinutes: 5,
        imageName: "https://example.com/margarita.jpg",
        ingredients: ["Tequila", "Lime juice", "Triple sec"],
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
        ingredients: ["White rum", "Lime juice", "Mint", "Soda water"],
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
        ingredients: ["Whiskey", "Sweet vermouth", "Bitters"],
        isFavorite: false
    )
}
