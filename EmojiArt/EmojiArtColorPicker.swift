import SwiftUI

struct EmojiArtColorPicker: View {
    @Binding var isPresented: Bool
    @ObservedObject var document: EmojiArtDocumentViewModel
    @State var backgroundColor: Color

    init(isPresented: Binding<Bool>, document: EmojiArtDocumentViewModel) {
        self._isPresented = isPresented
        self.document = document // ObservedObject.init from wrappedValue
        backgroundColor = Color(white: 1)
    }

    var body: some View {
        VStack {
            ZStack {
                Text("Edit Color")
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
                ColorPicker("Background Color", selection: $backgroundColor)
                    .onChange(of: backgroundColor) { newColor in
                        document.backgroundColor = newColor
                    }
            }
        }
    }
}
