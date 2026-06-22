import Foundation

final class NoDefaultBootPolicyService {
    static let shared = NoDefaultBootPolicyService()
    private init() {}
}
