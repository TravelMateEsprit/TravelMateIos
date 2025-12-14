#!/usr/bin/env python3
import os
import uuid

# Read the project file
project_path = "TravelMate.xcodeproj/project.pbxproj"
with open(project_path, 'r') as f:
    content = f.read()

# Files to add
files_to_add = [
    ("TravelMate/Utils/UIColor+Extensions.swift", "UIColor+Extensions.swift"),
    ("TravelMate/Utils/UIView+Extensions.swift", "UIView+Extensions.swift")
]

# Generate UUIDs for each file
file_refs = []
build_files = []

for file_path, file_name in files_to_add:
    file_ref_uuid = str(uuid.uuid4()).replace('-', '')[:24].upper()
    build_file_uuid = str(uuid.uuid4()).replace('-', '')[:24].upper()
    
    file_refs.append(f"\t\t{file_ref_uuid} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{file_name}\"; sourceTree = \"<group>\"; }};")
    build_files.append(f"\t\t{build_file_uuid} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {file_name} */; }};")
    
    print(f"Generated UUIDs for {file_name}:")
    print(f"  FileRef: {file_ref_uuid}")
    print(f"  BuildFile: {build_file_uuid}")

print("\n✅ Files need to be added manually to Xcode project")
print("Please open Xcode and add the files:")
for _, file_name in files_to_add:
    print(f"  - {file_name}")
