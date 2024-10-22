# FlipRSS

FlipRSS is a modern RSS reader for iOS that presents news articles in an engaging, card-based interface with smooth flip animations. The app supports RSS, Atom, and JSON Feed formats.

![Home](./Screenshots/home.png)


## Features

- **Interactive Card Interface**
  - Flip-based navigation between articles
  - Smooth 3D transition animations
  - Dynamic content layouts adapting to article content

- **Feed Management**
  - Support for RSS, Atom, and JSON Feed formats
  - Favorite feeds management
  - Automatic feed icon detection and display
  - Drag-and-drop feed reordering

- **Content Handling**
  - Intelligent image extraction from feeds
  - HTML content cleaning and formatting
  - Rich text support with custom styling
  - Safari integration for article viewing

- **Data Management**
  - CoreData persistence
  - Background feed refreshing
  - Efficient caching system
  - Optimized memory usage

## Architecture

### Core Components

- **Data Layer**
  - `DataController`: CoreData stack management
  - `FeedDataManager`: Central feed data coordination
  - `FeedParser`: Feed parsing and processing

- **View Layer**
  - `CardView`: Individual article presentation
  - `CardsStackView`: Card navigation and animation
  - `NewsItemView`: Article imagery and content display

- **View Models**
  - `FeedViewModel`: Feed data presentation logic
  - `CardFactory`: Card layout generation

### Dependencies

- **FeedKit**: RSS/Atom/JSON feed parsing
- **Kingfisher**: Image loading and caching
- **SwiftSoup**: HTML parsing and cleaning
- **NetworkImage**: Efficient network image handling

## Requirements

- iOS 17.5+
- macOS 14.5+
- Xcode 15.4+
- Swift 5.0+

## Setup

1. Clone the repository:
```bash
git clone [repository-url]
```

2. Install dependencies using Swift Package Manager:
```bash
xcode-select --install
```

3. Open `FlipRSS.xcodeproj` in Xcode

4. Build and run the project (⌘+R)

## Project Structure

```
FlipRSS/
├── Data & Models/           # Data management and model definitions
├── Views/                   # SwiftUI views and components
├── Extensions/             # Swift extension utilities
└── Resources/              # Asset catalogs and resources
```

## Key Features Implementation

### Card Animation System

The card system uses SwiftUI's animation system combined with Core Animation for smooth 3D transitions. Key components:

```swift
CardsStackView
├── Gesture handling for flips
├── 3D transformation calculations
└── State management for animations
```

### Feed Processing

The feed processing pipeline handles multiple feed formats:

```swift
FeedParser
├── RSS/Atom/JSON detection
├── HTML content cleaning
├── Image extraction
└── Metadata processing
```

## Contributing

1. Create a feature branch
2. Implement changes
3. Submit a pull request
4. Ensure CI passes
5. Request code review

## License

Copyright © 2024 Darian J. All rights reserved.