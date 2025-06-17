## Project Plan: "Things 3" Clone

This project is divided into six sequential phases. Each phase builds upon the last. The coding LLM must complete and verify all steps within a phase before proceeding to the next. The accompanying **Reference Document** will serve as the single source of truth for expected functionality and architecture at each stage.

### **Phase 1: The Foundation - Data Model and Local Persistence**

**Goal:** Establish the core data structures of the entire application and ensure they can be saved locally on a single device. No UI is built yet, only the data layer.

*   **Step 1.1: Define Core Data Models**
    *   **What to Build:** Create the primary data models in Swift. These should be value types (`struct`) conforming to `Codable` and `Identifiable`.
        *   `ToDo`: Properties must include `id` (UUID), `title` (String), `notes` (String, supporting Markdown), `creationDate`, `modificationDate`, `completionDate` (optional Dates), `status` (Enum: `open`, `completed`, `canceled`), `startDate` (optional Date), `isEvening` (Bool), `deadline` (optional Date), `parentProjectID` (optional UUID), `parentAreaID` (optional UUID), `headingID` (optional UUID).
        *   `ChecklistItem`: Properties: `id` (UUID), `title` (String), `isCompleted` (Bool). A `ToDo` will have an array `[ChecklistItem]`.
        *   `Project`: Properties must include `id`, `title`, `notes`, `creationDate`, `modificationDate`, `completionDate`, `status`, `startDate`, `isEvening`, `deadline`, `parentAreaID`.
        *   `Area`: Properties: `id`, `title`, `creationDate`, `modificationDate`.
        *   `Heading`: Properties: `id`, `title`, `creationDate`, `modificationDate`, `completionDate`, `status`, `parentProjectID`.
        *   `Tag`: Properties: `id`, `name` (String).
        *   **Relationships:** Implement relationships using UUIDs. For example, a `ToDo` has an optional `parentProjectID`. Add a many-to-many relationship between `ToDo`/`Project`/`Area` and `Tag`.
    *   **How to Test:** Write unit tests to confirm each model can be instantiated correctly. Verify that all properties can be set and retrieved. Test the `Codable` conformance by encoding and decoding an instance of each model to/from JSON.

*   **Step 1.2: Implement Local Persistence Manager**
    *   **What to Build:** Create a singleton class, `PersistenceManager`, responsible for saving and loading the entire database of items (To-Dos, Projects, Areas, etc.) to and from the device's local storage. Use the device's file system to store the data as a single JSON file for simplicity at this stage.
    *   **How to Test:** Write unit tests for the `PersistenceManager`.
        1.  Create several mock items (e.g., 2 Areas, 3 Projects, 10 To-Dos).
        2.  Call a `save(items:)` method.
        3.  Confirm the data is written to a file.
        4.  Instantiate a new `PersistenceManager` and call a `load()` method.
        5.  Confirm the returned items exactly match the ones that were saved.
        6.  Test edge cases: saving an empty database, loading a non-existent file (should return an empty state).

### **Phase 2: Core UI and CRUD Functionality**

**Goal:** Build the main user interface and allow for basic Create, Read, Update, and Delete (CRUD) operations on To-Dos and Projects. The app will be functional offline on one device.

*   **Step 2.1: Build the Main App Shell and Sidebar Navigation**
    *   **What to Build:** Using SwiftUI, create the main three-pane layout for iPadOS/macOS (Sidebar, List, Detail) and the navigation stack for iOS.
        *   The sidebar must list the default lists: Inbox, Today, Upcoming, Anytime, Someday, Logbook.
        *   Below the default lists, display a list of all user-created `Area`s, with their nested `Project`s.
        *   Tapping a list in the sidebar should show its title in the main view, which will be populated in the next step.
    *   **How to Test:** Launch the app. Confirm the sidebar is visible on iPad/Mac and accessible via a root navigation view on iPhone. Confirm all default lists and mock Areas/Projects are displayed. Tapping list items should update the main view's title. Test on all target platforms (iOS, iPadOS, macOS) to ensure the adaptive layout works.

