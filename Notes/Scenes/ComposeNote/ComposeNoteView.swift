//
//  ComposeNoteView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/13/21.
//

import Combine
import Kingfisher
import SwiftUI

// MARK: - User interface

struct ComposeNoteView: View {
    private typealias Localization = LocalizedStringKey.ComposeNote
    
    private var container: DependencyContainer
    private var cancellables = [AnyCancellable]()

    @ObservedObject private var input: ComposeNoteViewModel.Input
    @ObservedObject private var output: ComposeNoteViewModel.Output
    
    let hideSheet: PassthroughSubject<Void, Never>
    let saveButtonPushed = PassthroughSubject<Void, Never>()
    let addAttachment = PassthroughSubject<NoteAttachment, Never>()
    let deleteAttachment = PassthroughSubject<NoteAttachment, Never>()
    
    @State private var attachmentImage: NoteAttachment?
    
    @Namespace var animationNamespace

    var body: some View {
        ZStack {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.042)
                
                VStack(spacing: 6) {
                    Text(Localization.title).font(.system(size: 28, weight: .heavy))
                        .frame(maxWidth: .infinity, alignment: .topLeading).padding(.horizontal, 24)
                    Spacer().frame(height: 2)
                    TextField(Localization.titlePlaceholder, text: $input.noteTitle).font(.system(size: 17, weight: .bold)).padding(.horizontal, 24)
                    ZStack {
                        TextEditor(text: $input.noteContent).padding(.horizontal, -5).padding(.vertical, -9)
                        if output.showNoteContentPlaceholder {
                            HStack {
                                VStack {
                                    Text(Localization.contentPlaceholder).foregroundColor(Color(UIColor.placeholderText))
                                    Spacer()
                                }
                                Spacer()
                            }.allowsHitTesting(false)
                        }
                    }.frame(minHeight: 0, maxHeight: .infinity).padding(.horizontal, 24)
                    
                    if !input.noteAttachments.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Spacer().frame(width: 12)
                                ForEach(input.noteAttachments, id: \.url) { image in
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
                                                .frame(height: 48)
                                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                        }
                                        .matchedGeometryEffect(id: image.url, in: animationNamespace)
                                        .animation(.easeInOut(duration: 0.2))
                                    }
                                }
                                Spacer().frame(width: 12)
                            }
                        }.frame(height: 48)
                    }
                    
                    Spacer().frame(height: 0)
                    
                    VStack {
                        Button {
                            output.showAttachmentPopup = true
                        } label: {
                            HStack(spacing: 5) {
                                Image.paperclip.foregroundColor(
                                    Color.white.opacity(0.7)
                                ).font(
                                    .system(size: 13.5, weight: .medium)
                                )
                                Text(Localization.buttonAttach).foregroundColor(
                                    Color.white.opacity(0.7)
                                ).font(
                                    .system(size: 14.5, weight: .medium)
                                )
                                Spacer()
                            }.frame(height: 33)
                        }
                        
                        Spacer().frame(height: 6)
                        
                        Button {
                            saveButtonPushed.send()
                        } label: {
                            HStack(spacing: 5) {
                                Image.docOnClipboard.foregroundColor(
                                    Color.accentColor.opacity(0.7)
                                ).font(
                                    .system(size: 13.5, weight: .medium)
                                )
                                Text(Localization.buttonSave).foregroundColor(
                                    Color.accentColor.opacity(0.7)
                                ).font(
                                    .system(size: 14.5, weight: .medium)
                                )
                                Spacer()
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity)
                    }.padding(.horizontal, 24)
                    Spacer().frame(height: 56)
                }.padding(.vertical, 24)
            }.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)).onReceive(output.hideSheet) { _ in
                hideSheet.send()
            }
            ZStack {
                if output.showAttachmentPopup {
                    AddAttachmentPopupView(showAttachmentPopup: $output.showAttachmentPopup, noteAttachments: [], addAttachment: input.addAttachment)
                }
                if output.showAttachmentView, let image = attachmentImage {
                    NoteAttachmentView(
                        showAttachmentView: $output.showAttachmentView,
                        attachment: image,
                        animationNamespace: animationNamespace,
                        deleteAttachment: input.deleteAttachment
                    )
                }
            }.onReceive(output.$showAttachmentView.filter { !$0 }) { _ in
                attachmentImage = nil
            }.ignoresSafeArea()
        }
    }

    init(container: DependencyContainer, hideSheet: PassthroughSubject<Void, Never>) {
        let input = ComposeNoteViewModel.Input(saveButtonPushed: saveButtonPushed, addAttachment: addAttachment, deleteAttachment: deleteAttachment)
        
        self.container = container
        self.output = container.viewModel.composeNoteViewModel().transform(input, in: &cancellables)
        self.input = input
        
        self.hideSheet = hideSheet
    }
}

// MARK: - Previews

struct ComposeNoteView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeNoteView(container: .defaultValue, hideSheet: .init()).environment(\.colorScheme, .dark)
    }
}
