import Foundation

final class MutationExecutionViewModel: ObservableObject {
    @Published var execution: MutationExecutionResult?
    @Published var verification: MutationVerificationResult?
    @Published var reportMarkdown = ""
}
