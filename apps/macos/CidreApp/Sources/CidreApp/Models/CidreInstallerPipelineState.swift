import Foundation

public enum InstallerStep: Equatable {
    case welcome
    case artifactVerification
    case diskPlanning
    case finalReview
    case applyConfirmation
    case installing
    case firstBootHandoff
    case complete
    case failed(String)
}

public enum PipelineStatus: Equatable {
    case idle
    case running(String)
    case succeeded(String)
    case failed(String)
}
