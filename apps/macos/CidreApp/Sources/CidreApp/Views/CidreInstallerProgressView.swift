import SwiftUI

public struct CidreInstallerProgressView: View {
    let statusText: String
    
    public init(statusText: String) {
        self.statusText = statusText
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
            
            Text(statusText)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
