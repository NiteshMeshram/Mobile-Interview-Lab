import SwiftUI
import SwiftData


struct InspectionListView: View {
    // MARK: - ViewModel

    @StateObject private var viewModel: InspectionListViewModel
    @State private var showingInspectionForm = false
    @State private var selectedInspection: Inspection?
    @State private var showInspectionDetails = false
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
                meterRepository: meterRepository,
                videoStorageService: LocalVideoStorageService()
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
                    List(viewModel.inspections, id: \.id) { inspection in
                        HStack(alignment: .center, spacing: 12) {

                            VStack(alignment: .leading, spacing: 6) {
                                inspectionRowContent(inspection: inspection)

                                VideoPickerView(
                                    hasVideo: inspection.videoFilePath != nil,
                                    videoSyncStatus: inspection.videoSyncStatus
                                ) { videoURL in
                                    try await viewModel.attachVideo(
                                        inspectionID: inspection.id,
                                        sourceURL: videoURL
                                    )
                                }
                                .padding(.top, 8)
                            }

                            Spacer()

                            Button {
                                selectedInspection = inspection
                                showInspectionDetails = true
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .padding(12)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Inspections")
            .navigationDestination(isPresented: $showInspectionDetails) {
                if let selectedInspection {
                    InspectionDetailView(
                        inspection: selectedInspection,
                        videoStorageService: viewModel.videoStorageService,
                        onReplaceVideo: { videoURL in
                            try await viewModel.replaceVideo(
                                inspectionID: selectedInspection.id,
                                sourceURL: videoURL
                            )
                        }
                    )
                }
            }
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
        .padding(.top, 8)



    }

    @ViewBuilder
    func inspectionRowContent(inspection: Inspection) -> some View {
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
