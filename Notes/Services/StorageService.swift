//
//  StorageService.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/13/21.
//

import Combine
import RealmSwift
import SwiftUI

// MARK: - Definition

protocol StorageService {
    func getNotes(_ filters: [NoteFilter], archived: Bool) -> [Note]
    func getNotes(_ filters: [NoteFilter]) -> [Note]
    func getNote(id: String) -> Note?
    func addNote(title: String, content: String, attachments: [NoteAttachment])
    func addNote(title: String, content: String)
    func modifyNote(id: String, diff: NoteDiff)
    func purgeArchivedNotes()
    func clearStorage()
}

extension StorageService {
    func getNotes(_ filters: [NoteFilter]) -> [Note] {
        getNotes(filters, archived: false)
    }
    func addNote(title: String, content: String) {
        addNote(title: title, content: content, attachments: [])
    }
}

// MARK: - Implementation

struct StorageServiceImplementation: StorageService {
    private let realm = try! Realm()

    func getNotes(_ filters: [NoteFilter], archived: Bool) -> [Note] {
        let sorted = realm.objects(Note.self).sorted { $0.date > $1.date }.filter { archived ? $0.isArchived : !$0.isArchived }
        var result = [Note]()
        
        for filter in filters {
            switch filter {
            case .all:
                result.append(contentsOf: sorted)
            case .pinned:
                result.append(contentsOf: sorted.filter { $0.isPinned })
            case .createdToday:
                result.append(contentsOf: sorted.filter { Calendar.current.isDateInToday($0.date) })
            case .createdYesterday:
                result.append(contentsOf: sorted.filter { Calendar.current.isDateInYesterday($0.date) })
            case let .last(count):
                result.append(contentsOf: Array(sorted.prefix(count)))
            case let .matchContent(query):
                result.append(contentsOf: sorted.filter {
                    $0.title.localizedCaseInsensitiveContains(query) ||
                        $0.content.localizedCaseInsensitiveContains(query)
                })
            case let .color(color):
                result.append(contentsOf: sorted.filter { $0.noteColor == color })
            }
        }
        
        return result
    }
    
    func getNote(id: String) -> Note? {
        realm.objects(Note.self).first { $0.id == id }
    }
    
    func addNote(title: String, content: String, attachments: [NoteAttachment]) {
        let note = Note()
        note.id = UUID().uuidString
        note.title = title
        note.content = content
        for attachment in attachments {
            note.attachments.append(attachment)
        }
        
        try! realm.write {
            realm.add(note)
        }
    }

    func modifyNote(id: String, diff: NoteDiff) {
        guard let note = realm.objects(Note.self).filter({ $0.id == id }).first else {
            return
        }
        
        try! realm.write {
            note.date = Date()
            switch diff {
            case let .title(newTitle):
                note.title = newTitle
            case let .content(newContent):
                note.content = newContent
            case let .color(newNoteColor):
                note.noteColor = newNoteColor
            case .togglePin:
                note.isPinned = !note.isPinned
            case let .addAttachment(newAttachment):
                note.attachments.append(newAttachment)
            case let .deleteAttachment(existingAttachment):
                note.attachments.firstIndex { existingAttachment.url == $0.url }.map {
                    note.attachments.remove(at: $0)
                }
            case .protect:
                note.isProtected = true
            case .unprotect:
                note.isProtected = false
            case .archive:
                note.isPinned = false
                note.isArchived = true
            case .unarchive:
                note.isArchived = false
            case .delete:
                realm.delete(note)
            }
        }
    }
    
    func purgeArchivedNotes() {
        realm.delete(realm.objects(Note.self).filter { $0.isArchived }.filter {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let noteCreationDay = calendar.startOfDay(for: $0.date)
            
            let days = calendar.dateComponents([.day], from: today, to: noteCreationDay).day ?? 0
            return days > 30
        })
    }
    
    func clearStorage() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}

// MARK: - Substitute

struct StorageServiceSubstitute: StorageService {
    func getNotes(_ filters: [NoteFilter], archived: Bool) -> [Note] { [] }
    func getNote(id: String) -> Note? { nil }
    func addNote(title: String, content: String, attachments: [NoteAttachment]) {}
    func modifyNote(id: String, diff: NoteDiff) {}
    func purgeArchivedNotes() {}
    func clearStorage() {}
}
