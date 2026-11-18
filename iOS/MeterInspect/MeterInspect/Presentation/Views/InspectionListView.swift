import SwiftUI
import SwiftData


struct InspectionListView: View {
    // MARK: - ViewModel

    @StateObject private var viewModel: InspectionListViewModel
    @State private var showingInspectionForm = false
    private let customerRepository: CustomerRepository
    private let meterRepository: MeterRepository

    // MARK: - Initialization

    init(
        repository: InspectionRepository,
        customerRepository: CustomerRepository,
        meterRepository: MeterRepository
    ) {
        self.customerRepository = customerRepository
        self.meterRepository = meterRepository

        _viewModel = StateObject(
            wrappedValue: InspectionListViewModel(
                repository: repository,
                customerRepository: customerRepository,
                meterRepository: meterRepository
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
                            Text(
                                viewModel.customer(for: inspection)?.name
                                ?? "Unknown Customer"
                            )
                            .font(.headline)

                            if let meter = viewModel.meter(for: inspection) {
                                Text("Meter: \(meter.meterNumber) · \(meter.meterType)")
                                    .font(.subheadline)
                            } else {
                                Text("Meter details unavailable")
                                    .font(.subheadline)
                            }

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
            InspectionFormView(
                viewModel: viewModel,
                customerRepository: customerRepository,
                meterRepository: meterRepository
            )
        }
        .task {
            await viewModel.loadInspections()
        }

    }

}

#Preview {
    let container = try! ModelContainer(
        for: Schema([
            InspectionEntity.self,
            CustomerEntity.self,
            MeterEntity.self
        ]),
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext

    InspectionListView(
        repository: SwiftDataInspectionRepository(
            modelContext: context
        ),
        customerRepository: SwiftDataCustomerRepository(
            modelContext: context
        ),
        meterRepository: SwiftDataMeterRepository(
            modelContext: context
        )
    )
}
