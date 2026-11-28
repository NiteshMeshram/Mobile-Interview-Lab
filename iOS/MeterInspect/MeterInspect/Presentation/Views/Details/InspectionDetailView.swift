import SwiftUI

struct InspectionDetailView: View {

    // MARK: - Properties
    let inspection: Inspection
    let videoStorageService: VideoStorageService
    let onReplaceVideo: (URL) async throws -> String
    @State private var displayedVideoPath: String?

    // MARK: - Initialization

    init(
        inspection: Inspection,
        videoStorageService: VideoStorageService,
        onReplaceVideo: @escaping (URL) async throws -> String
    ) {
        self.inspection = inspection
        self.videoStorageService = videoStorageService
        self.onReplaceVideo = onReplaceVideo
        _displayedVideoPath = State(
            initialValue: inspection.videoFilePath
        )
    }

    // MARK: - Lifecycle
    var body: some View {
        List {
            Section("Inspection Information") {
                detailRow(
                    title: "Inspection ID",
                    value: inspection.id.uuidString
                )

                detailRow(
                    title: "Reading",
                    value: inspection.readings.description
                )

                detailRow(
                    title: "Inspection Date",
                    value: inspection.inspectionDate.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )

                detailRow(
                    title: "Status",
                    value: inspection.status.rawValue
                )
            }

            Section("Synchronization Status") {
                detailRow(
                    title: "Metadata",
                    value: inspection.metadataSyncStatus.rawValue
                )

                detailRow(
                    title: "Video",
                    value: inspection.videoSyncStatus.rawValue
                )
            }
            previewVideoContent()
        }

        .navigationTitle("Inspection Details")
        .onAppear {
            print("DETAIL - Video Status:", inspection.videoSyncStatus)
        }
    }

    // MARK: - Actions

    // MARK: - Private Methods
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }

    @ViewBuilder
    func previewVideoContent() -> some View {
        Section ("Video") {
            if let videoFilePath = displayedVideoPath {
                InspectionVideoPlayerContainer(
                    videoFilePath: videoFilePath,
                    videoStorageService: videoStorageService
                )
                .id(videoFilePath)
            } else {
                Label(
                    "No video attached",
                    systemImage: "video.slash"
                )
                .foregroundStyle(.secondary)
            }

            VideoPickerView(
                hasVideo: inspection.videoFilePath != nil,
                videoSyncStatus: inspection.videoSyncStatus
            ) { videoURL in
                let newVideoPath = try await onReplaceVideo(videoURL)
                displayedVideoPath = newVideoPath
            }
        }

    }
}

