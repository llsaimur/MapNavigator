//
//  MapButtonIcon.swift
//  MapNavigator
//
//  Created by Saimur Rashid on 2/17/26.
//

import SwiftUI

struct MapButtonIcon: View {
    let systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(.title2)
            .foregroundColor(.white)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .shadow(radius: 4)
    }
}
