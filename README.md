# CloudKitSyncTest

#### A sample repository to showcase a problem with syncing an interactive widget with its main app on iOS

I created this app as a minimal code example to figure out a way for a widget and its app to use the same source of truth and thus always stay in sync. I use Core Data as the data store, specifically, an `NSPersistentCloudKitContainer` because I also want the changes to syynchronize across devices with iCloud. (This is a secondary objective though.)

### 🎯 Goal: Keep an interactive widget in sync with its app

#### Core Requirements:
* When the user taps a button in the widget, the change should be reflected in the app immediately (or once it comes to the foreground).
* When the user taps a button in the app, the change should be reflected in the widget immediately (or when it becomes visible).

#### Additional Requirement:
* Any change should also be reflected on any other devices where the same iCloud user is logged in with minimal latency. 
