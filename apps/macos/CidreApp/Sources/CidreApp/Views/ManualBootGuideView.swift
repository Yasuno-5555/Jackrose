import SwiftUI

struct ManualBootGuideView: View {
    let guide: ManualBootGuide?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Manual Boot Instructions")
                .font(.headline)
            if let g = guide {
                Text(g.guide)
                    .font(.body)
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
            } else {
                Text("Cidre is installed in manual boot mode.\n\nTo boot Cidre, shut down your Mac, hold the power button, and choose Cidre from Startup Options.\n\nYour default startup disk was not changed.")
                    .font(.body)
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
