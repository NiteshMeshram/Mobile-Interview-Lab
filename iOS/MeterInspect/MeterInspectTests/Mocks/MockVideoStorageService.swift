import Foundation
@testable import MeterInspect

@MainActor
final class MockVideoStorageService: VideoStorageService {

    private(set) var saveVideoCallCount = 0
    private(set) var deleteVideoCallCount = 0

    var savedVideoPath = "MeterVideos/test-video.mov"
    var shouldThrowOnSave = false
    var shouldThrowOnDelete = false

    private(set) var deletedPaths: [String] = []
    private(set) var savedSourceURL: URL?
    private(set) var savedInspectionID: UUID?

    func saveVideo(
        from sourceURL: URL,
        for inspectionID: UUID
    ) async throws -> String {
        saveVideoCallCount += 1
        savedSourceURL = sourceURL
        savedInspectionID = inspectionID

        if shouldThrowOnSave {
            throw MockVideoStorageError.saveFailed
        }

        return savedVideoPath
    }

    func videoURL(for relativePath: String) async -> URL? {
        nil
    }

    func deleteVideo(at relativePath: String) async throws {
        deleteVideoCallCount += 1

        if shouldThrowOnDelete {
            throw MockVideoStorageError.deleteFailed
        }

        deletedPaths.append(relativePath)
    }
}

enum MockVideoStorageError: Error {
    case saveFailed
    case deleteFailed
}

