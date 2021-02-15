//
//  SearchBarHeaderView.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine
import SwiftUI

// MARK: - User interface

struct SearchBarHeaderView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                LinearGradient(gradient: .init(colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.08),
                    Color(red: 0.085, green: 0.085, blue: 0.095)
                ]), startPoint: .top, endPoint: .bottom)
                
                ZStack {
                    HStack(spacing: 6) {
                        Image.magnifyingGlass.foregroundColor(Color(
                            UIColor.placeholderText
                        )).font(.system(size: 14, weight: .medium, design: .default))
                        
                        TextField("Search for a note", text: $searchText).font(
                            .system(size: 15, weight: .semibold, design: .rounded)
                        )
                    }.padding(.horizontal, 10)
                }.clipShape(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                ).padding(2)
            }.clipShape(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
            )
            
            ZStack {
                LinearGradient(gradient: .init(colors: [
                    Color.accentColor.opacity(0.25), Color.accentColor.opacity(0.2)
                ]), startPoint: .top, endPoint: .bottom)
                
                Image.person.foregroundColor(Color.white.opacity(0.7)).font(.system(size: 17, weight: .bold))
            }.clipShape(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
            ).frame(width: 40)
        }
    }
}

// MARK: - Previews

struct SearchBarHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarHeaderView(searchText: .constant(.init()))
            .environment(\.colorScheme, .dark)
            .previewLayout(.fixed(width: 300, height: 56))
    }
}
