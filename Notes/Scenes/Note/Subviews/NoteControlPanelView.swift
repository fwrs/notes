//
//  NoteControlPanelView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/13/21.
//

import Combine
import SwiftUI

// MARK: - User interface

struct NoteControlPanelView: View {
    let note: Note
    let shareSheetContent: CurrentValueSubject<[AnyHashable], Never>
    
    @Binding var showColorPickerPopup: Bool
    @Binding var showAttachmentPopup: Bool
    @Binding var isNoteLocked: Bool
    
    let toggleNoteLock: PassthroughSubject<Void, Never>
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.12)
            
            HStack(spacing: 32) {
                Button {
                    showColorPickerPopup = true
                } label: {
                    Image.paintbrush.foregroundColor(note.noteColor.colorValue?.opacity(0.9) ?? Color.white.opacity(0.8))
                }
                Button {
                    showAttachmentPopup = true
                } label: {
                    Image.paperclip.foregroundColor(Color.white.opacity(0.8))
                }
                Button {
                    toggleNoteLock.send()
                } label: {
                    if isNoteLocked {
                        Image.lock.foregroundColor(Color.white.opacity(0.8))
                    } else {
                        Image.lockOpen.foregroundColor(Color.white.opacity(0.8))
                    }
                }
                Button {
                    shareSheetContent.send([note.title, note.content])
                } label: {
                    Image.squareAndArrowUp.foregroundColor(Color.white.opacity(0.8))
                }
            }.padding(10)
        }.clipShape(Capsule()).shadow(color: Color.gray.opacity(0.1), radius: 12, x: 0, y: 8)
    }
}

// MARK: - Previews

struct NoteControlPanelView_Previews: PreviewProvider {
    static var previews: some View {
        NoteControlPanelView(
            note: Note(),
            shareSheetContent: .init([]),
            showColorPickerPopup: .constant(false),
            showAttachmentPopup: .constant(false),
            isNoteLocked: .constant(false),
            toggleNoteLock: .init()
        ).environment(\.colorScheme, .dark).previewLayout(.fixed(width: 300, height: 56))
    }
}
