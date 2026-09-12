import SwiftUI

struct ContentView: View {
    // Replace this with the exact KanColle/DMM launch URL once the
    // navigation flow is finalized.
    private let startURL = URL(string: "https://www.dmm.com/")!

    var body: some View {
        GameWebView(url: startURL)
            .ignoresSafeArea()
    }
}
