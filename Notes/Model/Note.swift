//
//  Note.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/13/21.
//

import SwiftUI
import RealmSwift

// MARK: - Data

enum NoteColor: Int, CaseIterable, Equatable {
    case none = 0
    
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    
    var colorValue: Color? {
        switch self {
        case .none:
            return nil
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        }
    }
    
    var colorName: String {
        switch self {
        case .none:
            return "Uncolored"
        case .red:
            return "Red"
        case .orange:
            return "Orange"
        case .yellow:
            return "Yellow"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .purple:
            return "Purple"
        }
    }
}

class Note: Object, Identifiable {
    @objc dynamic var id = String()
    
    @objc dynamic var title = String()
    @objc dynamic var content = String()
    @objc dynamic var date = Date()
    @objc dynamic var isPinned = false
    @objc dynamic var isArchived = false
    @objc dynamic var isProtected = false
    
    @objc dynamic private var color = Int.zero
    
    let attachments = RealmSwift.List<NoteAttachment>()
    
    var noteColor: NoteColor {
        get {
            NoteColor(rawValue: color)!
        }
        
        set {
            color = newValue.rawValue
        }
    }
}

class NoteAttachment: Object {
    @objc dynamic var isLocal = false
    @objc dynamic private var urlString = String()
    
    var url: URL {
        get {
            URL(string: urlString)!
        }
        
        set {
            urlString = newValue.absoluteString
        }
    }
}

// MARK: - Logic

enum NoteFilter {
    case all
    case pinned
    case createdToday
    case createdYesterday
    case last(count: Int)
    case matchContent(query: String)
    case color(NoteColor)
}

enum NoteDiff {
    case title(String)
    case content(String)
    case color(NoteColor)
    case togglePin
    case addAttachment(NoteAttachment)
    case deleteAttachment(NoteAttachment)
    case protect
    case unprotect
    case archive
    case unarchive
    case delete
}

extension Array where Element == NoteFilter {
    static func matchContentOrColorName(in query: String) -> Self {
        let matchingColors = NoteColor.allCases.filter { query.localizedCaseInsensitiveContains($0.colorName) }
        return matchingColors.map { .color($0) } + [.matchContent(query: query)]
    }
}
