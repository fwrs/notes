//
//  NavigationView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine
import SwiftUI

// MARK: - User interface

struct NavigationView: View {
    private typealias Localization = LocalizedStringKey.Navigation
    
    private var container: DependencyContainer
    private var cancellables = [AnyCancellable]()

    @ObservedObject private var input: NavigationViewModel.Input
    @ObservedObject private var output: NavigationViewModel.Output
    
    private let didTapComposeButton = PassthroughSubject<Void, Never>()
    
    @State private var navigationBarHeightMultiplier: CGFloat = .zero
    
    let showNote = PassthroughSubject<Note, Never>()
    let hideNote = PassthroughSubject<Void, Never>()
    let hideComposeSheet = PassthroughSubject<Void, Never>()
    let shareSheetContent = CurrentValueSubject<[AnyHashable], Never>([])
    
    private let homeView: HomeView
    private let archiveView: ArchiveView
    
    private var noteView = CurrentValueSubject<NoteView?, Never>(nil)

    var body: some View {
        ZStack {
            switch output.selectedTab {
            case .home:
                homeView
            case .archive:
                archiveView
            }
            
            ZStack {
                Color.black.opacity(output.showComposeSheet ? 0.8 : 0)
            }.animation(.easeOut, value: output.showComposeSheet).allowsHitTesting(output.showComposeSheet).onTapGesture {
                hideComposeSheet.send()
            }
            
            VStack {
                Spacer()
                ComposeNoteView(container: container, hideSheet: input.hideComposeSheet)
                    .frame(height: UIScreen.main.bounds.height * navigationBarHeightMultiplier * 0.65)
                    .clipped()
                    .opacity(Double(navigationBarHeightMultiplier))
                    .padding(.horizontal, 26)
                Spacer().frame(height: 26)
            }.onReceive(output.$showComposeSheet) { shouldShow in
                withAnimation(.interpolatingSpring(stiffness: 400, damping: 40)) {
                    navigationBarHeightMultiplier = shouldShow ? 1 : 0
                }
            }

            if output.visibleNote != nil, let noteView = noteView.value {
                noteView.offset(
                    x: output.noteOffset,
                    y: .zero
                ).opacity(output.noteOpacity)
            }
            
            VStack {
                Spacer()
                NavigationBarView(
                    selectedTab: $input.selectedTab,
                    centerButtonRotation: $output.navigationBarMiddleButtonRotation,
                    didTapComposeButton: didTapComposeButton
                ).frame(height: 62).padding(.horizontal, 26).offset(x: .zero, y: output.showTabBar ? .zero : 200).animation(.spring(), value: output.showTabBar)
                Spacer().frame(height: 26)
            }
        }.ignoresSafeArea().onReceive(shareSheetContent) { content in
            if !content.isEmpty {
                shareSheet(data: content)
            }
        }
    }

    init(container: DependencyContainer) {
        UITextView.appearance().backgroundColor = .clear
        
        let input = NavigationViewModel.Input(didTapComposeButton: didTapComposeButton, showNote: showNote, hideNote: hideNote, hideComposeSheet: hideComposeSheet)
        
        self.container = container
        self.output = container.viewModel.navigationViewModel().transform(input, in: &cancellables)
        self.input = input
        
        homeView = HomeView(container: container, showNote: showNote, shareSheetContent: shareSheetContent)
        archiveView = ArchiveView(container: container, showNote: showNote, shareSheetContent: shareSheetContent)
        
        output.$visibleNote.sink { [self] note in
            noteView.send(note.map {
                NoteView(container: container, note: $0, hideNote: hideNote, shareSheetContent: shareSheetContent)
            })
        }.store(in: &cancellables)
    }
    
    func shareSheet(data: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        
        UIApplication.shared.windows.first?.rootViewController?.present(
            activityViewController,
            animated: true,
            completion: nil
        )
    }
}

// MARK: - Previews

struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView(container: .defaultValue).environment(\.colorScheme, .dark)
    }
}
