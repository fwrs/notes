//
//  SnackBar.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/15/21.
//

import SwiftUI

// MARK: - Snackbar

struct Snackbar: View {
    @Binding var isShowing: Bool
    
    private let presenting: AnyView
    private let text: Text
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    init<Presenting>(
        isShowing: Binding<Bool>,
        presenting: Presenting,
        text: Text
    ) where Presenting: View {
        
        _isShowing = isShowing
        self.presenting = AnyView(presenting)
        self.text = text
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.presenting
                VStack {
                    Spacer()
                    if self.isShowing {
                        HStack {
                            ZStack {
                                Color.black
                                
                                LinearGradient(gradient: .init(colors: [
                                    Color.darkAccentColor.opacity(0.6),
                                    Color.darkAccentColor.opacity(0.8)
                                ]), startPoint: .top, endPoint: .bottom)
                                
                                HStack {
                                    self.text
                                        .foregroundColor(Color.white.opacity(0.75))
                                        .font(.system(size: 17, weight: .bold))
                                    Spacer()
                                }.padding()
                            }.frame(minWidth: .zero, maxWidth: .infinity).shadow(radius: 3).clipShape(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                            ).padding(.horizontal, 26).onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        self.isShowing = false
                                    }
                                }
                            }
                        }.frame(height: 28).transition(.asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .move(edge: .trailing))
                        ).animation(Animation.spring())
                    }
                    Spacer().frame(height: 118)
                }
            }
        }
    }
    
}

// MARK: - View extension

extension View {
    func snackBar(isShowing: Binding<Bool>,
                  text: Text) -> some View {
        Snackbar(isShowing: isShowing,
                 presenting: self,
                 text: text)
    }
}
