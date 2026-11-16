
import Foundation

enum CustomerMapper {

    static func toEntity(_ customer: Customer) -> CustomerEntity {
        CustomerEntity(
            id: customer.id,
            name: customer.name,
            email: customer.email,
            address: customer.address
        )
    }

    static func toDomain(_ entity: CustomerEntity) -> Customer {
        Customer(
            id: entity.id,
            name: entity.name,
            email: entity.email,
            address: entity.address
        )
    }
}

