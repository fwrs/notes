//
//  NotesApp.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine
import RealmSwift
import SwiftUI

// MARK: - Metadata

struct AppMetadata {
    let dependencyContainer: DependencyContainer
    let appState: CurrentValueSubject<AppState, Never>
}

// MARK: - Application

@main struct NotesApp: SwiftUI.App {
    private var cancellables = [AnyCancellable]()
    private let metadata: AppMetadata

    init() {
        metadata = Assembly.setup()
        
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView(container: metadata.dependencyContainer)
        }
    }
}

