import SwiftUI

struct MutationConfirmationView: View {
    let requiredPhrase: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Type the destructive confirmation phrase exactly:")
                .font(.headline)
            Text(requiredPhrase)
                .font(.caption)
                .textSelection(.enabled)
            TextField(requiredPhrase, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}
