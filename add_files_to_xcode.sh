#!/bin/bash

# Script to add new Swift files to Xcode project
# Run this from the TravelMateIos directory

echo "🔵 Adding new Swift files to TravelMate Xcode project..."
echo ""

# Files to add
FILES=(
    "TravelMate/Models/PackReservation.swift"
    "TravelMate/Models/Message.swift"
    "TravelMate/Services/ReservationService.swift"
    "TravelMate/Services/ChatService.swift"
    "TravelMate/Scenes/PacksBrowseViewController.swift"
    "TravelMate/Scenes/FavoritesViewController.swift"
    "TravelMate/Scenes/UserReservationsViewController.swift"
    "TravelMate/Scenes/AgencyReservationsViewController.swift"
    "TravelMate/Scenes/ConversationsListViewController.swift"
)

echo "📁 Files to add:"
for file in "${FILES[@]}"; do
    echo "  ✓ $file"
done

echo ""
echo "⚠️  MANUAL STEPS REQUIRED:"
echo ""
echo "Since Xcode is now open, please follow these steps:"
echo ""
echo "1️⃣  In Xcode, locate the 'Models' folder in the Project Navigator (left sidebar)"
echo "2️⃣  Right-click on 'Models' → 'Add Files to \"TravelMate\"...'"
echo "3️⃣  Navigate to TravelMate/Models/ and select:"
echo "    • PackReservation.swift"
echo "    • Message.swift"
echo "4️⃣  Make sure to:"
echo "    ☑️  UNCHECK 'Copy items if needed'"
echo "    ☑️  SELECT 'Create groups'"
echo "    ☑️  CHECK 'TravelMate' target"
echo "5️⃣  Click 'Add'"
echo ""
echo "6️⃣  Repeat the same for the 'Services' folder:"
echo "    • ReservationService.swift"
echo "    • ChatService.swift"
echo ""
echo "7️⃣  Repeat the same for the 'Scenes' folder:"
echo "    • PacksBrowseViewController.swift"
echo "    • FavoritesViewController.swift"
echo "    • UserReservationsViewController.swift"
echo "    • AgencyReservationsViewController.swift"
echo "    • ConversationsListViewController.swift"
echo ""
echo "8️⃣  Build the project: Cmd+B"
echo ""
echo "✅ OR use this shortcut:"
echo "   Select ALL 9 files at once (Cmd+Click), then drag them to Xcode!"
echo ""
