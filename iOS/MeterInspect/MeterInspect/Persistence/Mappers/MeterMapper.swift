
import Foundation

enum MeterMapper {

    static func toEntity(_ meter: Meter) -> MeterEntity {
        MeterEntity(
            id: meter.id,
            meterNumber: meter.meterNumber,
            customerID: meter.customerID,
            meterType: meter.meterType
        )
    }

    static func toDomain(_ entity: MeterEntity) -> Meter {
        Meter(
            id: entity.id,
            meterNumber: entity.meterNumber,
            customerID: entity.customerID,
            meterType: entity.meterType
        )
    }
}

