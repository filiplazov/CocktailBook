# Cocktails Server

A Swift web server built with [Hummingbird](https://github.com/hummingbird-project/hummingbird) that provides a REST API for cocktail recipes.

## Features

- RESTful API for cocktail data
- Built with Swift and Hummingbird framework
- Shared domain models via CocktailsKit package
- OpenAPI 3.1 specification
- Health check endpoints
- Filter cocktails by type (alcoholic/non-alcoholic)
- **Comprehensive request logging** with structured metadata
- **Performance monitoring** with request duration tracking
- **Error tracking** with detailed failure information

## Installation

### Prerequisites

- Swift 5.9 or later
- macOS 10.15+ or Linux

### Building

```bash
cd server
swift build
```

## Usage

### Running the Server

```bash
swift run CocktailsServer
```

The server will start on `http://localhost:8080`

### Command Line Options

```bash
swift run CocktailsServer --help
```

Available options:
- `--hostname`: Server hostname (default: 127.0.0.1)
- `--port`: Server port (default: 8080)

## API Endpoints

### Health Check
- `GET /health` - Server health check

### Cocktails
- `GET /api/v1/cocktails` - Get all cocktails
- `GET /api/v1/cocktails/{id}` - Get cocktail by ID
- `GET /api/v1/cocktails/type/{type}` - Get cocktails by type (alcoholic/non-alcoholic)

## Documentation

- **OpenAPI Spec**: `openapi.yaml`
- **Paw Collection**: `api.paw` (for [Paw](https://paw.cloud) or [RapidAPI](https://paw.cloud))

## Architecture

The server uses shared domain models from the `CocktailsKit` package, ensuring consistency between the iOS app and server implementation. The domain models include:

- `Cocktail` - Main cocktail model with all recipe information
- `Ingredient` - Individual ingredient with imperial and metric amounts
- `CocktailType` - Enum for alcoholic/non-alcoholic classification

## Logging

The server provides comprehensive logging for monitoring and debugging:

### Request Logging
- **Incoming Requests**: Method, path, query parameters, user agent
- **Response Logging**: Status codes, response times in milliseconds
- **Error Tracking**: Detailed error information for failed requests

### Business Logic Logging
- **Cocktail Operations**: Fetch operations with counts and search parameters
- **Data Validation**: Invalid parameter warnings
- **Performance Metrics**: Request duration tracking

### Log Format
Logs use structured metadata for easy parsing and filtering:
```
2025-06-10T18:25:41+0200 info CocktailsServer : method=GET path=/api/v1/cocktails status=200 duration_ms=0 [CocktailsServer] Request completed
```

## Development

### Project Structure

```
server/
├── Sources/
│   └── CocktailsServer/
│       ├── CocktailsServer.swift      # Main entry point
│       ├── Controllers/
│       │   └── CocktailsController.swift  # API endpoints
│       ├── Data/
│       │   └── CocktailsData.swift    # Static cocktail data
│       ├── Middleware/
│       │   └── LoggingMiddleware.swift    # Request logging
│       └── Extensions/
│           └── Cocktail+Hummingbird.swift  # Hummingbird extensions
├── Package.swift
├── openapi.yaml
├── api.paw
└── README.md
```

### Dependencies

- [Hummingbird](https://github.com/hummingbird-project/hummingbird) - Web framework
- [ArgumentParser](https://github.com/apple/swift-argument-parser) - Command line parsing
- [CocktailsKit](../CocktailsKit) - Shared domain models

## License

MIT License