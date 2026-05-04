import Foundation

struct Restaurant: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var cuisine: String
    var location: String
    var visitDate: Date
    var rating: Int
    var notes: String
    var photoFileNames: [String]

    init(
        id: UUID = UUID(),
        name: String,
        cuisine: String,
        location: String,
        visitDate: Date,
        rating: Int,
        notes: String,
        photoFileNames: [String] = []
    ) {
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.location = location
        self.visitDate = visitDate
        self.rating = rating
        self.notes = notes
        self.photoFileNames = photoFileNames
    }
}
