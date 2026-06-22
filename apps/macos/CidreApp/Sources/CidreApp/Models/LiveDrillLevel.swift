import Foundation

enum LiveDrillLevel: Int, CaseIterable, Identifiable {
    case noop = 0
    case metadata = 1
    case marker = 2
    case apfsVolume = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .noop: return "Level 0 No-op"
        case .metadata: return "Level 1 Metadata"
        case .marker: return "Level 2 Marker"
        case .apfsVolume: return "Level 3 APFS Volume"
        }
    }
}
