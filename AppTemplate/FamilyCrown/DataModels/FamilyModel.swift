import SwiftData
import Foundation

@Model
class FamilyModel {
    var id = UUID()
    
    var emblem: UUID
    var name: String
    var members: [FamilyMember]
    
    init(id: UUID = UUID(), emblem: UUID, name: String, members: [FamilyMember]) {
        self.id = id
        self.emblem = emblem
        self.name = name
        self.members = members
    }
}

@Model
class FamilyMember {
    var id = UUID()
    
    var title: Title
    var name: String
    var surname: String
    var role: String?
    var photo: Data?
    
    init(id: UUID = UUID(), title: Title, name: String, surname: String, role: String? = nil, photo: Data? = nil) {
        self.id = id
        self.title = title
        self.name = name
        self.surname = surname
        self.role = role
        self.photo = photo
    }
}

enum Title: String, CaseIterable, Codable {
    case king, queen, knight, chester, chronicler, royalWinemaker
}
