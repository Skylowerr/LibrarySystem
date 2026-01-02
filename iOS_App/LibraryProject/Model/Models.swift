import Foundation

// MARK: - Category Model
struct Category: Codable, Identifiable {
    var id: String?
    var name: String
    var description: String
}

// MARK: - Book Model
struct Book: Codable, Identifiable {
    var id: String?
    var categoryID: String
    var title: String
    var author: String
    var isbn: String
    var isAvailable: Bool

    // API'den gelmediği için opsiyoneldir.
    var categoryName: String?
}
