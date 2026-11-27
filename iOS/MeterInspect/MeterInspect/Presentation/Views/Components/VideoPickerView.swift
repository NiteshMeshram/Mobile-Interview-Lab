
import SwiftUI
import PhotosUI

struct VideoPickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoading = false
    @State private var errorMessage: String?
    let hasVideo: Bool
    let videoSyncStatus: VideoSyncStatus
    let onVideoSelected: (URL) async throws -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PhotosPicker(
                selection: $selectedItem,
                matching: .videos
            ) {
                showStatus()
            }
            .disabled(isLoading || hasVideo)
            .onChange(of: selectedItem) { _, newItem in
                guard let newItem else { return }

                Task {
                    await importVideo(from: newItem)
                }
            }

            if let errorMessage {
                Label(
                    errorMessage,
                    systemImage: "exclamationmark.circle.fill"
                )
                .font(.caption)
                .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    func showStatus() -> some View {
        if hasVideo {
            switch videoSyncStatus {
            case .pending:
                Label(
                    "Saved locally · Waiting to sync",
                    systemImage: "icloud.and.arrow.up"
                )
                .foregroundStyle(.orange)

            case .uploading:
                Label("Uploading video...", systemImage: "arrow.up.circle")

            case .failed:
                Label("Video sync failed", systemImage: "exclamationmark.circle")
                    .foregroundStyle(.red)

            case .uploaded:
                Label("Video synced", systemImage: "checkmark.icloud")
                    .foregroundStyle(.green)

            case .notRequired:
                Label("Video attached", systemImage: "video")
                    .foregroundStyle(.green)
            }
        } else if isLoading {
            ProgressView("Importing video...")
        } else {
            Label("Select Meter Video", systemImage: "video")
        }
    }


    @MainActor
    private func importVideo(from item: PhotosPickerItem?) async {
        isLoading = true
        defer { isLoading = false }

        errorMessage = nil

        var temporaryURL: URL?
        var importStage = "Loading video from Photos"

        do {
            guard let video = try await item?.loadTransferable(
                type: VideoTransferable.self
            ) else {
                errorMessage = "Unable to load selected video."
                return
            }

            temporaryURL = video.fileULR

            importStage = "Saving video to local storage"

            try await onVideoSelected(video.fileULR)

        } catch {
            print("Video import failed at: \(importStage)")
            print("Underlying error: \(error)")
            print("Localized error: \(error.localizedDescription)")

            errorMessage = "\(importStage): \(error.localizedDescription)"
        }

        if let temporaryURL {
            try? FileManager.default.removeItem(at: temporaryURL)
        }

        selectedItem = nil
    }

}

