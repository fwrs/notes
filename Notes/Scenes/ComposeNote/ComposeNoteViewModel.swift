//
//  ComposeNoteViewModel.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/13/21.
//

import Combine
import SwiftUI

// MARK: - View model

struct ComposeNoteViewModel {
    final class Input: ObservableObject {
        @Published var noteTitle = String()
        @Published var noteContent = String()
        @Published var noteAttachments = [NoteAttachment]()
        
        let addAttachment: PassthroughSubject<NoteAttachment, Never>
        let deleteAttachment: PassthroughSubject<NoteAttachment, Never>
        
        let saveButtonPushed: PassthroughSubject<Void, Never>
        
        init(
            saveButtonPushed: PassthroughSubject<Void, Never>,
            addAttachment: PassthroughSubject<NoteAttachment, Never>,
            deleteAttachment: PassthroughSubject<NoteAttachment, Never>
        ) {
            self.saveButtonPushed = saveButtonPushed
            self.addAttachment = addAttachment
            self.deleteAttachment = deleteAttachment
        }
    }
    
    final class Output: ObservableObject {
        @Published var showNoteContentPlaceholder = true
        @Published var showAttachmentPopup = false
        @Published var showAttachmentView = false
        
        let hideSheet: PassthroughSubject<Void, Never>
        
        init(hideSheet: PassthroughSubject<Void, Never>) {
            self.hideSheet = hideSheet
        }
    }

    private let appState: CurrentValueSubject<AppState, Never>
    private let storageService: StorageService

    init(appState: CurrentValueSubject<AppState, Never>, storageService: StorageService) {
        self.appState = appState
        self.storageService = storageService
    }

    func transform(_ input: Input, in cancellables: inout [AnyCancellable]) -> Output {
        let hideSheet = PassthroughSubject<Void, Never>()
        
        let output = Output(hideSheet: hideSheet)
        
        input.$noteContent.map(\.isEmpty).assign(to: &output.$showNoteContentPlaceholder)
        
        input.saveButtonPushed.sink {
            storageService.addNote(title: input.noteTitle, content: input.noteContent, attachments: input.noteAttachments)
            NotificationCenter.default.post(.noteStateChanged)
            output.hideSheet.send()
        }.store(in: &cancellables)
        
        input.addAttachment.sink { newAttachment in
            input.noteAttachments.append(newAttachment)
        }.store(in: &cancellables)
        
        input.deleteAttachment.sink { existingAttachment in
            input.noteAttachments.removeAll { $0.url == existingAttachment.url }
        }.store(in: &cancellables)
        
        return output
    }
}
