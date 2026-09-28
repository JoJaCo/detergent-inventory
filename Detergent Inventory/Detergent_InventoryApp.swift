//
//  Detergent_InventoryApp.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 9/21/26.
//

import SwiftUI

@main
struct DetergentInventoryApp: App {
    @StateObject private var store = InventoryStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
