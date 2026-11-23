//
//  DIALApp.swift
//  DIAL
//
//  Created by Syon Aggarwal on 2/22/26.
//

import SwiftUI
import SwiftData

@main
struct DIALApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: AnalysisRecord.self)
        }
    }
}
