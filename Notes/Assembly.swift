//
//  Assembly.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine

// MARK: - Assembly

struct Assembly {
    static func setup() -> AppMetadata {
        let appState = CurrentValueSubject<AppState, Never>(AppState())
        let storageService = StorageServiceImplementation()
        
        return AppMetadata(
            dependencyContainer: DependencyContainer(
                appState: appState,
                viewModel: ViewModelGroup(
                    navigationViewModel: NavigationViewModel(appState: appState),
                    homeViewModel: HomeViewModel(appState: appState, storageService: storageService),
                    composeNoteViewModel: ComposeNoteViewModel(appState: appState, storageService: storageService),
                    archiveViewModel: ArchiveViewModel(appState: appState, storageService: storageService),
                    noteViewModel: NoteViewModel(appState: appState, storageService: storageService)
                )
            ),
            appState: appState
        )
    }
}
