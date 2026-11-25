import Foundation
import Testing
@testable import MeterInspect

@MainActor
struct CustomerSelectionViewModelTests {

    // MARK: - Test Helpers

    private func makeCustomer(
        id: UUID = UUID(),
        name: String = "Rahul Sharma"
    ) -> Customer {
        Customer(
            id: id,
            name: name,
            email: "rahul@example.com",
            address: "Nerul, Navi Mumbai"
        )
    }

    private func makeSUT(
        repository: MockCustomerRepository? = nil
    ) -> CustomerSelectionViewModel {
        let repository = repository ?? MockCustomerRepository()
        return CustomerSelectionViewModel(repository: repository)
    }

    // MARK: - Load Customers

    @Test
    func loadCustomers_loadsCustomersSuccessfully() async {
        let customer = makeCustomer()
        let repository = MockCustomerRepository()
        repository.seed([customer])

        let sut = makeSUT(repository: repository)

        await sut.loadCustomers()

        #expect(sut.customers.count == 1)
        #expect(sut.customers.first?.id == customer.id)
        #expect(sut.customers.first?.name == "Rahul Sharma")
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func loadCustomers_returnsEmptyListWhenNoCustomersExist() async {
        let sut = makeSUT()

        await sut.loadCustomers()

        #expect(sut.customers.isEmpty)
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func loadCustomers_setsErrorWhenRepositoryFails() async {
        let repository = MockCustomerRepository()
        repository.shouldThrowError = true

        let sut = makeSUT(repository: repository)

        await sut.loadCustomers()

        #expect(sut.customers.isEmpty)
        #expect(sut.errorMessage != nil)
        #expect(sut.isLoading == false)
    }

    @Test
    func loadCustomers_clearsPreviousErrorOnRetry() async {
        let repository = MockCustomerRepository()
        repository.shouldThrowError = true

        let sut = makeSUT(repository: repository)

        await sut.loadCustomers()
        #expect(sut.errorMessage != nil)

        repository.shouldThrowError = false
        repository.seed([makeCustomer()])

        await sut.loadCustomers()

        #expect(sut.errorMessage == nil)
        #expect(sut.customers.count == 1)
    }

    // MARK: - Customer Selection

    @Test
    func selectCustomer_updatesSelectedCustomer() {
        let customer = makeCustomer()
        let sut = makeSUT()

        sut.selectCustomer(customer)

        #expect(sut.selectedCustomer?.id == customer.id)
        #expect(sut.selectedCustomer?.name == customer.name)
    }

    @Test
    func clearSelection_removesSelectedCustomer() {
        let customer = makeCustomer()
        let sut = makeSUT()

        sut.selectCustomer(customer)
        sut.clearSelection()

        #expect(sut.selectedCustomer == nil)
    }

    @Test
    func selectCustomer_replacesPreviouslySelectedCustomer() {
        let firstCustomer = makeCustomer(name: "Rahul Sharma")
        let secondCustomer = makeCustomer(name: "Priya Patel")

        let sut = makeSUT()

        sut.selectCustomer(firstCustomer)
        sut.selectCustomer(secondCustomer)

        #expect(sut.selectedCustomer?.id == secondCustomer.id)
        #expect(sut.selectedCustomer?.name == "Priya Patel")
    }
}

