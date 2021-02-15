//
//  NavigationViewModel.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine
import SwiftUI

// MARK: - Tab

enum NavigationViewTab {
    case home
    case archive
}

// MARK: - View model

struct NavigationViewModel {
    final class Input: ObservableObject {
        @Published var selectedTab: NavigationViewTab = .home
        
        let didTapComposeButton: PassthroughSubject<Void, Never>
        let showNote: PassthroughSubject<Note, Never>
        let hideNote: PassthroughSubject<Void, Never>
        let hideComposeSheet: PassthroughSubject<Void, Never>
        
        init(
            didTapComposeButton: PassthroughSubject<Void, Never>,
            showNote: PassthroughSubject<Note, Never>,
            hideNote: PassthroughSubject<Void, Never>,
            hideComposeSheet: PassthroughSubject<Void, Never>
        ) {
            self.didTapComposeButton = didTapComposeButton
            self.showNote = showNote
            self.hideNote = hideNote
            self.hideComposeSheet = hideComposeSheet
        }
    }
    
    final class Output: ObservableObject {
        @Published var selectedTab: NavigationViewTab = .home
        @Published var showComposeSheet = false
        @Published var navigationBarMiddleButtonRotation = Angle.zero
        @Published var visibleNote: Note? = nil
        @Published var noteOffset = UIScreen.main.bounds.width
        @Published var noteOpacity = Double.zero
        @Published var showTabBar = true
    }

    private let appState: CurrentValueSubject<AppState, Never>

    init(appState: CurrentValueSubject<AppState, Never>) {
        self.appState = appState
    }

    func transform(_ input: Input, in cancellables: inout [AnyCancellable]) -> Output {
        let output = Output()
        
        var showComposeSheet = false
        
        input.$selectedTab.assign(to: &output.$selectedTab)
        
        input.$selectedTab.map { _ in false }.sink { _ in
            showComposeSheet = false
            output.showComposeSheet = showComposeSheet
            output.navigationBarMiddleButtonRotation = .zero
        }.store(in: &cancellables)
        
        input.didTapComposeButton.sink {
            showComposeSheet.toggle()
            output.navigationBarMiddleButtonRotation = showComposeSheet ? .degrees(45) : .zero
            output.showComposeSheet = showComposeSheet
        }.store(in: &cancellables)
        
        input.showNote.map { Optional<Note>($0) }.sink { note in
            output.visibleNote = note
            withAnimation(.interpolatingSpring(stiffness: 400, damping: 40)) {
                output.noteOffset = .zero
                output.noteOpacity = 1
                output.showTabBar = note == nil
            }
        }.store(in: &cancellables)
        
        input.hideNote.sink {
            withAnimation(.interpolatingSpring(stiffness: 400, damping: 40)) {
                output.noteOffset = UIScreen.main.bounds.width
                output.noteOpacity = .zero
                output.showTabBar = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                output.visibleNote = nil
            }
        }.store(in: &cancellables)
        
        input.hideComposeSheet.sink {
            showComposeSheet = false
            output.navigationBarMiddleButtonRotation = .zero
            output.showComposeSheet = showComposeSheet
        }.store(in: &cancellables)
        
        return output
    }
}
