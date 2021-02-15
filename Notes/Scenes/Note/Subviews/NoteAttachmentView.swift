//
//  NoteAttachmentView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/14/21.
//

import Combine
import Kingfisher
import SwiftUI

// MARK: - User interface

struct NoteAttachmentView: View {
    @Binding var showAttachmentView: Bool
    
    @State private var appeared = false
    
    let attachment: NoteAttachment
    let animationNamespace: Namespace.ID
    let deleteAttachment: PassthroughSubject<NoteAttachment, Never>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.7)
                KFImage(attachment.url).downloadPriority(1)
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: UIScreen.main.bounds.width, height: 0)))
                    .scaleFactor(UIScreen.main.scale)
                    .downloadPriority(1)
                    .cacheOriginalImage()
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: attachment.url, in: animationNamespace)
                    .animation(.easeInOut(duration: 0.2))
                VStack {
                    Spacer()
                    Button {
                        deleteAttachment.send(attachment)
                        withAnimation {
                            appeared = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showAttachmentView = false
                        }
                    } label: {
                        Image.trash.font(.system(size: 27)).foregroundColor(.white)
                    }
                    Spacer().frame(height: geometry.size.height * 0.2)
                }
            }.opacity(appeared ? 1 : 0).edgesIgnoringSafeArea(.all).onAppear {
                withAnimation {
                    appeared = true
                }
            }.onTapGesture {
                withAnimation {
                    appeared = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showAttachmentView = false
                }
            }
        }
    }
}

// MARK: - Previews

struct NoteAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        NoteAttachmentView(
            showAttachmentView: .constant(true),
            attachment: NoteAttachment(),
            animationNamespace: Namespace().wrappedValue,
            deleteAttachment: .init()
        ).environment(\.colorScheme, .dark).previewLayout(.fixed(width: 300, height: 56))
    }
}
