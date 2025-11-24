#!/bin/bash

# Git Merge Conflict Resolution Script
# This script resolves all merge conflicts by keeping your local changes (HEAD)

echo "🔧 Resolving Git merge conflicts..."
echo ""

# Step 1: Accept local version (--ours) for all conflicted files
echo "📝 Step 1: Accepting local changes for all conflicted files..."
git checkout --ours TravelMate.xcodeproj/project.pbxproj
git checkout --ours TravelMate/Models/Group.swift
git checkout --ours TravelMate/Scenes/CreateGroupViewController.swift
git checkout --ours TravelMate/Scenes/EditGroupViewController.swift
git checkout --ours TravelMate/Scenes/GroupDetailViewController.swift
git checkout --ours TravelMate/Scenes/GroupsViewController.swift
git checkout --ours TravelMate/Scenes/MainTabBarController.swift
git checkout --ours TravelMate/Scenes/VoyageListViewController.swift
git checkout --ours TravelMate/Services/GroupService.swift

echo "✅ Local changes accepted for all files"
echo ""

# Step 2: Mark all conflicts as resolved
echo "📝 Step 2: Marking all conflicts as resolved..."
git add TravelMate.xcodeproj/project.pbxproj
git add TravelMate/Models/Group.swift
git add TravelMate/Scenes/CreateGroupViewController.swift
git add TravelMate/Scenes/EditGroupViewController.swift
git add TravelMate/Scenes/GroupDetailViewController.swift
git add TravelMate/Scenes/GroupsViewController.swift
git add TravelMate/Scenes/MainTabBarController.swift
git add TravelMate/Scenes/VoyageListViewController.swift
git add TravelMate/Services/GroupService.swift

echo "✅ All conflicts marked as resolved"
echo ""

# Step 3: Commit the merge
echo "📝 Step 3: Committing the merge..."
git commit -m "Merge branch 'GestionVoyage' - kept local changes with language switcher and latest features"

echo "✅ Merge committed"
echo ""

# Step 4: Switch remote URL to SSH
echo "📝 Step 4: Switching remote URL to SSH..."
git remote set-url origin git@github.com:TravelMateEsprit/TravelMateIos.git

echo "✅ Remote URL updated to SSH"
echo ""

# Step 5: Push to GestionVoyage branch
echo "📝 Step 5: Pushing to GestionVoyage branch..."
git push origin GestionVoyage

echo ""
echo "🎉 All done! Your changes have been pushed to the GestionVoyage branch."
echo ""
echo "Summary:"
echo "  ✅ Resolved all merge conflicts (kept local changes)"
echo "  ✅ Committed the merge"
echo "  ✅ Updated remote URL to SSH"
echo "  ✅ Pushed to GestionVoyage branch"
