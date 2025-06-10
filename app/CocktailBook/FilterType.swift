import Foundation

enum FilterType: CaseIterable, Sendable {
    case all
    case alcoholic
    case nonAlcoholic

    var title: String {
        switch self {
        case .all:
            return "All Cocktails"
        case .alcoholic:
            return "Alcoholic Cocktails"
        case .nonAlcoholic:
            return "Non-Alcoholic Cocktails"
        }
    }
}
