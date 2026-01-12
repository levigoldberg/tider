# MarinaMatch

MarinaMatch is a SwiftUI iOS app that ranks nearby marinas by distance and free, global environmental risk signals (wind, currents, and sea-level forecast range). It uses only free, no-auth APIs and provides transparent scoring with adjustable weights.

## Quick start
1. Open `MarinaMatch.xcodeproj` in Xcode 15+.
2. Select the `MarinaMatch` scheme and run on an iOS 17+ simulator or device.

## Data sources (free, no-auth)
- OpenStreetMap Overpass API (marina discovery)
- Open-Meteo Weather API (10m wind speed)
- Open-Meteo Marine API (ocean current velocity, sea level height)

## Notes
- Sea level height and tide range are model forecasts; not depth and not for navigation.
- Boat specs are captured for display only and do not filter results.
- All raw values are stored in SI units and converted for display.

## Project structure
- `App/` app entry point
- `Models/` data models
- `Networking/` API clients
- `Services/` geocoding, caching, repositories
- `Scoring/` normalization and ranking
- `ViewModels/` MVVM view models
- `Views/` SwiftUI screens
- `Resources/` Info.plist and asset catalog
- `Tests/` unit tests
