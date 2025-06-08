@testable import CocktailBook
import XCTest

import CocktailsKit

class CocktailModelTests: XCTestCase {
    // MARK: - JSON Decoding Tests

    func testCocktailDecodingFromValidJSON() throws {
        let jsonString = createValidMargaritaJSON()
        let json = Data(jsonString.utf8)

        let cocktail = try JSONDecoder().decode(Cocktail.self, from: json)

        assertValidMargaritaProperties(cocktail)
        assertValidMargaritaIngredients(cocktail)
        XCTAssertFalse(cocktail.isFavorite) // Default value should be false
    }

    private func createValidMargaritaJSON() -> String {
        """
        {
            "id": "test-id-123",
            "name": "Margarita",
            "type": "alcoholic",
            "shortDescription": "A classic tequila cocktail",
            "longDescription": "The Margarita is a cocktail consisting of tequila, orange liqueur, and lime juice.",
            "preparationMinutes": 5,
            "imageName": "margarita_image",
            "ingredients": [
                {
                    "amount": "2 oz",
                    "name": "Tequila",
                    "metricAmount": "60 ml"
                },
                {
                    "amount": "1 oz",
                    "name": "Triple sec",
                    "metricAmount": "30 ml"
                },
                {
                    "amount": "1 oz",
                    "name": "Lime juice",
                    "metricAmount": "30 ml"
                },
                {
                    "amount": "",
                    "name": "Salt",
                    "metricAmount": ""
                }
            ]
        }
        """
    }

    private func assertValidMargaritaProperties(_ cocktail: Cocktail) {
        XCTAssertEqual(cocktail.id, "test-id-123")
        XCTAssertEqual(cocktail.name, "Margarita")
        XCTAssertEqual(cocktail.type, .alcoholic)
        XCTAssertEqual(cocktail.shortDescription, "A classic tequila cocktail")
        XCTAssertEqual(
            cocktail.longDescription,
            "The Margarita is a cocktail consisting of tequila, orange liqueur, and lime juice."
        )
        XCTAssertEqual(cocktail.preparationMinutes, 5)
        XCTAssertEqual(cocktail.imageName, "margarita_image")
    }

    private func assertValidMargaritaIngredients(_ cocktail: Cocktail) {
        XCTAssertEqual(cocktail.ingredients.count, 4)
        XCTAssertEqual(cocktail.ingredients[0].displayString, "2 oz Tequila")
        XCTAssertEqual(cocktail.ingredients[1].displayString, "1 oz Triple sec")
        XCTAssertEqual(cocktail.ingredients[2].displayString, "1 oz Lime juice")
        XCTAssertEqual(cocktail.ingredients[3].displayString, "Salt")
    }

    func testCocktailDecodingFromMinimalJSON() throws {
        let jsonString = """
        {
            "id": "minimal-test",
            "name": "Simple Drink",
            "type": "non-alcoholic",
            "shortDescription": "A simple drink",
            "longDescription": "Just a simple non-alcoholic drink",
            "preparationMinutes": 1,
            "imageName": "simple",
            "ingredients": [
                {
                    "amount": "1 cup",
                    "name": "Water",
                    "metricAmount": "240 ml"
                }
            ]
        }
        """
        let json = Data(jsonString.utf8)

        let cocktail = try JSONDecoder().decode(Cocktail.self, from: json)

        XCTAssertEqual(cocktail.type, .nonAlcoholic)
        XCTAssertEqual(cocktail.ingredients.count, 1)
        XCTAssertEqual(cocktail.ingredients.first?.displayString, "1 cup Water")
        XCTAssertFalse(cocktail.isFavorite)
    }

