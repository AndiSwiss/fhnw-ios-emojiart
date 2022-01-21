import SwiftUI

struct EmojiArtColorPicker: View {
    @Binding var isPresented: Bool
    @ObservedObject var document: EmojiArtDocumentViewModel
    @State var backgroundColor: Color
    @State var opacity: Double

    init(isPresented: Binding<Bool>, document: EmojiArtDocumentViewModel) {
        self._isPresented = isPresented
        self.document = document // ObservedObject.init from wrappedValue
        backgroundColor = Color(document.backgroundColor)
        opacity = document.backgroundColor.getAlpha
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
                        document.backgroundColor = UIColor(newColor)
                        // Update the opacity slider as well:
                        opacity = document.backgroundColor.getAlpha
                    }
                Section(header: Text("Opacity")) {
                    Slider(value: $opacity)
                        .onChange(of: opacity) { newValue in
                            document.opacity = newValue
                            // Update the color-picker as well:
                            backgroundColor = Color(document.backgroundColor)
                        }
                }
            }
        }
    }
}
