//
//  Localization.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import SwiftUI

// MARK: - Localization

extension LocalizedStringKey {
    // MARK: - Shared
    
    enum Shared {}
    
    // MARK: - Navigation
    
    enum Navigation {}
    
    // MARK: - Home
    
    enum Home {
        static let titleDashboard: LocalizedStringKey = "home.titleDashboard"
        static let titleSearchResults: LocalizedStringKey = "home.titleSearchResults"
        
        static let sectionPinned: LocalizedStringKey = "home.sectionPinned"
        static let sectionToday: LocalizedStringKey = "home.sectionToday"
        static let sectionYesterday: LocalizedStringKey = "home.sectionYesterday"
        static let sectionAll: LocalizedStringKey = "home.sectionAll"
        
        static let placeholderEmptyDashboard: LocalizedStringKey = "home.placeholderEmptyDashboard"
        static let placeholderEmptyDashboardHint: LocalizedStringKey = "home.placeholderEmptyDashboardHint"
        static let placeholderEmptySearchResults: LocalizedStringKey = "home.placeholderEmptySearchResults"
        static let placeholderEmptySearchResultsHint: LocalizedStringKey = "home.placeholderEmptySearchResultsHint"
        
        static let snackbarNoteMovedToArchive: LocalizedStringKey = "home.snackbarNoteMovedToArchive"

        enum NotePreview {
            static let protected: LocalizedStringKey = "home.notePreview.protected"
            static let emptyNote: LocalizedStringKey = "home.notePreview.emptyNote"
            static let untitledNote: LocalizedStringKey = "home.notePreview.untitledNote"
        }
    }
    
    // MARK: - Compose note
    
    enum ComposeNote {
        static let title: LocalizedStringKey = "composeNote.title"
        static let titlePlaceholder: LocalizedStringKey = "composeNote.titlePlaceholder"
        static let contentPlaceholder: LocalizedStringKey = "composeNote.contentPlaceholder"
        static let buttonAttach: LocalizedStringKey = "composeNote.buttonAttach"
        static let buttonSave: LocalizedStringKey = "composeNote.buttonSave"
    }
    
    // MARK: - Archive
    
    enum Archive {
        static let title: LocalizedStringKey = "archive.title"
        static let hint: LocalizedStringKey = "archive.hint"
        static let buttonRemoveAll: LocalizedStringKey = "archive.buttonRemoveAll"
        
        static let placeholderNoNotes: LocalizedStringKey = "archive.placeholderNoNotes";
        static let placeholderNoNotesHint: LocalizedStringKey = "archive.placeholderNoNotesHint";
        
        static let removeAllAlertTitle: LocalizedStringKey = "archive.removeAllAlertTitle";
        static let removeAllAlertMessage: LocalizedStringKey = "archive.removeAllAlertMessage";
        static let removeAllAlertConfirm: LocalizedStringKey = "archive.removeAllAlertConfirm";
        
        static let snackbarNoteRemovedFromArchive: LocalizedStringKey = "archive.snackbarNoteRemovedFromArchive"
        static let snackbarNoteWasDeleted: LocalizedStringKey = "archive.snackbarNoteWasDeleted"
        static let snackbarAllNotesDeleted: LocalizedStringKey = "archive.snackbarAllNotesDeleted"
    }
    
    // MARK: - Note
    
    enum Note {
        static let title: LocalizedStringKey = "note.title"
        static let titlePlaceholder: LocalizedStringKey = "note.titlePlaceholder"
        static let contentPlaceholder: LocalizedStringKey = "note.contentPlaceholder"
        static let ellipsis: LocalizedStringKey = "note.ellipsis"
        
        enum ColorPicker {
            static let title: LocalizedStringKey = "note.colorPicker.title"
            static let buttonRemoveColor: LocalizedStringKey = "note.colorPicker.buttonRemoveColor"
        }
        
        enum AddAttachment {
            static let title: LocalizedStringKey = "note.addAttachment.title"
            static let optionClipboardURL: LocalizedStringKey = "note.addAttachment.optionClipboardURL"
            static let optionGallery: LocalizedStringKey = "note.addAttachment.optionGallery"
            static let optionCamera: LocalizedStringKey = "note.addAttachment.optionCamera"
        }
    }
}
