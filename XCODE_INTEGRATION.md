# Xcode SwiftLint Integration Guide

This guide shows you how to integrate SwiftLint into your Xcode build process so that violations appear as warnings and errors directly in the Xcode editor.

## 📋 Step-by-Step Instructions

### 1. Open Your Project in Xcode
Open `CocktailBook.xcodeproj` in Xcode.

### 2. Select the Target
1. In the Project Navigator, click on **CocktailBook** (the blue project icon at the top)
2. In the main area, select the **CocktailBook** target (under "TARGETS")

### 3. Add Build Phase
1. Click on the **"Build Phases"** tab at the top
2. Click the **"+"** button in the top-left of the Build Phases section
3. Select **"New Run Script Phase"**

### 4. Configure the Run Script Phase
1. **Rename the phase** (optional but recommended):
   - Expand the newly created "Run Script" section
   - Change the title from "Run Script" to **"SwiftLint"**

2. **Add the script**:
   Copy and paste this script into the script text area:

```bash
# SwiftLint Integration for Xcode
# Only run for Debug builds to speed up Release builds
if [ "${CONFIGURATION}" = "Release" ]; then
    echo "Skipping SwiftLint for Release build"
    exit 0
fi

# Check if SwiftLint is installed
if which swiftlint >/dev/null; then
    echo "Running SwiftLint..."
    swiftlint lint --reporter xcode
else
    echo "warning: SwiftLint not installed. Install with: brew install swiftlint"
fi
```

3. **Configure Input Files** (optional but recommended for better build performance):
   - Expand "Input Files" section
   - Click "+" and add: `$(SRCROOT)/.swiftlint.yml`

4. **Configure Output Files** (optional):
   - This helps Xcode understand when to re-run the script
   - You can leave this empty for SwiftLint

### 5. Position the Build Phase
**Important**: Drag the "SwiftLint" build phase to be **after** "Compile Sources" but **before** any other phases. This ensures SwiftLint runs on your source code after compilation.

## 🎯 What You'll See

After adding this build phase, when you build your project (`Cmd+B`):

### ✅ Successful Build with Violations
- **Yellow triangles** (⚠️) in Xcode for SwiftLint warnings
- **Red circles** (🛑) in Xcode for SwiftLint errors  
- Violations appear **inline** in your source code
- Build **succeeds** but shows issues in the Issue Navigator

### 📍 Example in Xcode
You'll see entries like:
```
⚠️ Line Length Violation: Line should be 150 characters or less
🛑 Force Unwrapping Violation: Force unwrapping should be avoided
```

### 🚀 Performance Features
- **Debug Only**: SwiftLint only runs for Debug builds (not Release)
- **Fast Execution**: Uses optimized reporter for Xcode integration
- **Non-Breaking**: Build continues even with SwiftLint violations

## 🔧 Alternative: Using the Script File

If you prefer to use the dedicated script file we created:

```bash
# Alternative script using our dedicated file
if [ -f "${SRCROOT}/scripts/xcode-swiftlint.sh" ]; then
    "${SRCROOT}/scripts/xcode-swiftlint.sh"
else
    echo "warning: SwiftLint script not found at scripts/xcode-swiftlint.sh"
fi
```

## 🛠 Troubleshooting

### SwiftLint Not Found
If you see "SwiftLint not installed" warnings:
```bash
# Install SwiftLint
brew install swiftlint

# Verify installation
which swiftlint
swiftlint version
```

### Configuration Not Found
If SwiftLint doesn't use your `.swiftlint.yml`:
- Ensure the file is in the project root
- Check that `${SRCROOT}` is set correctly in the build phase

### Too Many Violations
If you want to temporarily disable SwiftLint:
- Comment out the script in the build phase
- Or change the condition to skip all builds:
  ```bash
  if [ true ]; then
      echo "SwiftLint temporarily disabled"
      exit 0
  fi
  ```

## 📊 Current Status

With the SwiftLint integration, you'll now see:
- **Real-time feedback** on code style issues
- **Automatic enforcement** of your project's coding standards
- **Consistent code quality** across the team
- **Educational tool** for learning Swift best practices

The integration respects your existing `.swiftlint.yml` configuration and will help maintain the high code quality standards established in your CocktailBook project. 