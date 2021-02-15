//
//  AddAttachmentPopupView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/14/21.
//

import Combine
import SwiftUI

// MARK: - User interface

struct AddAttachmentPopupView: View {
    private typealias Localization = LocalizedStringKey.Note.AddAttachment
    
    @Binding var showAttachmentPopup: Bool
    
    @State private var appeared = false
    @State private var showGalleryPickerSheet = false
    @State private var galleryPickerIsCamera = false
    
    let noteAttachments: [NoteAttachment]
    let addAttachment: PassthroughSubject<NoteAttachment, Never>
    
    var body: some View {
        ZStack {
            Color.black.opacity(appeared ? 0.7 : 0).animation(.easeInOut, value: appeared).onTapGesture {
                appeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showAttachmentPopup = false
                }
            }
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.055)
                
                VStack {
                    Spacer().frame(height: 8)
                    
                    HStack {
                        Button {
                            appeared = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showAttachmentPopup = false
                            }
                        } label: {
                            Image.xMark.foregroundColor(.white).font(.system(size: 15.5, weight: .heavy))
                        }
                        Text(Localization.title).font(.system(size: 16, weight: .heavy))
                        Spacer()
                    }.padding(.leading, 2)
                    
                    Spacer().frame(height: 20)
                    
                    Button {
                        if let pasteboardString = UIPasteboard.general.string,
                           let url = URL(string: pasteboardString),
                           !noteAttachments.contains(where: { $0.url == url }) {
                            let attachment = NoteAttachment()
                            attachment.isLocal = false
                            attachment.url = url
                            addAttachment.send(attachment)
                        }
                        
                        appeared = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showAttachmentPopup = false
                        }
                    } label: {
                        Spacer().frame(width: 2.5)
                        HStack(spacing: 7.5) {
                            Image.docOnClipboard.foregroundColor(Color.white.opacity(0.6)).font(.system(size: 15, weight: .medium))
                            Text(Localization.optionClipboardURL).foregroundColor(Color.white.opacity(0.6)).font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                    }.padding(.leading, 2).frame(height: 20)
                    
                    Spacer().frame(height: 8)
                    
                    Button {
                        galleryPickerIsCamera = false
                        showGalleryPickerSheet = true
                    } label: {
                        HStack(spacing: 5) {
                            Image.photoOnRectangleAngled.foregroundColor(Color.white.opacity(0.6)).font(.system(size: 15, weight: .medium))
                            Text(Localization.optionGallery).foregroundColor(Color.white.opacity(0.6)).font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                    }.padding(.leading, 2).frame(height: 20)
                    
                    Spacer().frame(height: 8)
                    
                    Button {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            galleryPickerIsCamera = true
                        }
                        showGalleryPickerSheet = true
                    } label: {
                        HStack(spacing: 5) {
                            Image.camera.foregroundColor(Color.white.opacity(0.6)).font(.system(size: 15, weight: .medium))
                            Text(Localization.optionCamera).foregroundColor(Color.white.opacity(0.6)).font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                    }.padding(.leading, 2).frame(height: 20)
                    
                    Spacer().frame(height: 8)
                    
                }.padding(.horizontal, 16)
            }.frame(maxWidth: 340, maxHeight: 148).clipShape(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
            ).padding(26).shadow(
                color: Color(red: 0.025, green: 0.025, blue: 0.028, opacity: 0.5),
                radius: 20,
                x: 0,
                y: 10
            ).opacity(appeared ? 1 : 0).offset(x: .zero, y: appeared ? .zero : 50).animation(.interpolatingSpring(stiffness: 400, damping: 40), value: appeared)
        }.edgesIgnoringSafeArea(.all).onAppear {
            appeared = true
        }.sheet(isPresented: $showGalleryPickerSheet) {
            ImagePickerView(sourceType: galleryPickerIsCamera ? .camera : .photoLibrary) { image in
                if !noteAttachments.contains(where: { $0.url == image }) {
                    let attachment = NoteAttachment()
                    attachment.isLocal = true
                    attachment.url = image
                    addAttachment.send(attachment)
                }
                appeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showAttachmentPopup = false
                }
            }
        }
    }
}

// MARK: - Previews

struct AddAttachmentPopupView_Previews: PreviewProvider {
    static var previews: some View {
        AddAttachmentPopupView(showAttachmentPopup: .constant(true), noteAttachments: [], addAttachment: .init())
            .environment(\.colorScheme, .dark).previewLayout(.fixed(width: 300, height: 56))
    }
}
