import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct VideoTransferable: Transferable {
    let fileULR: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { received in
            let fileExtension = received.file.pathExtension.isEmpty
            ? "mov"
            : received.file.pathExtension

            let temporaryURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(fileExtension)

            try FileManager.default.copyItem(
                at: received.file,
                to: temporaryURL
            )

            return VideoTransferable(fileULR: temporaryURL)
        }
    }
}

