
import SwiftUI

struct MeterSelectionView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: MeterSelectionViewModel

    let customerID: UUID
    let onSelect: (Meter) -> Void

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Select Meter")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
        .task(id: customerID) {
            await viewModel.loadMeters(for: customerID)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading meters...")
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView {
                Label(
                    "Unable to Load Meters",
                    systemImage: "exclamationmark.triangle"
                )
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Retry") {
                    Task {
                        await viewModel.loadMeters(for: customerID)
                    }
                }
            }
        } else if viewModel.meters.isEmpty {
            ContentUnavailableView(
                "No Meters Found",
                systemImage: "gauge",
                description: Text(
                    "No meters are registered for this customer."
                )
            )
        } else {
            meterList
        }
    }

    // MARK: - Meter List

    private var meterList: some View {
        List(viewModel.meters) { meter in
            Button {
                viewModel.selectMeter(meter)
                onSelect(meter)
                dismiss()
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(meter.meterNumber)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(meter.meterType)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
    }
}

