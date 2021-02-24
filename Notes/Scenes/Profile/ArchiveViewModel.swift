//
//  ArchiveViewModel.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/14/21.
//

import Combine
import SwiftUI

// MARK: - View model

struct ArchiveViewModel {
    final class Input: ObservableObject {
        
        let didAppear: PassthroughSubject<Void, Never>
        let archiveNote: PassthroughSubject<String, Never>
        let unarchiveNote: PassthroughSubject<String, Never>
        let deleteNote: PassthroughSubject<String, Never>
        let pinNote: PassthroughSubject<String, Never>
        let clearNotes: PassthroughSubject<Void, Never>
        let clearNotesAgreed: PassthroughSubject<Void, Never>
        
        init(
            didAppear: PassthroughSubject<Void, Never>,
            archiveNote: PassthroughSubject<String, Never>,
            unarchiveNote: PassthroughSubject<String, Never>,
            deleteNote: PassthroughSubject<String, Never>,
            pinNote: PassthroughSubject<String, Never>,
            clearNotes: PassthroughSubject<Void, Never>,
            clearNotesAgreed: PassthroughSubject<Void, Never>
        ) {
            self.didAppear = didAppear
            self.archiveNote = archiveNote
            self.unarchiveNote = unarchiveNote
            self.deleteNote = deleteNote
            self.pinNote = pinNote
            self.clearNotes = clearNotes
            self.clearNotesAgreed = clearNotesAgreed
        }
    }
    
    final class Output: ObservableObject {
        @Published var notes = [Note]()
        @Published var showSnackbar = false
        @Published var snackbarText = LocalizedStringKey(String())
        @Published var showClearConfirmAlert = false
    }

    private let appState: CurrentValueSubject<AppState, Never>
    private let storageService: StorageService

    init(appState: CurrentValueSubject<AppState, Never>, storageService: StorageService) {
        self.appState = appState
        self.storageService = storageService
    }

    func transform(_ input: Input, in cancellables: inout [AnyCancellable]) -> Output {
        let output = Output()
        
        output.notes = storageService.getNotes([.all], archived: true)
        
        input.didAppear.sink {
            withAnimation(.easeIn) {
                output.notes = storageService.getNotes([.all], archived: true)
            }
        }.store(in: &cancellables)
        
        input.archiveNote.sink {
            storageService.modifyNote(id: $0, diff: .archive)
            NotificationCenter.default.post(.noteStateChanged)
        }.store(in: &cancellables)
        
        input.unarchiveNote.sink {
            storageService.modifyNote(id: $0, diff: .unarchive)
            NotificationCenter.default.post(.noteStateChanged)
            output.snackbarText = LocalizedStringKey.Archive.snackbarNoteRemovedFromArchive
            output.showSnackbar = true
        }.store(in: &cancellables)
        
        input.deleteNote.sink {
            storageService.modifyNote(id: $0, diff: .delete)
            NotificationCenter.default.post(.noteStateChanged)
            output.snackbarText = LocalizedStringKey.Archive.snackbarNoteWasDeleted
            output.showSnackbar = true
        }.store(in: &cancellables)
        
        input.pinNote.sink {
            storageService.modifyNote(id: $0, diff: .togglePin)
            NotificationCenter.default.post(.noteStateChanged)
        }.store(in: &cancellables)
        
        input.clearNotes.sink {
            output.showClearConfirmAlert = true
        }.store(in: &cancellables)
        
        input.clearNotesAgreed.sink {
            storageService.clearStorage()
            NotificationCenter.default.post(.noteStateChanged)
            output.snackbarText = LocalizedStringKey.Archive.snackbarAllNotesDeleted
            output.showSnackbar = true
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .noteStateChanged).sink { _ in
            withAnimation(.easeIn) {
                output.notes = storageService.getNotes([.all], archived: true)
            }
        }.store(in: &cancellables)
        
        return output
    }
}
