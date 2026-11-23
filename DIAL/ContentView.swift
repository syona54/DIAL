import SwiftUI
import SwiftData

// MARK: - App Entry Point
// In your @main App file, set up the ModelContainer like this:
//
// @main#imageLiteral(resourceName: "DIAL.png")
// struct DIALApp: App {
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//                 .modelContainer(for: AnalysisRecord.self)
//         }
//     }
// }

// MARK: - Tab Container

struct ContentView: View {

    @State private var selectedTab: Tab = .home

    enum Tab { case home, history, model }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(Tab.home)
                .tabItem {
                    Label("Analyze", systemImage: "lungs.fill")
                }

            HistoryView()
                .tag(Tab.history)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            ModelInfoView()
                .tag(Tab.model)
                .tabItem {
                    Label("Model", systemImage: "brain.head.profile")
                }
        }
        .tint(Color(red: 88/255, green: 54/255, blue: 196/255))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: AnalysisRecord.self, inMemory: true)
}
