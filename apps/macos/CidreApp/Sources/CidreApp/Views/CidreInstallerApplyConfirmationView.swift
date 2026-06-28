import SwiftUI

public struct CidreInstallerApplyConfirmationView: View {
    @State private var confirmationInput: String = ""
    let onApply: (String) -> Void
    
    private let expectedString = "APPLY CIDRE STAGING TO SELECTED TARGET"
    
    public init(onApply: @escaping (String) -> Void) {
        self.onApply = onApply
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.orange)
                Text("Confirm Controlled Staging Apply")
                    .font(.title2)
                    .bold()
            }
            
            Text("This will write the validated Cidre rootfs files directly to the selected target partition.")
                .font(.body)
            
            Text("To proceed, type the exact confirmation string below:")
                .font(.headline)
            
            Text(expectedString)
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color(.windowBackgroundColor))
                .cornerRadius(6)
            
            TextField("Type confirmation string...", text: $confirmationInput)
                .font(.system(.body, design: .monospaced))
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Apply Controlled Staging") {
                    onApply(confirmationInput)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.orange)
                .disabled(confirmationInput != expectedString)
            }
        }
        .padding()
    }
}
