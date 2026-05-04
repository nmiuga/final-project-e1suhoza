//
//  ContentView.swift
//  Final Project
//
//  Created by Emerson Suhoza on 4/13/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        RestaurantListView()
    }
}

#Preview {
    ContentView()
        .environmentObject(RestaurantStore())
}
