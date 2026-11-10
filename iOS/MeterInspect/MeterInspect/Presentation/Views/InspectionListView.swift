import SwiftUI
import SwiftData

import SwiftUI

struct InspectionListView: View {
    // MARK: - ViewModel

    @StateObject private var viewModel: InspectionListViewModel
    @State private var showingInspectionForm = false

    // MARK: - Initialization

    init(repository: InspectionRepository) {
        _viewModel = StateObject(
            wrappedValue: InspectionListViewModel(
                repository: repository
            )
        )
    }


    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading inspections...")
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Unable to Load Inspections",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if viewModel.inspections.isEmpty {
                    ContentUnavailableView(
                        "No Inspections Yet",
                        systemImage: "gauge.with.needle",
                        description: Text(
                            "Your meter inspections will appear here."
                        )
                    )
                } else {
                    List(viewModel.inspections) { inspection in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Meter ID: \(inspection.meterID)")
                                .font(.headline)

                            Text("Reading: \(inspection.readings.description)")
                                .font(.subheadline)

                            Text(inspection.inspectionDate, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Inspections")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingInspectionForm = true
                    } label: {
                        Label("Add Inspection", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingInspectionForm) {
            InspectionFormView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadInspections()
        }

    }

}

#Preview {
    let container = try! ModelContainer(
        for: InspectionEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let repository = SwiftDataInspectionRepository(
        modelContext: container.mainContext
    )

    InspectionListView(repository: repository)
}
