
import SwiftUI
import PhotosUI

struct VideoPickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoading = false
    @State private var successMessage: String?
    @State private var errorMessage: String?

    let onVideoSelected: (URL) async throws -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PhotosPicker(
                selection: $selectedItem,
                matching: .videos
            ) {
                if isLoading {
                    ProgressView("Importing video...")
                } else {
                    Label(
                        "Select Meter Video",
                        systemImage: "video"
                    )
                }
            }
            .disabled(isLoading)
            .onChange(of: selectedItem) { _, newItem in
                guard let newItem else { return }

                Task {
                    await importVideo(from: newItem)
                }
            }

            if let successMessage {
                Label(
                    successMessage,
                    systemImage: "checkmark.circle.fill"
                )
                .font(.caption)
                .foregroundStyle(.green)
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


    @MainActor
    private func importVideo(from item: PhotosPickerItem?) async {
        isLoading = true
        defer { isLoading = false }

        successMessage = nil
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

            successMessage = "Video saved successfully."
            errorMessage = nil

        } catch {
            print("Video import failed at: \(importStage)")
            print("Underlying error: \(error)")
            print("Localized error: \(error.localizedDescription)")

            errorMessage = "\(importStage): \(error.localizedDescription)"
            successMessage = nil
        }

        if let temporaryURL {
            try? FileManager.default.removeItem(at: temporaryURL)
        }

        selectedItem = nil
    }

}

