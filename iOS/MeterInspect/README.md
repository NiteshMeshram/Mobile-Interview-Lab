# MeterInspect

**An Offline-First Native iOS Application for Electricity Meter Inspections**

MeterInspect is a SwiftUI-based iOS POC designed for field employees who inspect electricity meters, capture readings and videos, and synchronize inspection data when internet connectivity becomes available.

## Key Features

- Create and manage electricity meter inspections.
- Work without an internet connection.
- Store inspection data locally.
- Capture and store meter videos.
- Synchronize inspection metadata and videos independently.
- Retry failed uploads.
- Support background video uploads.

## Technology Stack

- Swift and SwiftUI
- MVVM + Clean Architecture
- Swift Concurrency
- SwiftData / SQLite (evaluation)
- URLSession and Background URLSession
- Network framework
- AVFoundation
- Cloudinary and hosted REST APIs
- XCTest and XCUITest

## Documentation

Detailed project documentation is maintained separately:

- [Project Overview](docs/01-Project-Overview.md)
- [Requirements](docs/02-Requirements.md)
- [Architecture](docs/03-Architecture.md)
- [Data Models](docs/04-Data-Models.md)
- [Offline-First Strategy](docs/05-Offline-First-Strategy.md)
- [Sync Engine](docs/06-Sync-Engine.md)
- [Video Upload](docs/07-Video-Upload.md)
- [Security](docs/08-Security.md)
- [Testing Strategy](docs/09-Testing-Strategy.md)
- [Development Roadmap](docs/10-Roadmap.md)
- [Interview Concept Mapping](docs/11-Interview-Concept-Mapping.md)

## Project Goal

Build a practical native iOS POC demonstrating offline-first architecture, reliable synchronization, media uploads, concurrency, persistence, and mobile application security.