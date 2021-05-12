//
//  NoteView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/13/21.
//

import Combine
import Kingfisher
import SwiftUI

// MARK: - User interface

struct NoteView: View {
    private typealias Localization = LocalizedStringKey.Note
    
    private var container: DependencyContainer
    private var cancellables = [AnyCancellable]()

    @ObservedObject private var input: NoteViewModel.Input
    @ObservedObject private var output: NoteViewModel.Output

    let note: Note
    
    let didAppear = PassthroughSubject<Void, Never>()
    let hideNote: PassthroughSubject<Void, Never>
    let shareSheetContent: CurrentValueSubject<[AnyHashable], Never>
    let addAttachment = PassthroughSubject<NoteAttachment, Never>()
    let deleteAttachment = PassthroughSubject<NoteAttachment, Never>()
    let toggleNoteLock = PassthroughSubject<Void, Never>()
    
    @State private var attachmentImage: NoteAttachment?
    
    @State private var redactContent = false
    
    @Namespace var animationNamespace
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).onReceive(output.redactNoteContent) { shouldRedact in
                    redactContent = shouldRedact

            }
            VStack {
                Spacer().frame(height: 60)
                HStack {
                    Spacer().frame(width: 26)
                    Button {
                        hideNote.send()
                    } label: {
                        Image.xMark.foregroundColor(.white).font(.system(size: 15.5, weight: .heavy))
                    }
                    Text(Localization.title).font(.system(size: 16, weight: .heavy))
                    Spacer()
                }
                Spacer().frame(height: 10)
                TextField(Localization.titlePlaceholder, text: $input.noteTitle).font(.system(size: 17, weight: .bold)).padding(.horizontal, 24).allowsHitTesting(!redactContent)
                ZStack {
                    TextEditor(
                        text: redactContent ? .constant(NSLocalizedString("note.ellipsis", comment: String())) : $input.noteContent
                    ).padding(
                        .horizontal, -5
                    ).padding(
                        .vertical, -9
                    )
                    if output.showNoteContentPlaceholder && !redactContent {
                        HStack {
                            VStack {
                                Text(Localization.contentPlaceholder).foregroundColor(Color(UIColor.placeholderText))
                                Spacer()
                            }
                            Spacer()
                        }.allowsHitTesting(false)
                    }
                }.frame(minHeight: 0, maxHeight: .infinity).padding(.horizontal, 24)
                if !note.attachments.isEmpty && !redactContent {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Spacer().frame(width: 12)
                            ForEach(note.attachments, id: \.url) { image in
                                if attachmentImage?.url != image.url {
                                    Button {
                                        output.showAttachmentView = true
                                        attachmentImage = image
                                    } label: {
                                        KFImage(image.url)
                                            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 0, height: 60)))
                                            .scaleFactor(UIScreen.main.scale)
                                            .downloadPriority(1)
                                            .cacheOriginalImage()
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                    }
                                    .matchedGeometryEffect(id: image.url, in: animationNamespace)
                                    .animation(.easeInOut(duration: 0.2))
                                }
                            }
                            Spacer().frame(width: 12)
                        }
                    }.frame(height: 60)
                }
                Spacer().frame(height: 102)
            }.onAppear {
                didAppear.send()
            }.onTapGesture {
                UIApplication.shared.endEditing()
            }
            VStack {
                Spacer()
                NoteControlPanelView(
                    note: note,
                    shareSheetContent: shareSheetContent,
                    showColorPickerPopup: $output.showColorPickerPopup,
                    showAttachmentPopup: $output.showAttachmentPopup,
                    isNoteLocked: $input.noteLock, toggleNoteLock: toggleNoteLock
                ).frame(width: 218, height: 40).allowsHitTesting(!redactContent)
                Spacer().frame(height: 40)
            }.onReceive(output.$showAttachmentView.filter { !$0 }) { _ in
                attachmentImage = nil
            }
            if output.showColorPickerPopup {
                ColorPickerPopupView(color: $input.noteColor, showColorPicker: $output.showColorPickerPopup)
            }
            if output.showAttachmentPopup {
                AddAttachmentPopupView(showAttachmentPopup: $output.showAttachmentPopup, noteAttachments: Array(note.attachments), addAttachment: input.addAttachment)
            }
            if output.showAttachmentView, let image = attachmentImage {
                NoteAttachmentView(
                    showAttachmentView: $output.showAttachmentView,
                    attachment: image,
                    animationNamespace: animationNamespace,
                    deleteAttachment: input.deleteAttachment
                )
            }
        }
    }

    init(container: DependencyContainer, note: Note, hideNote: PassthroughSubject<Void, Never>, shareSheetContent: CurrentValueSubject<[AnyHashable], Never>) {
        let input = NoteViewModel.Input(
            note: note,
            didAppear: didAppear,
            hideNote: hideNote,
            addAttachment: addAttachment,
            deleteAttachment: deleteAttachment,
            toggleNoteLock: toggleNoteLock
        )
        
        self.container = container
        self.output = container.viewModel.noteViewModel().transform(input, in: &cancellables)
        self.input = input
        
        self.note = note
        self.hideNote = hideNote
        self.shareSheetContent = shareSheetContent
    }
}

// MARK: - Previews

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(container: .defaultValue, note: Note(), hideNote: .init(), shareSheetContent: .init([])).environment(\.colorScheme, .dark)
    }
}
