@testable import CocktailBook
import XCTest

class CocktailModelTests: XCTestCase {
    // MARK: - JSON Decoding Tests

    func testCocktailDecodingFromValidJSON() throws {
        let jsonString = """
        {
            "id": "test-id-123",
            "name": "Margarita",
            "type": "alcoholic",
            "shortDescription": "A classic tequila cocktail",
            "longDescription": "The Margarita is a cocktail consisting of tequila, orange liqueur, and lime juice.",
            "preparationMinutes": 5,
            "imageName": "margarita_image",
            "ingredients": ["Tequila", "Triple sec", "Lime juice", "Salt"]
        }
        """
        let json = Data(jsonString.utf8)

        let cocktail = try JSONDecoder().decode(Cocktail.self, from: json)

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
        XCTAssertEqual(cocktail.ingredients, ["Tequila", "Triple sec", "Lime juice", "Salt"])
        XCTAssertFalse(cocktail.isFavorite) // Default value should be false
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
            "ingredients": ["Water"]
        }
        """
        let json = Data(jsonString.utf8)

        let cocktail = try JSONDecoder().decode(Cocktail.self, from: json)

        XCTAssertEqual(cocktail.type, .nonAlcoholic)
        XCTAssertEqual(cocktail.ingredients.count, 1)
        XCTAssertEqual(cocktail.ingredients.first, "Water")
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
            "ingredients": ["Nothing"]
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
            ingredients: ["Test Ingredient 1", "Test Ingredient 2"]
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
        XCTAssertEqual(decoded.ingredients, cocktail.ingredients)

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
            ingredients: ["Ingredient A", "Ingredient B", "Ingredient C"]
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
            ingredients: ["Test"]
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
            "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
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
