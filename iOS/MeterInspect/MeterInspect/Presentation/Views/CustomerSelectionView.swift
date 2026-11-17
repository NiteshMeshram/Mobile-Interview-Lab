
import SwiftUI

struct CustomerSelectionView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: CustomerSelectionViewModel

    let onSelect: (Customer) -> Void

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Select Customer")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
        .task {
            await viewModel.loadCustomers()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading customers...")
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView {
                Label("Unable to Load Customers", systemImage: "exclamationmark.triangle")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Retry") {
                    Task {
                        await viewModel.loadCustomers()
                    }
                }
            }
        } else if viewModel.customers.isEmpty {
            ContentUnavailableView(
                "No Customers Found",
                systemImage: "person.crop.circle",
                description: Text("No customers are currently available.")
            )
        } else {
            customerList
        }
    }

    // MARK: - Customer List

    private var customerList: some View {
        List(viewModel.customers) { customer in
            Button {
                viewModel.selectCustomer(customer)
                onSelect(customer)
                dismiss()
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(customer.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(customer.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(customer.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
    }
}
