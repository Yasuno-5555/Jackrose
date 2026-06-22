import Foundation

final class InstallPayloadStageService {
    static let shared = InstallPayloadStageService()
    private init() {}

    func payload(repositoryPath: String) -> InstallPayload? {
        return nil
    }
}
