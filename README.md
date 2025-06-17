# Things4

This repository contains a multi-platform SwiftUI app inspired by "Things 3".
The code implements the data model, sync layer, core UI views, widgets and a
watchOS companion. Tests cover the model and workflow logic.

## Building

Use Xcode 15 or Swift Package Manager:

```bash
swift build
swift test
```

The `Things4` package exposes the core models and logic. `Sources/MyApp` contains
the iOS/macOS app, `Sources/WatchApp` the watchOS target and
`Sources/Widgets` the widgets.