*   **Step 2.2: Implement the To-Do List View and Basic CRUD**
    *   **What to Build:**
        *   Create a `ToDoListView` that displays a list of `ToDo` items. Each row must show a checkbox and the `title`.
        *   When a list (e.g., Inbox) is selected in the sidebar, populate the `ToDoListView` with the relevant tasks from the `PersistenceManager`.
        *   Implement the "Add To-Do" functionality. A "+" button should add a new, empty `ToDo` to the currently viewed list.
        *   Implement completion: Tapping a checkbox should change the `ToDo`'s status to `completed`, add a `completionDate`, and visually update the row (strikethrough and faded).
        *   Implement deletion: Add a way to delete a To-Do (e.g., swipe-to-delete on iOS).
    *   **How to Test:**
        1.  Select the Inbox. Add several new to-dos. Verify they appear in the list.
        2.  Check off a to-do. Verify its appearance changes and its status is updated in the data model.
        3.  Delete a to-do. Verify it is removed from the list and the data model.
        4.  Restart the app. Confirm all changes were persisted locally and are reloaded correctly.

*   **Step 2.3: Implement the Detail/Editor View**
    *   **What to Build:** Create a view that appears when a `ToDo` is selected. This view must allow editing of all its properties as defined in the spec:
        *   Title (text field).
        *   Notes (a text editor that renders Markdown).
        *   Checklist (a sub-view to add/edit/complete checklist items).
        *   Tags (a UI to add/remove tags).
        *   Deadline (a date picker).
        *   Any changes made in this view must immediately save back to the `PersistenceManager`.
    *   **How to Test:**
        1.  Open a to-do. Change its title, add notes with Markdown (`**bold**`), add several checklist items, and assign a deadline.
        2.  Go back to the list view. Verify the title change is reflected.
        3.  Re-open the detail view. Confirm all changes, including notes and checklist state, were saved.
        4.  Restart the app and verify again.

### **Phase 3: Advanced Logic and Workflow**

**Goal:** Implement the "magic" of Things 3: its time-based lists, organizational structure, and repeating tasks.

*   **Step 3.1: Implement Scheduling Logic and Default Lists**
    *   **What to Build:** Create a `WorkflowEngine` that computes the content of the default lists based on the rules in the specification.
        *   **Today:** Contains to-dos with `startDate` of today or earlier, and any to-dos with a `deadline` of today.
        *   **Upcoming:** Contains to-dos with a `startDate` in the future, sorted chronologically.
        *   **Anytime:** Contains all `open` to-dos that are not in Today, Upcoming, or Someday.
        *   **Someday:** Contains to-dos explicitly moved here.
        *   **Logbook:** Contains all `completed` or `canceled` to-dos.
        *   Implement the UI for the date picker ("When" button) to set the `startDate` or move an item to Someday.
    *   **How to Test:**
        1.  Create a task. Verify it appears in Anytime.
        2.  Schedule it for today. Verify it moves to Today.
        3.  Schedule it for next week. Verify it moves to Upcoming.
        4.  Move it to Someday. Verify it only appears in the Someday list.
        5.  Complete the task. Verify it moves to the Logbook.
        6.  Create a task with a deadline for today but no start date. Verify it appears in both Anytime and Today.

*   **Step 3.2: Implement Projects, Areas, and Headings**
    *   **What to Build:**
        *   Allow creation and deletion of Projects and Areas from the sidebar.
        *   Implement the logic for assigning tasks to Projects/Areas.
        *   Inside a Project view, allow the creation of `Heading`s.
        *   Implement drag-and-drop to reorder to-dos and headings within a project. Dragging a heading should move all its associated to-dos.
        *   Display the project progress pie chart in the project view and sidebar. It must update in real-time as tasks are completed.
    *   **How to Test:**
        1.  Create an Area named "Work". Create a Project named "Website Launch" inside "Work".
        2.  Add several tasks to the project.
        3.  Create Headings like "Design" and "Development" and move tasks under them.
        4.  Drag the "Design" heading below "Development". Verify its tasks move with it.
        5.  Complete one task. Verify the progress pie updates from 0% to the correct percentage.
        6.  Complete the Project itself. Verify it moves to the Logbook.

*   **Step 3.3: Implement Repeating To-Dos**
    *   **What to Build:** This is a complex feature.
        1.  Create a `RepeatRule` model to store recurrence patterns (e.g., type: `on_schedule` vs `after_completion`; frequency: daily, weekly; interval: `2`; daysOfWeek: `[Mon, Wed]`).
        2.  Create a hidden "template" for each repeating to-do, which stores the base `ToDo` properties and its `RepeatRule`.
        3.  Implement a `RepeatingTaskEngine`. When a repeating task is completed, this engine should:
            *   Log the current instance.
            *   Generate the next instance based on the template and rule.
            *   Set the `startDate` of the new instance correctly.
        4.  Build the UI to create and edit these repeat rules.
    *   **How to Test:**
        1.  Create a task "Pay Rent" that repeats on the 1st of every month (fixed schedule). Complete it. Verify the next instance is created for the 1st of the next month.
        2.  Create a task "Water Plants" that repeats 3 days after completion. Complete it today. Verify the next instance is created with a `startDate` of 3 days from now.
        3.  Edit the template of a repeating task (e.g., change its title). Complete the current instance and verify the newly generated one has the updated title.

