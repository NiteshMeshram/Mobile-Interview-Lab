import SwiftUI
import AVKit

struct InspectionVideoPlayerView: View {

    // MARK: - Properties
    let videoURL: URL

    // MARK: - Initialization

    // MARK: - Lifecycle

    var body: some View {
        VideoPlayer(
            player: AVPlayer(url: videoURL)
        )
        .frame(maxWidth: .infinity)
        .aspectRatio(16/9, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))

    }

    // MARK: - Actions

    // MARK: - Private Methods
}

