//
//  TaskColor.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/20/25.
//

import Foundation
import SwiftUICore

enum TaskColor: Codable, CaseIterable, Equatable, Identifiable {
    case yellow
    case purple
    case red
    case teal
    case orange
    case blue
    case green
    case pink
    case peach
    case lime
    case steelBlue
    case brown
    case sand
    case custom(String)
    
    var id: String {
        switch self {
        case .yellow: return "yellow"
        case .purple: return "purple"
        case .red: return "red"
        case .teal: return "teal"
        case .orange: return "orange"
        case .blue: return "blue"
        case .green: return "green"
        case .pink: return "pink"
        case .peach: return "peach"
        case .lime: return "lime"
        case .steelBlue: return "steelBlue"
        case .brown: return "brown"
        case .sand: return "sand"
        case .custom(let color): return "custom-\(color)"
        }
    }
    
    func color(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .yellow:
            return colorScheme == .light ? "#FFF9C4".hexColor() : "#BFAF30".hexColor()
        case .purple:
            return colorScheme == .light ? "#E8DFFF".hexColor() : "#8A6AD8".hexColor()
        case .red:
            return colorScheme == .light ? "#FFE0E0".hexColor() : "#C66266".hexColor()
        case .teal:
            return colorScheme == .light ? "#D9F6EC".hexColor() : "#4FB99B".hexColor()
        case .orange:
            return colorScheme == .light ? "#FFD3C2".hexColor() : "#D46E41".hexColor()
        case .blue:
            return colorScheme == .light ? "#DCF0FF".hexColor() : "#4D95C6".hexColor()
        case .green:
            return colorScheme == .light ? "#E4F9D6".hexColor() : "#7EAF59".hexColor()
        case .pink:
            return colorScheme == .light ? "#FFE8F0".hexColor() : "#C95E91".hexColor()
        case .peach:
            return colorScheme == .light ? "#FFE7C2".hexColor() : "#D88C3E".hexColor()
        case .lime:
            return colorScheme == .light ? "#F0F7D3".hexColor() : "#A4B847".hexColor()
        case .steelBlue:
            return colorScheme == .light ? "#DEEAF2".hexColor() : "#5B7D9B".hexColor()
        case .brown:
            return colorScheme == .light ? "#F5EDE3".hexColor() : "#A08066".hexColor()
        case .sand:
            return colorScheme == .light ? "#FFF3D2".hexColor() : "#C4A256".hexColor()
        case .custom(let color):
            return color.hexColor()
        }
    }
    
    static var allCases: [TaskColor] {
         return [.yellow, .purple, .red, .teal, .orange, .blue,
                 .green, .pink, .peach, .lime, .steelBlue, .brown, .sand]
     }
}
