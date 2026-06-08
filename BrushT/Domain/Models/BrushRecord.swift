import Foundation
import SwiftUI

struct BrushRecord: Identifiable, Codable, Equatable, Hashable {
    enum Kind: String, Codable {
        case brushing
        case note
    }

    let id: UUID
    let date: Date
    let duration: TimeInterval
    let timeOfDay: BrushingTimeOfDay
    let notes: String
    let kind: Kind
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval,
        timeOfDay: BrushingTimeOfDay,
        notes: String = "",
        kind: Kind = .brushing
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.timeOfDay = timeOfDay
        self.notes = notes
        self.kind = kind
    }

    var isBrushing: Bool {
        kind == .brushing
    }

    var isStandaloneNote: Bool {
        kind == .note
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case duration
        case timeOfDay
        case notes
        case kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        timeOfDay = try container.decode(BrushingTimeOfDay.self, forKey: .timeOfDay)
        notes = try container.decode(String.self, forKey: .notes)
        kind = try container.decodeIfPresent(Kind.self, forKey: .kind) ?? .brushing
    }
}
