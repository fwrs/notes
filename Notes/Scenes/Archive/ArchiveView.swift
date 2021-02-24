//
//  ArchiveView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/14/21.
//

import Combine
import SwiftUI

// MARK: - User interface

struct ArchiveView: View {
    private typealias Localization = LocalizedStringKey.Archive
    
    private var container: DependencyContainer
    private var cancellables = [AnyCancellable]()

    @ObservedObject private var input: ArchiveViewModel.Input
    @ObservedObject private var output: ArchiveViewModel.Output
    
    @State private var shouldShowSeparator = false
    
    let didAppear = PassthroughSubject<Void, Never>()
    let showNote: PassthroughSubject<Note, Never>
    let archiveNote = PassthroughSubject<String, Never>()
    let unarchiveNote = PassthroughSubject<String, Never>()
    let deleteNote = PassthroughSubject<String, Never>()
    let pinNote = PassthroughSubject<String, Never>()
    let shareSheetContent: CurrentValueSubject<[AnyHashable], Never>
    let clearNotes = PassthroughSubject<Void, Never>()
    let clearNotesAgreed = PassthroughSubject<Void, Never>()

    var body: some View {
        ZStack {
            ScrollView(output.notes.isEmpty ? [] : .vertical) {
                VStack(spacing: 8) {
                    Spacer().frame(height: 58)
                    Text(Localization.title)
                        .font(.system(size: 32, weight: .heavy))
                        .frame(minWidth: .zero, maxWidth: .infinity, alignment: .leading)
                    
                    Text(Localization.hint)
                        .foregroundColor(Color.white.opacity(0.85))
                        .font(.system(size: 17, weight: .medium))
                        .frame(minWidth: .zero, maxWidth: .infinity, alignment: .leading)
                    
                    Spacer().frame(height: 2)
                    
                    Button {
                        clearNotes.send()
                    } label: {
                        HStack(spacing: 5) {
                            Image.trash
                                .foregroundColor(Color.white.opacity(0.7))
                            Text(Localization.buttonRemoveAll)
                                .minimumScaleFactor(0.1)
                                .frame(minWidth: .zero, maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                    }
                    
                    Spacer().frame(height: 6)
                    
                    ForEach(output.notes) { note in
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
                    
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named("scroll")).minY
                        Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                    }
                }
            }.onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                withAnimation {
                    shouldShowSeparator = value < 0
                }
            }
            if output.notes.isEmpty {
                VStack {
                    Text(Localization.placeholderNoNotes).font(.system(size: 28, weight: .bold))
                    Spacer().frame(height: 6)
                    Text(Localization.placeholderNoNotesHint).foregroundColor(.secondary)
                }.frame(minHeight: .zero, maxHeight: .infinity)
            }
            
            VStack(spacing: .zero) {
                ZStack {
                    Color(UIColor.systemBackground)
                }.frame(height: 44)
                if shouldShowSeparator {
                    ZStack {
                        Color(UIColor.separator.withAlphaComponent(0.35))
                    }.frame(height: 1)
                }
                Spacer()
            }
        }.padding(.horizontal, 26).onAppear {
            didAppear.send()
        }.snackBar(isShowing: $output.showSnackbar, text: Text(output.snackbarText))
        .alert(isPresented: $output.showClearConfirmAlert) {
            Alert(
                title: Text(Localization.removeAllAlertTitle),
                message: Text(Localization.removeAllAlertMessage),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text(Localization.removeAllAlertConfirm), action: {
                    clearNotesAgreed.send()
                })
            )
        }
    }

    init(container: DependencyContainer, showNote: PassthroughSubject<Note, Never>, shareSheetContent: CurrentValueSubject<[AnyHashable], Never>) {
        let input = ArchiveViewModel.Input(
            didAppear: didAppear,
            archiveNote: archiveNote,
            unarchiveNote: unarchiveNote,
            deleteNote: deleteNote,
            pinNote: pinNote,
            clearNotes: clearNotes,
            clearNotesAgreed: clearNotesAgreed
        )
        
        self.container = container
        self.output = container.viewModel.archiveViewModel().transform(input, in: &cancellables)
        self.input = input
        
        self.showNote = showNote
        self.shareSheetContent = shareSheetContent
    }
}

// MARK: - Previews

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView(container: .defaultValue, showNote: .init(), shareSheetContent: .init([])).environment(\.colorScheme, .dark)
    }
}
