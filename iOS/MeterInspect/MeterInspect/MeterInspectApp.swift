import SwiftUI
import SwiftData

@main
struct MeterInspectApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            InspectionEntity.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(
                modelContext: sharedModelContainer.mainContext
            )
        }
        .modelContainer(sharedModelContainer)
    }
}
