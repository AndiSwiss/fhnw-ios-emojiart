import SwiftUI

struct EmojiArtDocumentChooser: View {
    @ObservedObject var store: EmojiArtDocumentStore
    @State private var editMode = EditMode.inactive
    @State private var isFontPickerPresented = false
    @State private var chosenFont: Font = .custom("American Typewriter", size: UIFont.systemFontSize)

    private var initialDetailView: some View {
        let document = store.documents.first ?? EmojiArtDocumentViewModel()
        return EmojiArtDocumentView(document: document)
            .navigationTitle(store.name(for: document))
            .environment(\.font, chosenFont)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    let emojiArtDocumentView = EmojiArtDocumentView(document: document)
                        .navigationTitle(store.name(for: document))
                        .environment(\.font, chosenFont)
                    NavigationLink(destination: emojiArtDocumentView) {
                        EditableText(store.name(for: document), isEditing: editMode.isEditing, onChanged: { name in
                            store.setName(name, for: document)
                        }).environment(\.font, chosenFont)
                    }
                }
                .onDelete { indexSet in
                    indexSet
                        .map { store.documents[$0] }
                        .forEach { store.removeDocument($0) }
                }
            }
            .navigationBarTitle(store.name).environment(\.font, chosenFont)
            .toolbar {
                // Icon: Add document
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        store.addDocument()
                    }) {
                        Image(systemName: "plus").imageScale(.large)
                    }
                }
                // Icon: Font picker
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isFontPickerPresented = true
                    } label: {
                        Image(systemName: "textformat").imageScale(.large)
                    }
                        .sheet(isPresented: $isFontPickerPresented) {
                            FontPicker { font in
                                if let font = font {
                                    chosenFont = Font(UIFont(descriptor: font.fontDescriptor, size: UIFont.systemFontSize))
                                }
                                isFontPickerPresented = false
                            }
                        }
                }
                // Icon: Wall view
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: createWallView()) {
                        Image(systemName: "square.grid.2x2.fill").imageScale(.large)
                    }
                }
                // Icon: Edit button
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)

            createInitialDetailView()
        }
    }

    private func createInitialDetailView() -> some View {
        let document = store.documents.first ?? store.addDocument()
        return EmojiArtDocumentView(document: document)
            .navigationTitle(store.name(for: document))
            .environment(\.font, chosenFont)
    }

    private func createWallView() -> some View {
        EmojiArtWallView(store: store)
            .navigationTitle("Art Wall")
            .environment(\.font, chosenFont)
    }
}
