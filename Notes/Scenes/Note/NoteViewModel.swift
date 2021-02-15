//
//  NoteViewModel.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/13/21.
//

import Combine
import LocalAuthentication
import SwiftUI

// MARK: - View model

struct NoteViewModel {
    final class Input: ObservableObject {
        @Published var noteID = String()
        @Published var noteTitle = String()
        @Published var noteContent = String()
        @Published var noteColor: NoteColor = .none
        @Published var noteLock = false
        
        let didAppear: PassthroughSubject<Void, Never>
        let hideNote: PassthroughSubject<Void, Never>
        let addAttachment: PassthroughSubject<NoteAttachment, Never>
        let deleteAttachment: PassthroughSubject<NoteAttachment, Never>
        let toggleNoteLock: PassthroughSubject<Void, Never>
        
        init(
            note: Note,
            didAppear: PassthroughSubject<Void, Never>,
            hideNote: PassthroughSubject<Void, Never>,
            addAttachment: PassthroughSubject<NoteAttachment, Never>,
            deleteAttachment: PassthroughSubject<NoteAttachment, Never>,
            toggleNoteLock: PassthroughSubject<Void, Never>
        ) {
            noteID = note.id
            noteTitle = note.title
            noteContent = note.content
            noteColor = note.noteColor
            noteLock = note.isProtected
            
            self.didAppear = didAppear
            self.hideNote = hideNote
            self.addAttachment = addAttachment
            self.deleteAttachment = deleteAttachment
            self.toggleNoteLock = toggleNoteLock
        }
    }
    
    final class Output: ObservableObject {
        @Published var showNoteContentPlaceholder = true
        @Published var showColorPickerPopup = false
        @Published var showAttachmentPopup = false
        @Published var showAttachmentView = false
        
        let redactNoteContent: CurrentValueSubject<Bool, Never>
        
        init(redactNoteContent: CurrentValueSubject<Bool, Never>) {
            self.redactNoteContent = redactNoteContent
        }
        
    }

    private let appState: CurrentValueSubject<AppState, Never>
    private let storageService: StorageService

    init(appState: CurrentValueSubject<AppState, Never>, storageService: StorageService) {
        self.appState = appState
        self.storageService = storageService
    }

    func transform(_ input: Input, in cancellables: inout [AnyCancellable]) -> Output {
        let redactNoteContent = CurrentValueSubject<Bool, Never>(false)
        
        let output = Output(redactNoteContent: redactNoteContent)
        
        output.redactNoteContent.send(input.noteLock)
        
        let context = LAContext()
        
        input.didAppear.delay(for: 0.1, scheduler: RunLoop.main).sink {
            if input.noteLock {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "This note is protected") { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            output.redactNoteContent.send(false)
                        } else {
                            input.hideNote.send()
                        }
                    }
                }
            }
        }.store(in: &cancellables)
        
        input.$noteContent.map(\.isEmpty).assign(to: &output.$showNoteContentPlaceholder)
        
        output.showNoteContentPlaceholder = input.noteContent.isEmpty
        
        input.$noteContent.sink { newContent in
            storageService.modifyNote(id: input.noteID, diff: .content(newContent))
        }.store(in: &cancellables)
        
        input.$noteTitle.sink { newTitle in
            storageService.modifyNote(id: input.noteID, diff: .title(newTitle))
        }.store(in: &cancellables)
        
        input.$noteColor.sink { newColor in
            storageService.modifyNote(id: input.noteID, diff: .color(newColor))
        }.store(in: &cancellables)
        
        input.addAttachment.sink { newAttachment in
            storageService.modifyNote(id: input.noteID, diff: .addAttachment(newAttachment))
        }.store(in: &cancellables)
        
        input.deleteAttachment.sink { newAttachment in
            storageService.modifyNote(id: input.noteID, diff: .deleteAttachment(newAttachment))
        }.store(in: &cancellables)
        
        input.toggleNoteLock.sink { isLocked in
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "We need to verify it's you to manage notes") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        if input.noteLock {
                            storageService.modifyNote(id: input.noteID, diff: .unprotect)
                            input.noteLock = false
                        } else {
                            storageService.modifyNote(id: input.noteID, diff: .protect)
                            input.noteLock = true
                        }
                    }
                }
            }
        }.store(in: &cancellables)
        
        input.hideNote.sink {
            NotificationCenter.default.post(.noteStateChanged)
        }.store(in: &cancellables)

        return output
    }
}
