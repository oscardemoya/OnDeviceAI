//
//  RecipeCartApp.swift
//  RecipeCart
//
//  Created by Oscar De Moya on 2025/8/25.
//

import SwiftUI
import OSLog

let logger = Logger(subsystem: "com.koombea.OnDeviceAI", category: "general")

@main
struct RecipeCartApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeView()
#if os(macOS) || targetEnvironment(macCatalyst)
            .frame(minWidth: 400, maxWidth: 800, minHeight: 400, maxHeight: 800)
#endif
        }
#if os(macOS) || targetEnvironment(macCatalyst)
        .defaultSize(width: 500, height: 700)
        .windowResizability(.contentSize)
#endif
    }
}
