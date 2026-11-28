import SwiftUI

struct InspectionVideoPlayerContainer: View {

    // MARK: - Properties
    let videoFilePath: String
    let videoStorageService: VideoStorageService

    @State private var videoURL: URL?
    @State private var isLoading: Bool = true

    // MARK: - Initialization

    // MARK: - Lifecycle

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading video...")
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16/9, contentMode: .fit)
            } else if let videoURL {
                InspectionVideoPlayerView(videoURL: videoURL)
            } else {
                ContentUnavailableView(
                    "Video Unavailable",
                    systemImage: "video.slash",
                    description: Text("The locally stored video could not be found.")
                )
            }
        }
        .task(id: videoFilePath) {
            await loadVideo()
        }
    }
    // MARK: - Actions

    // MARK: - Private Methods
    @MainActor
    private func loadVideo() async {
        isLoading = true
        defer { isLoading = false }
        videoURL = await videoStorageService.videoURL(for: videoFilePath)
    }
}

