import Foundation
import UIKit

struct LocalVideoStorageService : VideoStorageService {
    private let fileManager = FileManager.default
    private let directoryName = "MeterVideos"
    private let applicationSupportURL: URL?

    nonisolated init(applicationSupportURL: URL? = nil) {
        self.applicationSupportURL = applicationSupportURL
    }

    // MARK: - Save Video

    func saveVideo(from sourceURL: URL, for inspectionID: UUID) async throws -> String {
        guard fileManager.fileExists(atPath: sourceURL.path) else {
            throw LocalVideoStorageError.sourceFileNotFound
        }

        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: sourceURL.path, isDirectory: &isDirectory)

        guard !isDirectory.boolValue else {
            throw LocalVideoStorageError.invalidSourceFile
        }

        let directoryURL = try storageDirectory()
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let fileExtension = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension

        let fileName = "\(inspectionID.uuidString)_\(UUID().uuidString).\(fileExtension)"
        let destinationURL = directoryURL.appendingPathComponent(fileName)

        guard !fileManager.fileExists(atPath: destinationURL.path) else {
            throw LocalVideoStorageError.fileAlreadyExists
        }

        try fileManager.copyItem(at: sourceURL, to: destinationURL)

        return "\(directoryName)/\(fileName)"

    }

    // MARK: - Retrieve Video

    func videoURL(for relativePath: String) async -> URL? {
        guard let fileURL = resolveURL(for: relativePath),
              fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return fileURL
    }

    // MARK: - Delete Video

    func deleteVideo(at relativePath: String) async throws {
        guard let fileURL = resolveURL(for: relativePath) else {
            throw LocalVideoStorageError.invalidPath
        }

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return
        }

        try fileManager.removeItem(at: fileURL)
    }

    // MARK: - Private Helpers

    private func storageDirectory() throws -> URL {
        let baseURL = applicationSupportURL ?? fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first

        guard let baseURL else {
            throw LocalVideoStorageError.storageDirectoryUnavailable
        }

        return baseURL.appendingPathComponent(
            directoryName,
            isDirectory: true
        )
    }

    private func resolveURL(for relativePath: String) -> URL? {
        guard !relativePath.isEmpty,
              !relativePath.hasPrefix("/") else {
            return nil
        }

        let components = relativePath.split(separator: "/")

        guard components.count == 2,
              components.first == Substring(directoryName),
              !components.contains("..") else {
            return nil
        }

        guard let baseURL = applicationSupportURL ?? fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        let fileURL = baseURL
            .appendingPathComponent(relativePath)
            .standardizedFileURL

        let expectedDirectory = baseURL
            .appendingPathComponent(directoryName)
            .standardizedFileURL

        guard fileURL.path.hasPrefix(expectedDirectory.path + "/") else {
            return nil
        }

        return fileURL
    }

}

// MARK: - Errors

enum LocalVideoStorageError: Error, Equatable, LocalizedError {
    case sourceFileNotFound
    case invalidSourceFile
    case fileAlreadyExists
    case invalidPath
    case storageDirectoryUnavailable

    var errorDescription: String? {
        switch self {
        case .sourceFileNotFound:
            return "Selected source video does not exist."

        case .invalidSourceFile:
            return "Selected source is not a valid video file."

        case .fileAlreadyExists:
            return "A video already exists for this inspection."

        case .invalidPath:
            return "Invalid video storage path."

        case .storageDirectoryUnavailable:
            return "Application Support directory is unavailable."
        }
    }
}

