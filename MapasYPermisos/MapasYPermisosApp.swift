import SwiftUI

@main
struct MapasYPermisosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 680, minHeight: 700)
                #endif
        }
    }
}
