import SwiftUI
import SwiftData

@main
struct MeterInspectApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            InspectionEntity.self,
            CustomerEntity.self,
            MeterEntity.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )

            try SampleDataSeeder.seedIfNeeded(
                context: container.mainContext
            )

            return container

        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            InspectionListView(
                repository: SwiftDataInspectionRepository(
                    modelContext: sharedModelContainer.mainContext
                )
            )
        }
        .modelContainer(sharedModelContainer)
    }
}
