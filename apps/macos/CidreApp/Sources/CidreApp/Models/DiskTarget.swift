import Foundation

struct DiskTarget: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let protected: Bool
    let mountPoint: String?
    let sizeBytes: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, category, protected
        case mountPoint = "mount_point"
        case sizeBytes = "size_bytes"
    }
}
