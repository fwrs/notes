//
//  ColorPickerPopupView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/14/21.
//

import Combine
import SwiftUI

// MARK: - User interface

struct ColorPickerPopupView: View {
    private typealias Localization = LocalizedStringKey.Note.ColorPicker
    
    @Binding var color: NoteColor
    @Binding var showColorPicker: Bool
    
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(appeared ? 0.7 : 0).animation(.easeInOut, value: appeared).onTapGesture {
                appeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showColorPicker = false
                }
            }
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.055)
                
                VStack {
                    HStack {
                        Button {
                            appeared = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showColorPicker = false
                            }
                        } label: {
                            Image.xMark.foregroundColor(.white).font(.system(size: 15.5, weight: .heavy))
                        }
                        Text(Localization.title).font(.system(size: 16, weight: .heavy))
                        Spacer()
                    }.padding(.leading, 2)
                    
                    Spacer().frame(height: 22)
                    
                    Button {
                        self.color = .none
                        appeared = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showColorPicker = false
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image.trash.foregroundColor(Color.white.opacity(0.6)).font(.system(size: 15, weight: .medium))
                            Text(Localization.buttonRemoveColor).foregroundColor(Color.white.opacity(0.6)).font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                    }.padding(.leading, 2)
                    
                    Spacer().frame(height: 8)
                    
                    HStack(spacing: 10) {
                        ForEach(NoteColor.allCases.dropFirst(), id: \.colorName) { color in
                            Button {
                                self.color = color
                                appeared = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showColorPicker = false
                                }
                            } label: {
                                ZStack {
                                    color.colorValue.opacity(0.78)
                                    ZStack {
                                        color.colorValue
                                        if self.color == color {
                                            Image.checkmark.foregroundColor(.white).font(.system(size: 14, weight: .black))
                                        }
                                    }.frame(width: 28, height: 28).clipShape(Circle())
                                }.frame(width: 32, height: 32).clipShape(Circle())
                            }
                        }
                        Spacer()
                    }.padding(3)
                }.padding(.horizontal, 16)
            }.frame(maxWidth: 340, maxHeight: 138).clipShape(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
            ).padding(26).shadow(
                color: Color(red: 0.025, green: 0.025, blue: 0.028, opacity: 0.5),
                radius: 20,
                x: 0,
                y: 10
            ).opacity(appeared ? 1 : 0).offset(x: .zero, y: appeared ? .zero : 50).animation(.interpolatingSpring(stiffness: 400, damping: 40), value: appeared)
        }.edgesIgnoringSafeArea(.all).onAppear {
            appeared = true
        }
    }
}

// MARK: - Previews

struct ColorPickerPopupView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerPopupView(color: .constant(.red), showColorPicker: .constant(true))
            .environment(\.colorScheme, .dark).previewLayout(.fixed(width: 300, height: 56))
    }
}
