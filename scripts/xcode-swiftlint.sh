#!/bin/bash

# SwiftLint Build Phase Script for Xcode
# This script integrates SwiftLint into Xcode's build process
# Violations will appear as warnings/errors in the Xcode editor

# Only run SwiftLint for Debug builds to speed up Release builds
if [ "${CONFIGURATION}" = "Release" ]; then
    echo "Skipping SwiftLint for Release build"
    exit 0
fi

# Check if SwiftLint is installed
if which swiftlint >/dev/null; then
    echo "Running SwiftLint..."
    
    # Change to the project root directory
    cd "${SRCROOT}"
    
    # Run SwiftLint with Xcode-compatible output
    swiftlint lint --reporter xcode
    
    # Capture the exit code
    SWIFTLINT_EXIT_CODE=$?
    
    if [ $SWIFTLINT_EXIT_CODE -eq 0 ]; then
        echo "✅ SwiftLint completed successfully"
    elif [ $SWIFTLINT_EXIT_CODE -eq 2 ]; then
        echo "⚠️ SwiftLint found violations"
    else
        echo "❌ SwiftLint encountered an error"
    fi
    
    # Always exit with 0 to not break the build
    # Violations will show as warnings/errors in Xcode
    exit 0
else
    echo "warning: SwiftLint not installed. Install with: brew install swiftlint"
    echo "warning: Or visit https://github.com/realm/SwiftLint for installation instructions"
    exit 0
fi 