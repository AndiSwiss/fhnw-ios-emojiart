import SwiftUI

struct PaletteEditor: View {
    @Binding var isPresented: Bool
    @Binding var chosenPalette: String
    @ObservedObject var document: EmojiArtDocumentViewModel
    @State private var paletteNameInput: String
    @State private var emojisToAdd = ""

    init(isPresented: Binding<Bool>, chosenPalette: Binding<String>, document: EmojiArtDocumentViewModel) {
        self._isPresented = isPresented
        self._chosenPalette = chosenPalette // Binding.init expects Binding
        self.document = document // ObservedObject.init from wrappedValue
        paletteNameInput = document.paletteNames[chosenPalette.wrappedValue] ?? ""
    }

    var body: some View {
        VStack {
            ZStack {
                Text("Edit Palette")
                    .font(.headline)
                    .padding()
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Done")
                            .padding()
                    }
                }
            }
            Form {
                Section {
                    TextField("Palette Name", text: $paletteNameInput, onEditingChanged: { isEditing in
                        if !isEditing {
                            document.renamePalette(chosenPalette, to: paletteNameInput)
                        }
                    })
                    TextField("Add Emojis", text: $emojisToAdd) { isEditing in
                        if !isEditing {
                            chosenPalette = document.addEmoji(emojisToAdd, toPalette: chosenPalette)
                            emojisToAdd = ""
                        }
                    }
                }
                Section(header: Text("Remove Emojis")) {
                    let emojiSize: CGFloat = 40
                    let emojis = chosenPalette.map { String($0) }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: emojiSize))]) {
                        ForEach(emojis, id: \.self) { emoji in
                            Text(emoji)
                                .onTapGesture {
                                    withAnimation {
                                        chosenPalette = document.removeEmojis(emoji, fromPalette: chosenPalette)
                                    }
                                }
                                .font(.system(size: emojiSize))
                        }
                    }
                }

            }
        }
    }
}
