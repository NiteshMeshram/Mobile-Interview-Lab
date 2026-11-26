import Foundation
import Testing
@testable import MeterInspect

struct LocalVideoStorageServiceTests {

    // MARK: - Helpers

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        return directory
    }

    private func makeSourceVideo(in directory: URL) throws -> URL {
        let sourceURL = directory.appendingPathComponent("source.mov")
        let videoData = Data("sample-video-content".utf8)

        try videoData.write(to: sourceURL)

        return sourceURL
    }

    // MARK: - Save

    @Test
    func saveVideo_copiesFileAndReturnsRelativePath() async throws {
        let directory = try makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let sourceURL = try makeSourceVideo(in: directory)
        let storage = LocalVideoStorageService(
            applicationSupportURL: directory
        )
        let inspectionID = UUID()

        let relativePath = try await storage.saveVideo(
            from: sourceURL,
            for: inspectionID
        )

        #expect(relativePath == "MeterVideos/\(inspectionID.uuidString).mov")

        let savedURL = await storage.videoURL(for: relativePath)

        #expect(savedURL != nil)
        #expect(FileManager.default.fileExists(atPath: savedURL!.path))

        let savedData = try Data(contentsOf: savedURL!)
        #expect(savedData == Data("sample-video-content".utf8))
    }

    @Test
    func saveVideo_throwsWhenSourceFileDoesNotExist() async throws {
        let directory = try makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let missingURL = directory.appendingPathComponent("missing.mov")
        let storage = LocalVideoStorageService(
            applicationSupportURL: directory
        )

        await #expect(throws: LocalVideoStorageError.sourceFileNotFound) {
            try await storage.saveVideo(
                from: missingURL,
                for: UUID()
            )
        }
    }

    @Test
    func saveVideo_throwsWhenDestinationAlreadyExists() async throws {
        let directory = try makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let sourceURL = try makeSourceVideo(in: directory)
        let storage = LocalVideoStorageService(
            applicationSupportURL: directory
        )
        let inspectionID = UUID()

        _ = try await storage.saveVideo(
            from: sourceURL,
            for: inspectionID
        )

        await #expect(throws: LocalVideoStorageError.fileAlreadyExists) {
            try await storage.saveVideo(
                from: sourceURL,
                for: inspectionID
            )
        }
    }

    // MARK: - Retrieve

    @Test
    func videoURL_returnsNilWhenFileDoesNotExist() async throws {
        let directory = try makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let storage = LocalVideoStorageService(
            applicationSupportURL: directory
        )

        let result = await storage.videoURL(
            for: "MeterVideos/missing.mov"
        )

        #expect(result == nil)
    }

    @Test
    func videoURL_returnsNilForInvalidRelativePath() async throws {
        let directory = try makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let storage = LocalVideoStorageService(
            applicationSupportURL: directory
        )

        let result = await storage.videoURL(
            for: "../outside.mov"
        )

        #expect(result == nil)
    }

    // MARK: - Delete

    @Test
    func deleteVideo_removesStoredFile() async throws {
        let directory = try makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let sourceURL = try makeSourceVideo(in: directory)
        let storage = LocalVideoStorageService(
            applicationSupportURL: directory
        )

        let relativePath = try await storage.saveVideo(
            from: sourceURL,
            for: UUID()
        )

        let savedURL = await storage.videoURL(for: relativePath)
        #expect(savedURL != nil)

        try await storage.deleteVideo(at: relativePath)

        let deletedURL = await storage.videoURL(for: relativePath)
        #expect(deletedURL == nil)
    }

    @Test
    func deleteVideo_doesNotThrowWhenFileDoesNotExist() async throws {
        let directory = try makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let storage = LocalVideoStorageService(
            applicationSupportURL: directory
        )

        try await storage.deleteVideo(
            at: "MeterVideos/missing.mov"
        )
    }

    @Test
    func deleteVideo_throwsForInvalidRelativePath() async throws {
        let directory = try makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let storage = LocalVideoStorageService(
            applicationSupportURL: directory
        )

        await #expect(throws: LocalVideoStorageError.invalidPath) {
            try await storage.deleteVideo(at: "../outside.mov")
        }
    }
}


