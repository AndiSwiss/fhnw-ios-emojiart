import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocumentViewModel
    @Binding var chosenPalette: String
    @State private var isPaletteEditorPresented = false
    
    var body: some View {
        HStack {
            Button(action: {
                chosenPalette = document.palette(before: chosenPalette)
            }) {
                Image(systemName: "arrow.left").imageScale(.large)
            }
            Button(action: {
                chosenPalette = document.palette(after: chosenPalette)
            }) {
                Image(systemName: "arrow.right").imageScale(.large)
            }
            Text(document.paletteNames[chosenPalette] ?? "")
            Image(systemName: "square.and.pencil").imageScale(.large)
                .onTapGesture {
                    isPaletteEditorPresented = true
                }
                .sheet(isPresented: $isPaletteEditorPresented, content: {
                    PaletteEditor(isPresented: $isPaletteEditorPresented, chosenPalette: $chosenPalette, document: document)
                })
        }
    }
}
