//
//  HomeViewModel.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine
import SwiftUI

// MARK: - View model

struct HomeViewModel {
    final class Input: ObservableObject {
        @Published var searchText = String()
        
        let didAppear: PassthroughSubject<Void, Never>
        let archiveNote: PassthroughSubject<String, Never>
        let unarchiveNote: PassthroughSubject<String, Never>
        let deleteNote: PassthroughSubject<String, Never>
        let pinNote: PassthroughSubject<String, Never>
        
        init(
            didAppear: PassthroughSubject<Void, Never>,
            archiveNote: PassthroughSubject<String, Never>,
            unarchiveNote: PassthroughSubject<String, Never>,
            deleteNote: PassthroughSubject<String, Never>,
            pinNote: PassthroughSubject<String, Never>
        ) {
            self.didAppear = didAppear
            self.archiveNote = archiveNote
            self.unarchiveNote = unarchiveNote
            self.deleteNote = deleteNote
            self.pinNote = pinNote
        }
    }
    
    final class Output: ObservableObject {
        @Published var sections = [HomeSection]()
        @Published var mode: HomeMode = .emptyDashboard
        @Published var showSnackbar = false
    }

    private let appState: CurrentValueSubject<AppState, Never>
    private let storageService: StorageService

    init(appState: CurrentValueSubject<AppState, Never>, storageService: StorageService) {
        self.appState = appState
        self.storageService = storageService
    }

    func transform(_ input: Input, in cancellables: inout [AnyCancellable]) -> Output {
        let output = Output()
        
        let loadSections = { (searchText: String) in
            storageService.purgeArchivedNotes()
            
            var sections = [HomeSection]()
                        
            if searchText.isEmpty {
                let pinnedNotes = storageService.getNotes([.pinned])
                
                let notesCreatedToday = storageService.getNotes([.createdToday]).filter { note in
                    !pinnedNotes.contains { $0.id == note.id }
                }
                
                let notesCreatedYesterday = storageService.getNotes([.createdYesterday]).filter { note in
                    !pinnedNotes.contains { $0.id == note.id } &&
                    !notesCreatedToday.contains { $0.id == note.id }
                }
                
                let otherNotes = storageService.getNotes([.all]).filter { note in
                    !pinnedNotes.contains { $0.id == note.id } &&
                    !notesCreatedToday.contains { $0.id == note.id } &&
                    !notesCreatedYesterday.contains { $0.id == note.id }
                }
                
                if !pinnedNotes.isEmpty {
                    sections.append(HomeSection(
                        title: HomeSectionTitle(
                            iconColor: .yellow,
                            icon: Image.pin,
                            iconRotation: .degrees(45),
                            name: LocalizedStringKey.Home.sectionPinned
                        ),
                        notes: pinnedNotes
                    ))
                }
                
                if !notesCreatedToday.isEmpty {
                    sections.append(HomeSection(
                        title: HomeSectionTitle(
                            iconColor: .red,
                            icon: Image.calendar,
                            iconRotation: .zero,
                            name: LocalizedStringKey.Home.sectionToday
                        ), notes: notesCreatedToday
                    ))
                }
                
                if !notesCreatedYesterday.isEmpty {
                    sections.append(HomeSection(
                        title: HomeSectionTitle(
                            iconColor: Color.red.opacity(0.7),
                            icon: Image.calendar,
                            iconRotation: .zero,
                            name: LocalizedStringKey.Home.sectionYesterday
                        ), notes: notesCreatedYesterday
                    ))
                }
                
                if !otherNotes.isEmpty {
                    sections.append(HomeSection(
                        title: HomeSectionTitle(
                            iconColor: Color.red.opacity(0.5),
                            icon: Image.listBulletRectangle,
                            iconRotation: .zero,
                            name: LocalizedStringKey.Home.sectionAll
                        ), notes: otherNotes
                    ))
                }
                
                withAnimation(.easeIn) {
                    if [pinnedNotes, notesCreatedToday, notesCreatedYesterday, otherNotes].allSatisfy(\.isEmpty) {
                        output.mode = .emptyDashboard
                    } else {
                        output.mode = .dashboard
                    }
                    output.sections = sections
                }
            } else {
                let searchResult = storageService.getNotes(.matchContentOrColorName(in: searchText))
                sections.append(HomeSection(title: nil, notes: searchResult))
                withAnimation(.easeIn) {
                    if searchResult.isEmpty {
                        output.mode = .emptySearchResults
                    } else {
                        output.mode = .searchResults
                    }
                    output.sections = sections
                }
            }
        }
        
        input.didAppear.map { String() }.sink(receiveValue: loadSections).store(in: &cancellables)
        
        input.$searchText.sink(receiveValue: loadSections).store(in: &cancellables)
        
        input.archiveNote.sink {
            storageService.modifyNote(id: $0, diff: .archive)
            NotificationCenter.default.post(.noteStateChanged)
            
            output.showSnackbar = true
        }.store(in: &cancellables)
        
        input.unarchiveNote.sink {
            storageService.modifyNote(id: $0, diff: .unarchive)
            NotificationCenter.default.post(.noteStateChanged)
        }.store(in: &cancellables)
        
        input.deleteNote.sink {
            storageService.modifyNote(id: $0, diff: .delete)
            NotificationCenter.default.post(.noteStateChanged)
        }.store(in: &cancellables)
        
        input.pinNote.sink {
            storageService.modifyNote(id: $0, diff: .togglePin)
            NotificationCenter.default.post(.noteStateChanged)
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .noteStateChanged).sink { _ in
            loadSections(input.searchText)
        }.store(in: &cancellables)
                
        return output
    }
}
