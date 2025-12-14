#!/bin/bash

# Script to verify and add localization files to Xcode project

echo "🔍 Checking localization setup..."
echo ""

# Check if .lproj folders exist
if [ -d "TravelMate/Resources/fr.lproj" ] && [ -d "TravelMate/Resources/en.lproj" ]; then
    echo "✅ Localization folders exist:"
    echo "   - fr.lproj (French)"
    echo "   - en.lproj (English)"
else
    echo "❌ Localization folders missing!"
    exit 1
fi

# Check if Localizable.strings files exist
if [ -f "TravelMate/Resources/fr.lproj/Localizable.strings" ] && [ -f "TravelMate/Resources/en.lproj/Localizable.strings" ]; then
    echo "✅ Localizable.strings files exist"
else
    echo "❌ Localizable.strings files missing!"
    exit 1
fi

echo ""
echo "📋 CRITICAL: Add localization files to Xcode project"
echo ""
echo "The .lproj folders are NOT in the Xcode project yet."
echo "This is why you're seeing raw keys instead of translated text."
echo ""
echo "TO FIX:"
echo "1. In Xcode, right-click on 'Resources' folder"
echo "2. Select 'Add Files to \"TravelMate\"...'"
echo "3. Navigate to TravelMate/Resources/"
echo "4. Select BOTH folders:"
echo "   ☑️  fr.lproj"
echo "   ☑️  en.lproj"
echo "5. IMPORTANT: Select 'Create folder references' (blue folders, not yellow)"
echo "6. Make sure 'TravelMate' target is checked"
echo "7. Click 'Add'"
echo "8. Build and run: Cmd+R"
echo ""
echo "After adding, the tab bar should show 'Accueil' instead of 'tab.home'"
echo ""
