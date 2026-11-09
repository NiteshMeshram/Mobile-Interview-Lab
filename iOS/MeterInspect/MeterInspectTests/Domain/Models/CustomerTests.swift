import Testing
import Foundation
@testable import MeterInspect

struct CustomerTests {

    @Test
    func customerInitialization() {
        let id = UUID()

        let customer = Customer(
            id: id,
            name: "Rahul Sharma",
            email: "test@gmail.com",
            address: "Navi Mumbai"
        )

        #expect(customer.id == id)
        #expect(customer.name == "Rahul Sharma")
        #expect(customer.email == "test@gmail.com")
        #expect(customer.address == "Navi Mumbai")
    }
}
