# Git Merge Conflict Resolution Guide

## Current Status
You have merge conflicts in 9 files after pulling from the `GestionVoyage` branch.

## Quick Resolution (Automated)

Run this single command to resolve all conflicts automatically:

```bash
cd /Users/dhiabenchagra/Desktop/TravelMateIos
./resolve_conflicts.sh
```

This script will:
1. ✅ Accept your local changes for all conflicted files
2. ✅ Mark all conflicts as resolved
3. ✅ Commit the merge
4. ✅ Update remote URL to SSH
5. ✅ Push to GestionVoyage branch

---

## Manual Resolution (Step by Step)

If you prefer to do it manually, run these commands one by one:

### Step 1: Accept Local Changes (--ours)
```bash
cd /Users/dhiabenchagra/Desktop/TravelMateIos

git checkout --ours TravelMate.xcodeproj/project.pbxproj
git checkout --ours TravelMate/Models/Group.swift
git checkout --ours TravelMate/Scenes/CreateGroupViewController.swift
git checkout --ours TravelMate/Scenes/EditGroupViewController.swift
git checkout --ours TravelMate/Scenes/GroupDetailViewController.swift
git checkout --ours TravelMate/Scenes/GroupsViewController.swift
git checkout --ours TravelMate/Scenes/MainTabBarController.swift
git checkout --ours TravelMate/Scenes/VoyageListViewController.swift
git checkout --ours TravelMate/Services/GroupService.swift
```

### Step 2: Mark Conflicts as Resolved
```bash
git add TravelMate.xcodeproj/project.pbxproj
git add TravelMate/Models/Group.swift
git add TravelMate/Scenes/CreateGroupViewController.swift
git add TravelMate/Scenes/EditGroupViewController.swift
git add TravelMate/Scenes/GroupDetailViewController.swift
git add TravelMate/Scenes/GroupsViewController.swift
git add TravelMate/Scenes/MainTabBarController.swift
git add TravelMate/Scenes/VoyageListViewController.swift
git add TravelMate/Services/GroupService.swift
```

### Step 3: Commit the Merge
```bash
git commit -m "Merge branch 'GestionVoyage' - kept local changes with language switcher and latest features"
```

### Step 4: Switch Remote URL to SSH
```bash
git remote set-url origin git@github.com:TravelMateEsprit/TravelMateIos.git
```

### Step 5: Push to GestionVoyage Branch
```bash
git push origin GestionVoyage
```

---

## Verify Success

After running the commands, verify everything worked:

```bash
# Check status
git status

# Should show: "Your branch is up to date with 'origin/GestionVoyage'"
# Should show: "nothing to commit, working tree clean"

# Verify remote URL
git remote -v

# Should show: git@github.com:TravelMateEsprit/TravelMateIos.git
```

---

## What This Does

- **`git checkout --ours`**: Keeps YOUR local version of each file (discards remote changes)
- **`git add`**: Marks the conflicts as resolved
- **`git commit`**: Completes the merge with a commit message
- **`git remote set-url`**: Changes from HTTPS to SSH for easier pushing
- **`git push`**: Uploads your changes to GitHub

---

## Why Keep Local Changes?

Your local version includes:
- ✅ Language switcher (French/English)
- ✅ Latest insurance features
- ✅ Groups functionality
- ✅ Packs and messaging
- ✅ All recent bug fixes

The remote version is older and doesn't have these features.

---

## Need to Abort?

If you want to cancel the merge and start over:

```bash
git merge --abort
```

This will restore your repository to the state before the merge.
