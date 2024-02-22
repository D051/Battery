//
//  BatteryApp.swift
//  Battery
//
//  Created by Dominik Schweigler on 19.02.24.
//

import SwiftUI

@main
struct BatteryApp: App {
    var body: some Scene {
        MenuBarExtra("Battery", systemImage: "bolt.fill") {
            ContentView()
        }
        .menuBarExtraStyle(WindowMenuBarExtraStyle())
    }
}
