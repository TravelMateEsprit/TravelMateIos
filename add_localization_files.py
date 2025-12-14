#!/usr/bin/env python3
"""
Script to add localization files and new Swift files to TravelMate Xcode project
"""

import uuid
import sys

def generate_uuid():
    """Generate a unique 24-character uppercase hex string for Xcode"""
    return uuid.uuid4().hex[:24].upper()

def main():
    files_to_add = [
        ("TravelMate/Utils/AppLanguage.swift", "Utils"),
        ("TravelMate/Utils/LanguageManager.swift", "Utils"),
        ("TravelMate/Resources/fr.lproj/Localizable.strings", "Resources"),
        ("TravelMate/Resources/en.lproj/Localizable.strings", "Resources"),
    ]
    
    print("📦 New files to add to Xcode project:\n")
    
    for file_path, group in files_to_add:
        file_ref_uuid = generate_uuid()
        build_file_uuid = generate_uuid()
        
        print(f"File: {file_path}")
        print(f"  Group: {group}")
        print(f"  FileRef UUID: {file_ref_uuid}")
        print(f"  BuildFile UUID: {build_file_uuid}")
        print()
    
    print("\n⚠️  MANUAL STEPS REQUIRED:")
    print("\nPlease add these files to Xcode:")
    print("1. Open TravelMate.xcodeproj in Xcode")
    print("2. Right-click on 'Utils' folder → 'Add Files to \"TravelMate\"...'")
    print("   - Add AppLanguage.swift")
    print("   - Add LanguageManager.swift")
    print("3. Right-click on 'Resources' folder → 'Add Files to \"TravelMate\"...'")
    print("   - Add fr.lproj folder")
    print("   - Add en.lproj folder")
    print("4. Make sure to:")
    print("   ☑️  UNCHECK 'Copy items if needed'")
    print("   ☑️  SELECT 'Create groups'")
    print("   ☑️  CHECK 'TravelMate' target")
    print("5. Build the project: Cmd+B")
    print("\n✅ All files are ready to be added!")

if __name__ == "__main__":
    main()
