//
//  HomeViewStates.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/14/21.
//

import SwiftUI

struct HomeSectionTitle {
    let iconColor: Color
    let icon: Image
    let iconRotation: Angle
    let name: LocalizedStringKey
}

struct HomeSection {
    let title: HomeSectionTitle?
    let notes: [Note]
}

enum HomeMode: Equatable {
    case dashboard
    case emptyDashboard
    case searchResults
    case emptySearchResults
    
    var header: LocalizedStringKey {
        switch self {
        case .dashboard:
            return LocalizedStringKey.Home.titleDashboard
        case .searchResults:
            return LocalizedStringKey.Home.titleSearchResults
        default:
            return .init(String())
        }
    }
    
    var placeholderTitle: LocalizedStringKey {
        switch self {
        case .emptyDashboard:
            return LocalizedStringKey.Home.placeholderEmptyDashboard
        case .emptySearchResults:
            return LocalizedStringKey.Home.placeholderEmptySearchResults
        default:
            return .init(String())
        }
    }
    
    var placeholderSubitle: LocalizedStringKey {
        switch self {
        case .emptyDashboard:
            return LocalizedStringKey.Home.placeholderEmptyDashboardHint
        case .emptySearchResults:
            return LocalizedStringKey.Home.placeholderEmptySearchResultsHint
        default:
            return .init(String())
        }
    }
}
