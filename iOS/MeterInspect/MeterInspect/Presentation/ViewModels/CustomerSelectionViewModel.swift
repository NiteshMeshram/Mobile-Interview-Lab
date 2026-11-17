import Foundation
import UIKit
import Combine

@MainActor
final class CustomerSelectionViewModel: ObservableObject {

    // MARK: - Properties
    @Published private(set) var customers: [Customer] = []
    @Published private(set) var selectedCustomer: Customer?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: CustomerRepository

    // MARK: - Initialization

    init(repository: CustomerRepository) {
        self.repository = repository
    }

    // MARK: - Actions

    func loadCustomers() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            customers = try await repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectCustomer(_ customer: Customer) {
        selectedCustomer = customer
    }

    func clearSelection() {
        selectedCustomer = nil
    }
}

