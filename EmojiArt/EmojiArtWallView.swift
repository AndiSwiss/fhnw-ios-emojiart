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
                            Image(uiImage: backgroundImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
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