    func testCocktailDecodingWithInvalidType() throws {
        let jsonString = """
        {
            "id": "invalid-type-test",
            "name": "Invalid Drink",
            "type": "invalid-type",
            "shortDescription": "This should fail",
            "longDescription": "This should fail to decode",
            "preparationMinutes": 1,
            "imageName": "invalid",
            "ingredients": [
                {
                    "amount": "",
                    "name": "Nothing",
                    "metricAmount": ""
                }
            ]
        }
        """
        let json = Data(jsonString.utf8)

        XCTAssertThrowsError(try JSONDecoder().decode(Cocktail.self, from: json)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testCocktailDecodingWithMissingFields() throws {
        let jsonString = """
        {
            "id": "missing-fields-test",
            "name": "Incomplete Drink"
        }
        """
        let json = Data(jsonString.utf8)

        XCTAssertThrowsError(try JSONDecoder().decode(Cocktail.self, from: json)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    // MARK: - JSON Encoding Tests

    func testCocktailJSONEncoding() throws {
        var cocktail = Cocktail(
            id: "encode-test",
            name: "Test Cocktail",
            type: .alcoholic,
            shortDescription: "A test cocktail",
            longDescription: "This is a test cocktail for encoding",
            preparationMinutes: 10,
            imageName: "test_image",
            ingredients: [
                Ingredient(imperialAmount: "1 oz", name: "Test Ingredient 1", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "2 oz", name: "Test Ingredient 2", metricAmount: "60 ml")
            ]
        )

        // Set isFavorite to true - this should NOT be encoded
        cocktail.isFavorite = true

        let encoded = try JSONEncoder().encode(cocktail)
        let decoded = try JSONDecoder().decode(Cocktail.self, from: encoded)

        XCTAssertEqual(decoded.id, cocktail.id)
        XCTAssertEqual(decoded.name, cocktail.name)
        XCTAssertEqual(decoded.type, cocktail.type)
        XCTAssertEqual(decoded.shortDescription, cocktail.shortDescription)
        XCTAssertEqual(decoded.longDescription, cocktail.longDescription)
        XCTAssertEqual(decoded.preparationMinutes, cocktail.preparationMinutes)
        XCTAssertEqual(decoded.imageName, cocktail.imageName)
        XCTAssertEqual(decoded.ingredients.count, cocktail.ingredients.count)
        for (index, ingredient) in decoded.ingredients.enumerated() {
            XCTAssertEqual(ingredient.displayString, cocktail.ingredients[index].displayString)
        }

        // isFavorite should be false (default) in decoded version, not the true we set
        XCTAssertFalse(decoded.isFavorite)
    }

    // MARK: - CocktailType Tests

    func testCocktailTypeDisplayNames() {
        XCTAssertEqual(CocktailType.alcoholic.displayName, "Alcoholic")
        XCTAssertEqual(CocktailType.nonAlcoholic.displayName, "Non-Alcoholic")
    }

    func testCocktailTypeRawValues() {
        XCTAssertEqual(CocktailType.alcoholic.rawValue, "alcoholic")
        XCTAssertEqual(CocktailType.nonAlcoholic.rawValue, "non-alcoholic")
    }

    func testCocktailTypeDecoding() throws {
        let alcoholicData = Data("\"alcoholic\"".utf8)
        let nonAlcoholicData = Data("\"non-alcoholic\"".utf8)

        let alcoholicType = try JSONDecoder().decode(CocktailType.self, from: alcoholicData)
        let nonAlcoholicType = try JSONDecoder().decode(CocktailType.self, from: nonAlcoholicData)

        XCTAssertEqual(alcoholicType, .alcoholic)
        XCTAssertEqual(nonAlcoholicType, .nonAlcoholic)
    }

    // MARK: - FilterType Tests

    func testFilterTypeTitles() {
        XCTAssertEqual(FilterType.all.title, "All Cocktails")
        XCTAssertEqual(FilterType.alcoholic.title, "Alcoholic Cocktails")
        XCTAssertEqual(FilterType.nonAlcoholic.title, "Non-Alcoholic Cocktails")
    }

    func testFilterTypeAllCases() {
        let allCases = FilterType.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.all))
        XCTAssertTrue(allCases.contains(.alcoholic))
        XCTAssertTrue(allCases.contains(.nonAlcoholic))
    }

    // MARK: - Cocktail Creation Tests

    func testCocktailCreation() {
        let cocktail = Cocktail(
            id: "creation-test",
            name: "Creation Test Cocktail",
            type: .alcoholic,
            shortDescription: "Test creation",
            longDescription: "Testing cocktail creation",
            preparationMinutes: 15,
            imageName: "creation_test",
            ingredients: [
                Ingredient(imperialAmount: "1 oz", name: "Ingredient A", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "2 oz", name: "Ingredient B", metricAmount: "60 ml"),
                Ingredient(imperialAmount: "3 oz", name: "Ingredient C", metricAmount: "90 ml")
            ]
        )

        XCTAssertEqual(cocktail.id, "creation-test")
        XCTAssertEqual(cocktail.name, "Creation Test Cocktail")
        XCTAssertEqual(cocktail.type, .alcoholic)
        XCTAssertEqual(cocktail.shortDescription, "Test creation")
        XCTAssertEqual(cocktail.longDescription, "Testing cocktail creation")
        XCTAssertEqual(cocktail.preparationMinutes, 15)
        XCTAssertEqual(cocktail.imageName, "creation_test")
        XCTAssertEqual(cocktail.ingredients.count, 3)
        XCTAssertFalse(cocktail.isFavorite) // Default value
    }

    func testCocktailIdentifiable() {
        let cocktail = Cocktail(
            id: "identifiable-test",
            name: "Identifiable Test",
            type: .nonAlcoholic,
            shortDescription: "Test",
            longDescription: "Test",
            preparationMinutes: 1,
            imageName: "test",
            ingredients: [
                Ingredient(imperialAmount: "1", name: "Test", metricAmount: "1")
            ]
        )

        // Test that it conforms to Identifiable
        XCTAssertEqual(cocktail.id, "identifiable-test")
    }

    // MARK: - Performance Tests

    func testCocktailDecodingPerformance() throws {
        let jsonString = """
        {
            "id": "performance-test",
            "name": "Performance Test Cocktail",
            "type": "alcoholic",
            "shortDescription": "Performance testing",
            "longDescription": "This is a performance test for cocktail decoding",
            "preparationMinutes": 5,
            "imageName": "performance_test",
            "ingredients": [
                {
                    "amount": "1 oz",
                    "name": "Ingredient 1",
                    "metricAmount": "30 ml"
                },
                {
                    "amount": "2 oz",
                    "name": "Ingredient 2",
                    "metricAmount": "60 ml"
                },
                {
                    "amount": "3 oz",
                    "name": "Ingredient 3",
                    "metricAmount": "90 ml"
                }
            ]
        }
        """
        let json = Data(jsonString.utf8)

        measure {
            for _ in 0..<1_000 {
                do {
                    _ = try JSONDecoder().decode(Cocktail.self, from: json)
                } catch {
                    XCTFail("Decoding failed: \(error)")
                }
            }
        }
    }
}
