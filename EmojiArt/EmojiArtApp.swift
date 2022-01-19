import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentChooser(store: EmojiArtDocumentStore())
        }
    }
}
