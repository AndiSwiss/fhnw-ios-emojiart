import SwiftUI

struct EmojiArtDocumentView: View {

    @ObservedObject var document: EmojiArtDocumentViewModel
    @State private var chosenPalette: String
    @State private var isPastingExplanationPresented = false
    @State private var isColorPickerEditorPresented = false

    init(document: EmojiArtDocumentViewModel) {
        self.document = document
        chosenPalette = document.defaultPalette
    }

    private var isLoading: Bool {
        document.backgroundImage == nil && document.backgroundURL != nil
    }

    var body: some View {
        VStack {
            createPalette()
            GeometryReader { geometry in
                ZStack{
                    createBackground(geometry: geometry)
                    createEmojiLayer(geometry: geometry)
                }
                    .gesture(doubleTapGesture(in: geometry))
            }
                .gesture(panGesture())
                .gesture(zoomGesture())
                .clipped()
        }
        .toolbar {
            // show elapsed time
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "timer").imageScale(.large) //Icon timer
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(document.elapsedTime)\(" s")")
            }
            // color picker
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isColorPickerEditorPresented = true
                } label: {
                    Image(systemName: "paintbrush.fill").imageScale(.large)
                }
                    .sheet(isPresented: $isColorPickerEditorPresented) {
                        EmojiArtColorPicker(isPresented: $isColorPickerEditorPresented, document: document)
                    }
            }
            // icon for pasting image via URL
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let url = UIPasteboard.general.url {
                        document.backgroundURL = url
                    } else {
                        isPastingExplanationPresented = true
                    }
                } label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                }
                    .alert(isPresented: $isPastingExplanationPresented) {
                        Alert(title: Text("Paste Background Image"), message: Text("Copy the URL of an image to set it as background image"))
                    }
            }
        }
            .onAppear {
                document.startTimer()
            }
            .onDisappear {
                document.cancelTimer()
            }
    }

    private func createPalette() -> some View {
        HStack {
            PaletteChooser(document: document, chosenPalette: $chosenPalette)
            ScrollView(.horizontal) {
                HStack{
                    ForEach(chosenPalette.map{String($0)},id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: defaultEmojiSize))
                            .onDrag { NSItemProvider(object: emoji as NSString) }
                    }
                }
            }
        }.padding(.horizontal)
    }

    private func createBackground(geometry: GeometryProxy) -> some View {
        // First, paint white (then opacity of backgroundColor works as expected!)
        Color.white.overlay(
                    // Then, paint the backgroundColor
                    Color(document.backgroundColor).overlay(
                            // Lastly, paint the backgroundImage
                            Group {
                                if let image = document.backgroundImage {
                                    Image(uiImage: image)
                                        .scaleEffect(zoomScale)
                                        .position(toCanvasCoordinate(from: CGPoint(x: 0, y: 0), in: geometry))
                                }
                            }
                    )
            )
            .edgesIgnoringSafeArea([.horizontal, .bottom])
            .onDrop(of: [.url, .plainText, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, location: location, geometry: geometry)
            }
            .onReceive(document.$backgroundImage) { backgroundImage in
                zoomToFit(backgroundImage: backgroundImage, in: geometry)
            }
    }

    private func createEmojiLayer(geometry: GeometryProxy) -> some View {
        Group {
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            } else {
                ForEach(document.emojis) { emoji in
                    Text(emoji.text)
                        .font(font(for: emoji))
                        .position(toCanvasCoordinate(from: emoji.location, in: geometry))
                }
            }
        }
    }

    private func drop(providers: [NSItemProvider], location: CGPoint, geometry: GeometryProxy) -> Bool {
        var isDropHandled = providers.loadObjects(ofType: URL.self) { url in
            document.backgroundURL = url
        }
        if !isDropHandled {
            isDropHandled = providers.loadObjects(ofType: String.self, using: { string in
                let emojiLocation = toEmojiCoordinate(from: location, in: geometry)
                document.addEmoji(string, at: emojiLocation, size: defaultEmojiSize)
            })
        }
        return isDropHandled
    }

    private func font(for emoji: EmojiArtModel.Emoji) -> Font {
        let fontSize = emoji.fontSize * zoomScale
        return Font.system(size: fontSize)

    }

    // MARK: - Panning
    @State private var steadyPanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    private var panOffset: CGSize {
        steadyPanOffset + gesturePanOffset
    }

    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset, body: { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation
            })
            .onEnded { finalDragGestureValue in
                steadyPanOffset = panOffset + finalDragGestureValue.translation
            }
    }

    // MARK: - Zooming
    @State private var steadyZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    private var zoomScale: CGFloat {
        steadyZoomScale * gestureZoomScale
    }

    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale, body: { magnifyBy, gestureZoomScale, _ in
                gestureZoomScale = magnifyBy
            })
            .onEnded { finalDragGestureValue in
                steadyZoomScale *= finalDragGestureValue
            }
    }

    private func doubleTapGesture(in geometry: GeometryProxy) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                zoomToFit(backgroundImage: document.backgroundImage, in: geometry)
            }
    }

    private func zoomToFit(backgroundImage: UIImage?, in geometry: GeometryProxy) {
        if let image = backgroundImage {
            let horizontalZoom = geometry.size.width / image.size.width
            let verticalZoom = geometry.size.height / image.size.height
            steadyPanOffset = .zero
            steadyZoomScale = min(horizontalZoom, verticalZoom)
        }
    }

    // MARK: - Positioning & Sizing Emojis
    private func toCanvasCoordinate(from emojiCoordinate: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + emojiCoordinate.x * zoomScale + panOffset.width,
            y: center.y + emojiCoordinate.y * zoomScale + panOffset.height
        )
    }

    private func toEmojiCoordinate(from canvasCoordinate: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: (canvasCoordinate.x - center.x - panOffset.width) / zoomScale,
            y: (canvasCoordinate.y - center.y - panOffset.height) / zoomScale
        )
    }

    // MARK: - Drawing constants
    private let defaultEmojiSize: CGFloat = 40
}
