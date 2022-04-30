import SwiftUI

@main
struct App: SwiftUI.App {
    
    var body: some Scene {
        WindowGroup {
            HStack {
                ContentView().ignoresSafeArea()
                LinearGradient(colors: [.white, .black], startPoint: .top, endPoint: .bottom)
            }
        }
    }
}
