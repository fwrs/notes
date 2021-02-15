//
//  NavigationBar.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import Combine
import SwiftUI

// MARK: - User interface

struct NavigationBarView: View {
    @Binding var selectedTab: NavigationViewTab
    @Binding var centerButtonRotation: Angle
    
    let didTapComposeButton: PassthroughSubject<Void, Never>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: .init(colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.08),
                    Color(red: 0.08, green: 0.085, blue: 0.1)
                ]), startPoint: .top, endPoint: .bottom)
                ZStack {
                    HStack {
                        Button {
                            selectedTab = .home
                        } label: {
                            ZStack {
                                Image.house.font(.system(size: 12, weight: .black)).foregroundColor(Color.white.opacity(0.85)).frame(
                                    width: geometry.size.width / 3,
                                    height: geometry.size.height
                                )
                                if selectedTab == .home {
                                    VStack {
                                        Spacer()
                                        ZStack {
                                            Color.secondary.opacity(0.4)
                                        }.clipShape(Circle()).frame(width: 4, height: 4, alignment: .center)
                                        Spacer().frame(height: 15)
                                    }.transition(.opacity)
                                }
                            }
                        }
                        Spacer()
                    }
                    ZStack {
                        AccentButtonView(
                            image: Image.plus,
                            rotation: $centerButtonRotation
                        ) {
                            didTapComposeButton.send()
                        }.frame(width: 86, height: 33)
                    }
                    HStack {
                        Spacer()
                        Button {
                            selectedTab = .archive
                        } label: {
                            ZStack {
                                Image.archiveBox.font(.system(size: 14, weight: .black)).foregroundColor(Color.white.opacity(0.85)).frame(
                                    width: geometry.size.width / 3,
                                    height: geometry.size.height
                                )
                                if selectedTab == .archive {
                                    VStack {
                                        Spacer()
                                        ZStack {
                                            Color.secondary.opacity(0.4)
                                        }.clipShape(Circle()).frame(width: 4, height: 4, alignment: .center)
                                        Spacer().frame(height: 15)
                                    }.transition(.opacity)
                                }
                            }
                        }
                    }
                }.frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                )
            }.clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            ).shadow(color: Color.black.opacity(0.4), radius: 18, x: .zero, y: .zero)
        }
    }
}

// MARK: - Previews

struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView(
            selectedTab: .constant(.home),
            centerButtonRotation: .constant(.zero),
            didTapComposeButton: .init()
        ).environment(\.colorScheme, .dark).previewLayout(.fixed(width: 300, height: 56))
    }
}