### **Phase 4: Cloud Sync**

**Goal:** Integrate CloudKit to enable seamless, real-time data synchronization across all the user's devices.

*   **Step 4.1: Migrate to CloudKit**
    *   **What to Build:**
        1.  Refactor the data models to be compatible with CloudKit. Each model (`ToDo`, `Project`, etc.) will correspond to a `CKRecord` type in the CloudKit schema.
        2.  Set up the CloudKit schema in the iCloud Dashboard with the required record types and fields.
        3.  Modify the `PersistenceManager` to be a `SyncManager`. Instead of writing to a local JSON file, it will now save and fetch `CKRecord`s from the user's private CloudKit database.
    *   **How to Test:** Run the app on a single device. Confirm that all previous CRUD functionality (creating, editing, completing tasks) now works by saving to and fetching from CloudKit instead of the local file. Use the CloudKit Dashboard to verify records are being created and updated correctly.

*   **Step 4.2: Implement Real-Time Sync and Subscriptions**
    *   **What to Build:**
        1.  Use `CKDatabaseSubscription` to subscribe to all changes in the private database.
        2.  Configure the app to receive silent push notifications from CloudKit when data changes on another device.
        3.  Implement a handler that, upon receiving a push, fetches the changes from CloudKit and updates the local UI in real-time.
        4.  Implement conflict resolution. CloudKit has built-in policies (e.g., "last writer wins"), which are sufficient for this project. Ensure the app gracefully handles these resolutions.
    *   **How to Test:**
        1.  Run the app on two devices (e.g., an iPhone and a Mac) signed into the same iCloud account.
        2.  Create a to-do on the iPhone. Verify it appears on the Mac within seconds.
        3.  Complete a task on the Mac. Verify it updates to a completed state on the iPhone.
        4.  Go offline on one device. Make several changes. Go back online. Verify the changes sync up correctly and any changes made on the other device are synced down.

### **Phase 5: Platform-Specific Features and Polish**

**Goal:** Implement the platform-specific UI/UX features that make Things 3 feel so powerful and native on each device.

*   **Step 5.1: Implement iOS/iPadOS Gestures and Magic Plus**
    *   **What to Build:**
        *   **Swipe Gestures:** Swipe-right on a task to open the "When" scheduler. Swipe-left to enter multi-select mode.
        *   **Magic Plus Button:** Implement the floating `+` button. Tapping adds a task. Dragging it allows inserting a task at a specific position. Dragging it to the left margin in a project creates a `Heading`.
    *   **How to Test:** On an iPhone/iPad:
        1.  Swipe right on a task; confirm the scheduler appears.
        2.  Swipe left; confirm the task is selected and a multi-select toolbar appears.
        3.  Drag the Magic Plus button between two tasks; confirm a new item is inserted there.
        4.  In a project, drag the Magic Plus to the left edge; confirm a new Heading is created.

*   **Step 5.2: Implement macOS Keyboard Shortcuts and Quick Entry**
    *   **What to Build:**
        *   **Keyboard Navigation:** Implement a full suite of keyboard shortcuts on macOS as detailed in the spec (`⌘N` for New To-Do, `⌘K` for Complete, etc.).
        *   **Quick Find / Type Travel:** In the main window, typing any character should immediately open a search/filter overlay that allows jumping to any list or tag.
        *   **Quick Entry:** Create a system-wide hotkey (e.g., `Ctrl+Space`) that opens a small, separate window for adding a task from anywhere in the OS. Implement the "autofill" feature to grab context from the foreground app (e.g., a URL from Safari).
    *   **How to Test:** On a Mac:
        1.  Press `⌘N`. Verify a new to-do is created. Press `⌘K`. Verify the selected to-do is completed.
        2.  With the main window focused, type the name of a project. Verify the Quick Find overlay appears and filters correctly.
        3.  Open Safari, then press the Quick Entry hotkey. Verify the panel appears with the page title and URL pre-filled. Add the task and confirm it appears in the Inbox.

