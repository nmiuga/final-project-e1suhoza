//
//  Final_ProjectApp.swift
//  Final Project
//
//  Created by Emerson Suhoza on 4/13/26.
//

import SwiftUI

@main
struct Final_ProjectApp: App {
    @StateObject private var store = RestaurantStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
