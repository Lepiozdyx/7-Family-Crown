import SwiftData
import Foundation
import SwiftUI

@Model
class EmblemModel {
    var id = UUID()
    
    var color: [EmblemColors] // max 4
    var symbols: [EmblemSymbols] // max 4
    
    init(id: UUID = UUID(), color: [EmblemColors], symbols: [EmblemSymbols]) {
        self.id = id
        self.color = color
        self.symbols = symbols
    }
}

enum EmblemSymbols: String, CaseIterable, Codable {
    case blade, crown, lily, eagle, lion
    
    var asset: String {
        return self.rawValue
    }
}

enum EmblemColors: String, CaseIterable, Codable {
    case yellow, white, blue, green, black, red
    
    var asset: String {
        return "\(self.rawValue)Emblem"
    }
    
    var color: Color {
        switch self {
        case .yellow:
                .yellow
        case .white:
                .white
        case .blue:
                .blue
        case .green:
                .green
        case .black:
                .black
        case .red:
                .red
        }
    }
}
