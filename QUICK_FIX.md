# Quick Fix: Add Missing Files to Xcode Project

## The Problem
The files `AppLanguage.swift` and `LanguageManager.swift` exist on disk but are not added to the Xcode project, causing build errors.

## The Solution (2 minutes)

### Option 1: Drag and Drop (Fastest)

1. **In Xcode**, locate the **Utils** folder in the Project Navigator (left sidebar)

2. **In Finder**, open a new window and navigate to:
   ```
   /Users/dhiabenchagra/Desktop/TravelMateIos/TravelMate/Utils/
   ```

3. **Drag these 2 files** from Finder into the **Utils** folder in Xcode:
   - `AppLanguage.swift`
   - `LanguageManager.swift`

4. **In the dialog that appears**, make sure:
   - ☑️ **CHECK** "Copy items if needed" (or leave unchecked, both work)
   - ☑️ **SELECT** "Create groups"
   - ☑️ **CHECK** "TravelMate" target
   - Click **Finish**

5. **Build the project**: `Cmd+B`

### Option 2: Right-Click Method

1. **In Xcode Project Navigator**, right-click on **Utils** folder
2. Select **"Add Files to 'TravelMate'..."**
3. Navigate to `TravelMate/Utils/`
4. Select both files:
   - `AppLanguage.swift`
   - `LanguageManager.swift`
5. Click **Add** (with same settings as above)
6. **Build**: `Cmd+B`

### Option 3: Add Localization Files (Optional, for later)

If you also want to add the localization files now:

1. Right-click on **Resources** folder
2. **"Add Files to 'TravelMate'..."**
3. Navigate to `TravelMate/Resources/`
4. Select:
   - `fr.lproj` folder
   - `en.lproj` folder
5. **Important**: Select **"Create folder references"** (not "Create groups")
6. Click **Add**

---

## Verify It Worked

After adding the files, you should see:
- ✅ `AppLanguage.swift` in Utils folder (blue icon)
- ✅ `LanguageManager.swift` in Utils folder (blue icon)
- ✅ Build succeeds with `Cmd+B`

Then run the app and test the language switcher!
