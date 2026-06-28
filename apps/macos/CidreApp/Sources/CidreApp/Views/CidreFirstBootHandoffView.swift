import SwiftUI

public struct CidreFirstBootHandoffView: View {
    let handoff: FirstBootHandoff
    let onDone: () -> Void
    
    public init(handoff: FirstBootHandoff, onDone: @escaping () -> Void) {
        self.handoff = handoff
        self.onDone = onDone
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.green)
                Text("Cidre Staging Completed Successfully")
                    .font(.title2)
                    .bold()
            }
            
            Text("The installer MVP pipeline has completed. Target filesystem has been validated and unmounted safely.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            Group {
                Text("Initial Boot Expectations:")
                    .font(.headline)
                
                Text("- A manual boot is required. Boot policy and NVRAM default boot paths were NOT altered.")
                Text("- Select the newly staged Cidre partition target from the Startup Options menu manually.")
                Text("- Cidre first boot will automatically launch the desktop-first Welcome configuration wizard.")
            }
            
            Divider()
            
            Group {
                Text("Fallback & Recovery Strategy:")
                    .font(.headline)
                
                Text("- The macOS default boot selection remains untouched.")
                Text("- In case of boot failure, you can safely return to macOS by holding power button and choosing Macintosh HD.")
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Done", action: onDone)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
        }
        .padding()
    }
}
