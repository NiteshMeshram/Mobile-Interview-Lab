//
import Foundation
import UIKit
import SwiftUI

struct InspectionFormView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: InspectionListViewModel

    @State private var meterID = ""
    @State private var readings = ""
    @State private var isSaving = false
    @State private var validationError: String?


    // MARK: - Initialization

    // MARK: - Lifecycle

    // MARK: - Actions

    // MARK: - Private Methods

    @MainActor
    private func saveInspection() async {
        guard let meterUUID = UUID(uuidString: meterID) else {
            validationError = "Invalid Meter ID"
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
                meterID: meterUUID,
                readings: readingValue
            )

            dismiss()

        } catch {
            validationError = "Failed to save inspection: \(error.localizedDescription)"

        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Meter Details") {
                    TextField("Meter ID", text: $meterID)
                        .keyboardType(.default)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Meter Reading", text: $readings)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Inspection")
            .navigationBarTitleDisplayMode(.inline)
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
        }
        

        .alert(
            "Unable to Save Inspection",
            isPresented: Binding(
                get: { validationError != nil },
                set: { if !$0 { validationError = nil } }
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

