//
//  HomeView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine
import SwiftUI

// MARK: - User interface

struct HomeView: View {
    private typealias Localization = LocalizedStringKey.Home
    
    private var container: DependencyContainer
    private var cancellables = [AnyCancellable]()

    @ObservedObject private var input: HomeViewModel.Input
    @ObservedObject private var output: HomeViewModel.Output
    
    @State private var shouldShowSeparator = false
    
    let didAppear = PassthroughSubject<Void, Never>()
    let showNote: PassthroughSubject<Note, Never>
    let archiveNote = PassthroughSubject<String, Never>()
    let unarchiveNote = PassthroughSubject<String, Never>()
    let deleteNote = PassthroughSubject<String, Never>()
    let pinNote = PassthroughSubject<String, Never>()
    let shareSheetContent: CurrentValueSubject<[AnyHashable], Never>
    
    var body: some View {
        ZStack {
            ZStack {
                if output.mode == .dashboard || output.mode == .searchResults {
                    ScrollView {
                        VStack(spacing: 8) {
                            GeometryReader { proxy in
                                let offset = proxy.frame(in: .named("scroll")).minY
                                Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                            }
                            
                            Spacer().frame(height: 84)
                            Text(output.mode.header)
                                .font(.system(size: 32, weight: .heavy))
                                .frame(minWidth: .zero, maxWidth: .infinity, alignment: .leading)
                            
                            let sections = Array(output.sections.enumerated())
                            
                            ForEach(sections, id: \.offset) { element in
                                let section = element.element
                                if let title = section.title {
                                    HStack(spacing: 3.5) {
                                        title.icon
                                            .rotationEffect(title.iconRotation)
                                            .offset(y: title.iconRotation == .zero ? 0 : 2)
                                            .foregroundColor(title.iconColor.opacity(0.75))
                                            .font(.system(size: 14, weight: .medium))
                                        Text(title.name)
                                            .textCase(.uppercase)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                
                                ForEach(section.notes) { note in
                                    NotePreviewView(
                                        note: note,
                                        archiveNote: archiveNote,
                                        unarchiveNote: unarchiveNote,
                                        deleteNote: deleteNote,
                                        pinNote: pinNote,
                                        showNote: showNote,
                                        shareSheetContent: shareSheetContent
                                    )
                                }
                                Spacer().frame(height: 7)
                            }
                            Spacer().frame(height: 84)
                        }.padding(.horizontal, 26)
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                        withAnimation {
                            shouldShowSeparator = value < 0
                        }
                    }
                } else if output.mode == .emptyDashboard || output.mode == .emptySearchResults {
                    VStack {
                        Text(output.mode.placeholderTitle).font(.system(size: 28, weight: .bold))
                        Spacer().frame(height: 6)
                        Text(output.mode.placeholderSubitle).foregroundColor(.secondary)
                    }
                }
            }.onAppear {
                didAppear.send()
            }
            VStack(spacing: .zero) {
                ZStack {
                    Color(UIColor.systemBackground)
                }.frame(height: 110)
                if shouldShowSeparator {
                    ZStack {
                        Color(UIColor.separator.withAlphaComponent(0.35))
                    }.frame(height: 1)
                }
                Spacer()
            }
            VStack {
                Spacer().frame(height: 32)
                SearchBarHeaderView(searchText: $input.searchText).frame(height: 40).padding(26)
                Spacer()
            }
        }.snackBar(isShowing: $output.showSnackbar, text: Text(Localization.snackbarNoteMovedToArchive))
    }

    init(container: DependencyContainer, showNote: PassthroughSubject<Note, Never>, shareSheetContent: CurrentValueSubject<[AnyHashable], Never>) {
        let input = HomeViewModel.Input(
            didAppear: didAppear,
            archiveNote: archiveNote,
            unarchiveNote: unarchiveNote,
            deleteNote: deleteNote,
            pinNote: pinNote
        )
        
        self.container = container
        self.output = container.viewModel.homeViewModel().transform(input, in: &cancellables)
        self.input = input
        
        self.showNote = showNote
        self.shareSheetContent = shareSheetContent
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(container: .defaultValue, showNote: .init(), shareSheetContent: .init([])).environment(\.colorScheme, .dark)
    }
}
