import ArgumentParser
import Foundation
import Hummingbird
import Logging

@main
struct CocktailsServer: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"
    
    @Option(name: .shortAndLong)
    var port: Int = 8080
    
    func run() async throws {
        var logger = Logger(label: "CocktailsServer")
        logger.logLevel = .info
        
        let router = Router()
        
        // Add logging middleware
        router.add(middleware: LoggingMiddleware(logger: logger))
        
        router.get("/") { request, context -> String in
            return "Welcome to Cocktails Server! 🍹"
        }
        
        router.get("/health") { request, context -> String in
            return "OK"
        }
        
        let cocktailsController = CocktailsController(logger: logger)
        cocktailsController.addRoutes(to: router)
        
        let app = Application(
            router: router,
            configuration: .init(
                address: .hostname(hostname, port: port),
                serverName: "CocktailsServer"
            ),
            logger: logger
        )
        
        logger.info("🍹 CocktailsServer starting", metadata: [
            "hostname": "\(hostname)",
            "port": "\(port)",
            "server_url": "http://\(hostname):\(port)",
            "endpoints": "/, /health, /api/v1/cocktails, /api/v1/cocktails/{id}, /api/v1/cocktails/type/{type}"
        ])
        
        do {
            try await app.runService()
        } catch {
            logger.error("Server failed to start", metadata: [
                "error": "\(error.localizedDescription)"
            ])
            throw error
        }
    }
}