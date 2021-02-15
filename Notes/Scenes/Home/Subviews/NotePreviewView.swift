//
//  NotePreviewView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine
import Kingfisher
import SwiftUI

// MARK: - User interface

struct NotePreviewView: View {
    private typealias Localization = LocalizedStringKey.Home.NotePreview
    
    let note: Note
    
    private let formatter = DateFormatter()
    
    let archiveNote: PassthroughSubject<String, Never>
    let unarchiveNote: PassthroughSubject<String, Never>
    let deleteNote: PassthroughSubject<String, Never>
    let pinNote: PassthroughSubject<String, Never>
    let showNote: PassthroughSubject<Note, Never>
    let shareSheetContent: CurrentValueSubject<[AnyHashable], Never>
    
    @State private var shouldShowOptions = false
    @State private var showButtons = [false, false, false, false, false]
    
    init(
        note: Note,
        archiveNote: PassthroughSubject<String, Never>,
        unarchiveNote: PassthroughSubject<String, Never>,
        deleteNote: PassthroughSubject<String, Never>,
        pinNote: PassthroughSubject<String, Never>,
        showNote: PassthroughSubject<Note, Never>,
        shareSheetContent: CurrentValueSubject<[AnyHashable], Never>
    ) {
        self.note = note
        formatter.dateFormat = "dd.MM HH:mm"
        
        self.archiveNote = archiveNote
        self.unarchiveNote = unarchiveNote
        self.deleteNote = deleteNote
        self.pinNote = pinNote
        self.showNote = showNote
        self.shareSheetContent = shareSheetContent
    }
    
    var body: some View {
        let hideButtons = {
            for (index, delay) in [0, 0.08, 0.11, 0.14, 0.17].enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showButtons[index] = false
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    shouldShowOptions = false
                }
            }
        }
        
        ZStack {
            LinearGradient(gradient: .init(colors: [
                Color(red: 0.08, green: 0.08, blue: 0.08),
                Color(red: 0.085, green: 0.085, blue: 0.095)
            ]), startPoint: .top, endPoint: .bottom)
            ZStack {
                Color(UIColor.systemBackground)
                ZStack {
                    VStack(spacing: 4) {
                        HStack {
                            if let colorValue = note.noteColor.colorValue {
                                ZStack {
                                    colorValue
                                }.frame(width: 15, height: 15).clipShape(RoundedPolygon(sides: 3, cornerRadius: 2)).rotationEffect(.degrees(90)).offset(x: -3)
                                Spacer().frame(width: 1)
                            }
                            Text(note.title.isEmpty ? Localization.untitledNote : LocalizedStringKey(note.title)).font(.system(size: 15, weight: .bold)).truncationMode(.middle)
                            Spacer().frame(width: 8)
                            Text(formatter.string(from: note.date)).foregroundColor(.secondary).font(.system(size: 15))
                            Spacer()
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    shouldShowOptions.toggle()
                                }
                                for (index, delay) in [0.08, 0.11, 0.14, 0.17, 0.20].enumerated() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            showButtons[index] = true
                                        }
                                    }
                                }
                            } label: {
                                Image.gearShape.foregroundColor(
                                    Color(red: 1, green: 1, blue: 1, opacity: 0.8)
                                ).font(.system(size: 15, weight: .medium))
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.horizontal, 15)
                        if note.isProtected {
                            HStack(spacing: 3) {
                                Image.lockShield
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                Text(Localization.protected)
                                    .lineLimit(6)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.horizontal, 15)
                        } else {
                            Text(note.content.isEmpty ? "Empty note" : note.content)
                                .lineLimit(6).fixedSize(horizontal: false, vertical: true)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 15))
                                .padding(.horizontal, 15)
                        }
                        
                        if !note.attachments.isEmpty && !note.isProtected {
                            Spacer().frame(height: 1)
                            HStack(spacing: 10) {
                                Spacer().frame(width: 3)
                                ForEach(note.attachments, id: \.url) { image in
                                    KFImage(image.url)
                                        .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 0, height: 60)))
                                        .scaleFactor(UIScreen.main.scale)
                                        .downloadPriority(1)
                                        .cacheOriginalImage()
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                }
                                Spacer()
                            }.frame(height: 40)
                        }
                    }
                }.padding(.vertical, 12).scaleEffect(shouldShowOptions ? 0.7 : 1)
            }.clipShape(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
            ).padding(2).opacity(shouldShowOptions ? 0 : 1)
            if shouldShowOptions {
                HStack(spacing: .zero) {
                    Button {
                        if note.isArchived {
                            deleteNote.send(note.id)
                        } else {
                            archiveNote.send(note.id)
                        }
                    } label: {
                        (note.isArchived ? Image.trash : Image.archiveBox).font(
                            .system(size: 24, weight: .regular)
                        ).foregroundColor(note.isArchived ? .red : .orange)
                    }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center).scaleEffect(showButtons[0] ? 1 : 0.01).opacity(showButtons[0] ? 0.8 : 0)
                    Button {
                        if note.isArchived {
                            unarchiveNote.send(note.id)
                        } else {
                            pinNote.send(note.id)
                            hideButtons()
                        }
                    } label: {
                        if note.isArchived {
                            Image.archiveBox.font(
                                .system(size: 24, weight: .regular)
                            ).foregroundColor(.orange)
                        } else {
                            Image.pin.font(
                                .system(size: 24, weight: .regular)
                            ).foregroundColor(note.isPinned ? .yellow : .white).rotationEffect(.degrees(45))
                        }
                    }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center).scaleEffect(showButtons[1] ? 1 : 0.01).opacity(showButtons[1] ? 0.8 : 0)
                    Button {
                        shareSheetContent.send([note.title, note.content])
                    } label: {
                        Image.squareAndArrowUp.font(
                            .system(size: 24, weight: .regular)
                        ).foregroundColor(.white)
                    }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center).scaleEffect(showButtons[2] ? 1 : 0.01).opacity(showButtons[2] ? 0.8 : 0)
                    Button {
                        showNote.send(note)
                    } label: {
                        Image.squareAndPencil.font(
                            .system(size: 23, weight: .regular)
                        ).foregroundColor(.white)
                    }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center).scaleEffect(showButtons[3] ? 1 : 0.01).opacity(showButtons[3] ? 0.8 : 0)
                    Button {
                        hideButtons()
                    } label: {
                        Image.xMark.font(
                            .system(size: 26, weight: .regular)
                        ).foregroundColor(.white)
                    }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center).scaleEffect(showButtons[4] ? 1 : 0.01).opacity(showButtons[4] ? 0.8 : 0)
                }.padding(.horizontal, 28)
            }
        }.clipShape(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
        ).onTapGesture {
            if !shouldShowOptions {
                showNote.send(note)
            }
        }
    }
}

// MARK: - Previews

struct NotePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NotePreviewView(
            note: Note(),
            archiveNote: .init(),
            unarchiveNote: .init(),
            deleteNote: .init(),
            pinNote: .init(),
            showNote: .init(),
            shareSheetContent: .init([])
        ).environment(\.colorScheme, .dark).previewLayout(.fixed(width: 400, height: 300))
    }
}
