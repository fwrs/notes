//
//  DependencyContainer.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine
import SwiftUI

// MARK: - ViewModel group

struct ViewModelGroup {
    let navigationViewModel: () -> NavigationViewModel
    let homeViewModel: () -> HomeViewModel
    let composeNoteViewModel: () -> ComposeNoteViewModel
    let archiveViewModel: () -> ArchiveViewModel
    let noteViewModel: () -> NoteViewModel
    
    init(
        navigationViewModel: @autoclosure @escaping () -> NavigationViewModel,
        homeViewModel: @autoclosure @escaping () -> HomeViewModel,
        composeNoteViewModel: @autoclosure @escaping () -> ComposeNoteViewModel,
        archiveViewModel: @autoclosure @escaping () -> ArchiveViewModel,
        noteViewModel: @autoclosure @escaping () -> NoteViewModel
    ) {
        self.navigationViewModel = navigationViewModel
        self.homeViewModel = homeViewModel
        self.composeNoteViewModel = composeNoteViewModel
        self.archiveViewModel = archiveViewModel
        self.noteViewModel = noteViewModel
    }

    static let substitute = Self(
        navigationViewModel: NavigationViewModel(appState: .init(AppState())),
        homeViewModel: HomeViewModel(appState: .init(AppState()), storageService: StorageServiceSubstitute()),
        composeNoteViewModel: ComposeNoteViewModel(appState: .init(AppState()), storageService: StorageServiceSubstitute()),
        archiveViewModel: ArchiveViewModel(appState: .init(AppState()), storageService: StorageServiceSubstitute()),
        noteViewModel: NoteViewModel(appState: .init(AppState()), storageService: StorageServiceSubstitute())
    )
}

// MARK: - Dependency container

struct DependencyContainer {
    let appState: CurrentValueSubject<AppState, Never>
    let viewModel: ViewModelGroup

    init(appState: CurrentValueSubject<AppState, Never>, viewModel: ViewModelGroup) {
        self.appState = appState
        self.viewModel = viewModel
    }
    
    static var defaultValue: Self {
        Self(
            appState: .init(AppState()),
            viewModel: .substitute
        )
    }
}
