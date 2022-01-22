import SwiftUI

struct EmojiArtWallView: View {
    var store: EmojiArtDocumentStore
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(store.documents, id: \.self) { document in
                        let destination = EmojiArtDocumentView(document: document)
                            .navigationTitle(store.name(for: document))
                        let backgroundImage = document.backgroundImage ?? UIImage()
                        NavigationLink(destination: destination) {
                            Color.clear
                                .overlay(Image(uiImage: backgroundImage)
                                            .resizable()
                                            .scaledToFill())
                                .aspectRatio(1, contentMode: .fit)
                                .clipped()
                                .border(Color.black)
                        }
                    }
                }
                    .navigationBarTitle("Art Wall")
                    .padding()
            }
                .padding()
        }
    }
}

