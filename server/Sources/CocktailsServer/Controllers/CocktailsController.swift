import Foundation
import Hummingbird
import Logging
import CocktailsModels

struct CocktailsController {
    let logger: Logger
    let cocktails: [Cocktail]
    
    init(logger: Logger) {
        self.logger = logger
        self.cocktails = CocktailsData.cocktails
        
        logger.info("Loaded \(cocktails.count) cocktails")
    }
    
    func addRoutes(to router: Router<some RequestContext>) {
        let api = router.group("api/v1")
        api.get("cocktails", use: getAllCocktails)
        api.get("cocktails/{id}", use: getCocktailById)
        api.get("cocktails/type/{type}", use: getCocktailsByType)
    }
    
    @Sendable
    func getAllCocktails(request: Request, context: some RequestContext) async throws -> [Cocktail] {
        logger.info("Fetching all cocktails", metadata: [
            "cocktails_count": "\(cocktails.count)"
        ])
        
        return cocktails
    }
    
    @Sendable
    func getCocktailById(request: Request, context: some RequestContext) async throws -> Cocktail? {
        guard let id = context.parameters.get("id") else {
            logger.warning("Missing ID parameter for cocktail request")
            throw HTTPError(.badRequest)
        }
        
        logger.info("Fetching cocktail by ID", metadata: [
            "cocktail_id": "\(id)"
        ])
        
        let result = cocktails.first { $0.id == id }
        
        if let cocktail = result {
            logger.info("Cocktail found", metadata: [
                "cocktail_id": "\(id)",
                "cocktail_name": "\(cocktail.name)"
            ])
        } else {
            logger.info("Cocktail not found", metadata: [
                "cocktail_id": "\(id)"
            ])
        }
        
        return result
    }
    
    @Sendable
    func getCocktailsByType(request: Request, context: some RequestContext) async throws -> [Cocktail] {
        guard let type = context.parameters.get("type") else {
            logger.warning("Missing type parameter for cocktail filter request")
            throw HTTPError(.badRequest)
        }
        
        logger.info("Filtering cocktails by type", metadata: [
            "filter_type": "\(type)"
        ])
        
        // Convert the type string to CocktailType enum
        let cocktailType: CocktailType
        switch type.lowercased() {
        case "alcoholic":
            cocktailType = .alcoholic
        case "non-alcoholic", "nonalcoholic":
            cocktailType = .nonAlcoholic
        default:
            logger.warning("Invalid cocktail type requested", metadata: [
                "filter_type": "\(type)",
                "error": "invalid_cocktail_type"
            ])
            throw HTTPError(.badRequest, message: "Invalid cocktail type. Use 'alcoholic' or 'non-alcoholic'")
        }
        
        let result = cocktails.filter { $0.type == cocktailType }
        
        logger.info("Cocktails filtered", metadata: [
            "filter_type": "\(type)",
            "cocktail_type": "\(cocktailType)",
            "cocktails_count": "\(result.count)"
        ])
        
        return result
    }
}