import SwiftUI

public struct HelloView: View {

    public init() {}

    @available(iOS 13.0, *)
    public var body: some View {
        VStack(spacing: 16) {
            Text("Hello World 👋")
                .font(.largeTitle)
                .fontWeight(.bold)

            if #available(iOS 17.0, *) {
                Text("This View comes from ExampleSPM")
                    .foregroundStyle(.secondary)
            } else {
                // Fallback on earlier versions
            }
        }
        .padding()
    }
}
