import Foundation
import Hummingbird
import Logging

struct LoggingMiddleware<Context: RequestContext>: RouterMiddleware {
    let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func handle(
        _ request: Request,
        context: Context,
        next: (Request, Context) async throws -> Response
    ) async throws -> Response {
        let startTime = Date()
        let userAgent = request.headers[.userAgent] ?? "unknown"
        let method = request.method.rawValue
        let path = request.uri.path
        
        // Log incoming request
        logger.info("Incoming request", metadata: [
            "user_agent": "\(userAgent)",
            "method": "\(method)",
            "path": "\(path)",
            "query": "\(request.uri.query ?? "")"
        ])
        
        do {
            let response = try await next(request, context)
            let duration = Date().timeIntervalSince(startTime)
            
            // Log successful response
            logger.info("Request completed", metadata: [
                "method": "\(method)",
                "path": "\(path)",
                "status": "\(response.status.code)",
                "duration_ms": "\(Int(duration * 1000))"
            ])
            
            return response
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            
            // Log error response
            if let httpError = error as? HTTPError {
                logger.warning("Request failed", metadata: [
                    "method": "\(method)",
                    "path": "\(path)",
                    "status": "\(httpError.status.code)",
                    "error": "\(httpError.status.reasonPhrase)",
                    "duration_ms": "\(Int(duration * 1000))"
                ])
            } else {
                logger.error("Request error", metadata: [
                    "method": "\(method)",
                    "path": "\(path)",
                    "error": "\(error.localizedDescription)",
                    "duration_ms": "\(Int(duration * 1000))"
                ])
            }
            
            throw error
        }
    }
}