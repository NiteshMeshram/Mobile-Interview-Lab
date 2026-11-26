import Foundation
import UIKit

protocol VideoStorageService: Sendable {

    /// Copies a captured video into permanent app storage.
    /// Returns the relative path used to retrieve the video later.
    func saveVideo(from sourceURL: URL, for inspectionID: UUID) async throws -> String

    /// Resolves a previously stored relative path into a file URL.
    func videoURL(for relativePath: String) async -> URL?
    /// Deletes a previously stored video.
    func deleteVideo(at relativePath: String) async throws
}

