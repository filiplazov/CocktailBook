#!/bin/bash

# SwiftLint Script for CocktailBook
# This script runs SwiftLint on the project source files

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🧹 Running SwiftLint for CocktailBook...${NC}"

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo -e "${RED}❌ SwiftLint is not installed. Please install it using:${NC}"
    echo "brew install swiftlint"
    exit 1
fi

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Change to project root
cd "$PROJECT_ROOT"

# Check if .swiftlint.yml exists
if [ ! -f ".swiftlint.yml" ]; then
    echo -e "${YELLOW}⚠️  No .swiftlint.yml configuration found, using default rules${NC}"
fi

# Run SwiftLint
echo -e "${GREEN}📁 Project root: $PROJECT_ROOT${NC}"
echo -e "${GREEN}🔍 Analyzing Swift files...${NC}"

# Run SwiftLint with the appropriate action
case "${1:-lint}" in
    "lint")
        echo -e "${GREEN}🔍 Linting Swift files...${NC}"
        swiftlint lint --reporter xcode
        ;;
    "fix")
        echo -e "${GREEN}🔧 Auto-fixing SwiftLint violations...${NC}"
        swiftlint --fix
        echo -e "${GREEN}✅ Auto-fix completed. Please review the changes.${NC}"
        ;;
    "version")
        echo -e "${GREEN}📋 SwiftLint version:${NC}"
        swiftlint version
        ;;
    *)
        echo -e "${YELLOW}Usage: $0 [lint|fix|version]${NC}"
        echo "  lint    - Run SwiftLint analysis (default)"
        echo "  fix     - Auto-fix SwiftLint violations"
        echo "  version - Show SwiftLint version"
        exit 1
        ;;
esac

echo -e "${GREEN}✅ SwiftLint completed successfully!${NC}" 