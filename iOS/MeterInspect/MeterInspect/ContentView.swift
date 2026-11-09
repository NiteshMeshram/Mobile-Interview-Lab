import SwiftUI
import SwiftData

import SwiftUI

struct ContentView: View {

    private let repository: SwiftDataInspectionRepository

    init(modelContext: ModelContext) {
        self.repository = SwiftDataInspectionRepository(
            modelContext: modelContext
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gauge.with.needle")
                .font(.largeTitle)
                .foregroundStyle(.tint)

            Text("MeterInspect")
                .font(.title)

            Text("Offline-First Meter Inspection")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    let container = try! ModelContainer(
        for: InspectionEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    ContentView(
        modelContext: container.mainContext
    )
}
