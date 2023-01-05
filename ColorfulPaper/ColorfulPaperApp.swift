//
//  ColorfulPaperApp.swift
//  ColorfulPaper
//
//  Created by LiYanan2004 on 2023/1/1.
//

import SwiftUI

@main
struct ColorfulPaperApp: App {
    var body: some Scene {
#if os(macOS)
        Window("Colorful Paper", id: "MAIN") {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
#else
        WindowGroup {
            ContentView()
        }
#endif
    }
}
