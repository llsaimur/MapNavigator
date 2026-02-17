//
//  TransportType.swift
//  MapNavigator
//
//  Created by Saimur Rashid on 2/17/26.
//

import MapKit

enum TransportType: String, CaseIterable, Identifiable {
    case automobile, transit, walking, cycling
    var id: Self { self }
    
    var mkType: MKDirectionsTransportType {
        switch self {
        case .automobile: return .automobile
        case .transit: return .transit
        case .walking: return .walking
        case .cycling: return .walking
        }
    }
    
    var icon: String {
        switch self {
        case .automobile: return "car.fill"
        case .transit: return "bus.fill"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        }
    }
}