*   **Step 5.3: Implement Widgets and Apple Watch App**
    *   **What to Build:**
        *   **Widgets:** Create Home Screen and Lock Screen widgets using WidgetKit.
            *   List Widget (configurable to show Today, a project, etc.).
            *   Progress Ring Widget (for Today's progress).
            *   New To-Do button widget.
            *   Ensure widgets are interactive (on supported OS versions) to allow completing tasks directly.
        *   **Apple Watch App:** Create a companion watchOS app that focuses on the Today list. It must show tasks, allow completion, and offer complications for the watch face. It should sync directly with CloudKit.
    *   **How to Test:**
        1.  Add a "Today" list widget to the iOS Home Screen. Verify it shows the correct tasks. Complete a task in the app and verify the widget updates.
        2.  Open the Apple Watch app. Verify it shows the Today list. Check off a task on the watch and confirm it syncs back to the iPhone/Mac.
        3.  Add the progress ring complication to a watch face. Verify it reflects the correct completion percentage for Today.

### **Phase 6: External Integrations and Finalizing**

**Goal:** Connect the app to the wider OS and external services, replicating the final set of features.

*   **Step 6.1: Implement Calendar and Reminders Integration**
    *   **What to Build:**
        *   **Calendar:** Implement read-only access to the user's Apple Calendar. Display calendar events in the Today and Upcoming lists, visually distinct from tasks. This must be configured on a per-device basis.
        *   **Reminders Import:** In Settings, allow the user to select an Apple Reminders list. Fetch items from this list and display them in the Inbox for manual import. Importing a task should create it in the app and delete it from Reminders.
    *   **How to Test:**
        1.  Enable Calendar integration. Add an event to your Apple Calendar for today. Open the app and verify the event appears at the top of the Today list.
        2.  Enable Reminders import, linked to a specific list. Use Siri to add a reminder to that list. Open the app and verify it appears in the Inbox, ready for import. Import it and confirm it's added to the app and removed from the Reminders app.

*   **Step 6.2: Implement Siri, Shortcuts, and URL Scheme**
    *   **What to Build:**
        *   **Siri:** Integrate with SiriKit to allow adding and viewing tasks via voice commands (e.g., "In [AppName], add milk to my shopping list").
        *   **Shortcuts:** Provide a rich library of actions for the Shortcuts app (Create To-Do, Find Items, Open List, etc.) as detailed in the spec.
        *   **URL Scheme:** Implement the `appname://` URL scheme for adding, showing, and searching for items. Ensure modification commands require an auth token for security.
    *   **How to Test:**
        1.  Use Siri: "Hey Siri, using [AppName], remind me to call John." Check the app to see if the task was created.
        2.  Create a Shortcut that finds all tasks tagged "urgent" and displays them in an alert. Run the shortcut and verify the output.
        3.  In a browser, open a URL like `appname:///add?title=Test%20URL`. Verify the app opens and a new to-do "Test URL" has been created in the Inbox.

*   **Step 6.3: Final Review and Polish**
    *   **What to Build:** Conduct a full audit of the app against the specification. Fix bugs, refine animations, improve performance, and ensure all text and UI elements match the clean, minimalist aesthetic of Things 3. Implement features like the Logbook's Trash functionality on Mac and the "Cancel" option for tasks.
    *   **How to Test:** Go through the entire provided specification, line by line, and tick off every single feature. Use the app on all platforms for a day to identify any workflow inconsistencies or rough edges. The app should feel indistinguishable from the original in terms of functionality.

***

## Reference Document for the Coding LLM

LLM, refer to this document as the "Source of Truth" at each stage. Your implementation must exactly match these specifications.

### `DataModel.md`

-   **ToDo**: `id`, `title`, `notes`, `creationDate`, `modificationDate`, `completionDate?`, `status` (Enum: `open`, `completed`, `canceled`), `startDate?`, `isEvening` (Bool), `deadline?`, `checklist` ([ChecklistItem]), `tagIDs` ([UUID]), `parentProjectID?`, `parentAreaID?`, `headingID?`.
-   **Project**: `id`, `title`, `notes`, `creationDate`, `modificationDate`, `completionDate?`, `status`, `startDate?`, `isEvening`, `deadline?`, `tagIDs`, `parentAreaID?`.
-   **Area**: `id`, `title`, `creationDate`, `modificationDate`, `tagIDs`.
-   **Heading**: `id`, `title`, `creationDate`, `modificationDate`, `completionDate?`, `status`, `parentProjectID`.
-   **Tag**: `id`, `name`.
-   **ChecklistItem**: `id`, `title`, `isCompleted`.
-   **RepeatRule**: `id`, `type` (Enum: `on_schedule`, `after_completion`), `frequency` (Enum: `daily`, `weekly`, `monthly`, `yearly`), `interval` (Int), `weekdays?` ([DayOfWeek]), `templateData` (JSON representation of the template ToDo/Project).

### `CoreLogic.md`

-   **List Computation:**
    -   **Today:** `(startDate <= today && status == .open) || (deadline == today && status == .open)`
    -   **Upcoming:** `startDate > today && status == .open`, sorted by `startDate`.
    -   **Anytime:** `status == .open && startDate == nil && somedayFlag == false`. Tasks in Today also appear here.
    -   **Someday:** `somedayFlag == true`.
    -   **Logbook:** `status == .completed || status == .canceled`, sorted by `completionDate` descending.
-   **Completion Logic:**
    -   Completing a Project with open tasks marks them as `canceled`.
    -   Canceling a Project marks all its open tasks as `canceled`.
    -   Completing a Heading marks all its open tasks as `canceled` and archives the group.
-   **Repeat Logic:**
    -   On completion of a repeating item, a new instance is generated from its template.
    -   `on_schedule`: Next `startDate` is calculated from the *previous* scheduled date.
    -   `after_completion`: Next `startDate` is calculated from the `completionDate` of the current instance.

### `UIComponents.md`

-   **Sidebar:** Displays Default Lists, then Areas > Projects hierarchy. Project rows must show a progress pie chart.
-   **Task Row:** Must contain a circular checkbox, title. Optional: tags, deadline flag (red), checklist progress icon. Completed tasks are greyed out with a strikethrough.
-   **Project View:** Lists tasks and headings. Drag-and-drop must be supported for reordering. A heading drag operation moves all child tasks.
-   **Magic Plus Button (iOS):** Floating circular `+` button. Drag-and-drop interaction for precise insertion.
-   **Quick Entry (macOS):** Separate, lightweight window invoked by a global hotkey. Must support autofill from the active application.
-   **Date Picker ("When"):** Must provide quick options for Today, This Evening, Tomorrow, Someday, and a full calendar picker. Must support natural language input.

### `SyncArchitecture.md`

-   **Provider:** Apple CloudKit.
-   **Database:** Private database for each user.
-   **Schema:** One-to-one mapping from `DataModel.md` to `CKRecord` types. Relationships are handled via `CKRecord.Reference` or UUID strings.
-   **Sync Trigger:** Real-time updates via `CKDatabaseSubscription` and silent push notifications.
-   **Conflict Resolution:** Default CloudKit policy (`ifServerRecordUnchanged` or "last writer wins"). The app must not crash or lose data during a conflict.

### `PlatformFeatures.md`

-   **iOS/iPadOS:** Multi-select via swipe-left or tap-and-drag on checkboxes. Context menus via long-press. Full Split View and Slide Over support on iPad.
-   **macOS:** Full keyboard navigation. `Type Travel` for quick filtering. Multiple window support. Menu bar commands.
-   **watchOS:** Standalone app syncing via CloudKit. Today-focused UI. Complications for progress, next tasks, and quick add.
-   **Widgets:** Interactive widgets for all platforms. Must be configurable to show any project/list and filter by tags.

### `APIs_Integrations.md`

-   **Calendar:** Read-only. Events appear in Today/Upcoming.
-   **Reminders:** Import-only from a user-selected list. Imported items are deleted from Reminders.
-   **Siri:** Must support creating and showing tasks/lists via donated intents.
-   **Shortcuts:** Provide actions for: `Create To-Do/Project/Heading`, `Find Items`, `Edit Items`, `Open List`, `Delete Items`, `Get Selected Items`, `Run URL`.
-   **URL Scheme:** `appname://`
    -   `add`: Creates a new item. Parameters: `title`, `notes`, `when`, `deadline`, `tags`, `list-id`, etc.
    -   `show`: Navigates to an item or list. Parameters: `id`, `query`.
    -   `update`: Modifies an existing item. Requires `id` and `auth-token`.
    -   `json`: Creates a complex hierarchy of items from a JSON payload.
