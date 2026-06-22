import Foundation

enum HelperAuthorization {
    static func canExecute(_ request: HelperProtocol) -> Bool {
        guard request.dryRun else {
            guard let planID = request.planID, !planID.isEmpty else { return false }
            guard let confirmationToken = request.confirmationToken, !confirmationToken.isEmpty else { return false }
            return confirmationToken == "CIDRE EXECUTE \(planID)" || confirmationToken.count >= 32
        }
        return true
    }
}
