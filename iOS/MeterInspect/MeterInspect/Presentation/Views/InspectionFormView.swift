
import SwiftUI

struct InspectionFormView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: InspectionListViewModel

    @StateObject private var customerSelectionViewModel: CustomerSelectionViewModel
    @StateObject private var meterSelectionViewModel: MeterSelectionViewModel

    @State private var selectedCustomer: Customer?
    @State private var selectedMeter: Meter?

    @State private var showingCustomerSelection = false
    @State private var showingMeterSelection = false

    @State private var readings = ""
    @State private var isSaving = false
    @State private var validationError: String?

    // MARK: - Initialization

    init(
        viewModel: InspectionListViewModel,
        customerRepository: CustomerRepository,
        meterRepository: MeterRepository
    ) {
        self.viewModel = viewModel

        _customerSelectionViewModel = StateObject(
            wrappedValue: CustomerSelectionViewModel(
                repository: customerRepository
            )
        )

        _meterSelectionViewModel = StateObject(
            wrappedValue: MeterSelectionViewModel(
                repository: meterRepository
            )
        )
    }

    // MARK: - Actions

    @MainActor
    private func saveInspection() async {

        guard let selectedMeter else {
            validationError = "Please select a meter."
            return
        }

        guard let readingValue = Decimal(string: readings),
              readingValue > 0 else {
            validationError = "Invalid Reading Value"
            return
        }

        isSaving = true
        validationError = nil

        defer {
            isSaving = false
        }

        do {
            try await viewModel.createInspection(
                meterID: selectedMeter.id,
                readings: readingValue
            )

            dismiss()

        } catch {
            validationError = """
            Failed to save inspection: \(error.localizedDescription)
            """
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Customer Details

                Section("Customer Details") {

                    Button {
                        showingCustomerSelection = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Customer")

                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(selectedCustomer?.name ?? "Select Customer")
                                    .foregroundStyle(
                                        selectedCustomer == nil
                                        ? .secondary
                                        : .primary
                                    )
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // MARK: Meter Details

                Section("Meter Details") {

                    Button {
                        showingMeterSelection = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Meter")

                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(
                                    selectedMeter?.meterNumber
                                    ?? "Select Meter"
                                )
                                .foregroundStyle(
                                    selectedMeter == nil
                                    ? .secondary
                                    : .primary
                                )
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(selectedCustomer == nil)

                    if let selectedMeter {
                        LabeledContent(
                            "Meter Type",
                            value: selectedMeter.meterType
                        )
                    }
                }

                // MARK: Reading Details

                Section("Inspection Details") {

                    TextField(
                        "Meter Reading",
                        text: $readings
                    )
                    .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Inspection")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: Toolbar

            .toolbar {

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await saveInspection()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }

            // MARK: Customer Selection

            .sheet(isPresented: $showingCustomerSelection) {
                CustomerSelectionView(
                    viewModel: customerSelectionViewModel
                ) { customer in

                    selectedCustomer = customer

                    // Reset meter when customer changes.
                    selectedMeter = nil
                    meterSelectionViewModel.clearSelection()
                }
            }

            // MARK: Meter Selection

            .sheet(isPresented: $showingMeterSelection) {
                if let selectedCustomer {
                    MeterSelectionView(
                        viewModel: meterSelectionViewModel,
                        customerID: selectedCustomer.id
                    ) { meter in
                        selectedMeter = meter
                    }
                }
            }
        }

        // MARK: Error Alert

        .alert(
            "Unable to Save Inspection",
            isPresented: Binding(
                get: { validationError != nil },
                set: {
                    if !$0 {
                        validationError = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                validationError = nil
            }
        } message: {
            Text(validationError ?? "")
        }
    }
}

