import Foundation

final class MutationPlanViewModel: ObservableObject {
    @Published var plan: MutationPlan?
    @Published var signature: MutationPlanSignature?
    @Published var confirmation: MutationConfirmation?
}
