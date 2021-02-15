//
//  AccentButtonView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine
import SwiftUI

// MARK: - User interface

struct AccentButtonView: View {
    let image: Image
    
    @Binding var rotation: Angle
    
    let didTap: () -> Void
    
    var body: some View {
        Button(action: didTap) {
            ZStack {
                LinearGradient(gradient: .init(colors: [
                    Color.accentColor.opacity(0.4), Color.accentColor.opacity(0.3)
                ]), startPoint: .top, endPoint: .bottom)
                ZStack {
                    LinearGradient(gradient: .init(colors: [
                        Color.darkAccentColor.opacity(0.8), Color.darkAccentColor
                    ]), startPoint: .top, endPoint: .bottom)
                    image.foregroundColor(
                        Color.white.opacity(0.85)
                    ).font(
                        .system(size: 14.5, weight: .heavy)
                    ).rotationEffect(rotation).animation(.easeInOut(duration: 0.15), value: rotation)
                }.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)).padding(2)
            }.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
    }
}

// MARK: - Previews

struct AccentButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AccentButtonView(image: Image.plus, rotation: .constant(.zero)) {}
            .environment(\.colorScheme, .dark)
            .previewLayout(.fixed(width: 70, height: 45))
    }
}
