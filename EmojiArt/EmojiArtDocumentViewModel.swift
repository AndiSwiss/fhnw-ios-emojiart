import SwiftUI
import Combine

class EmojiArtDocumentViewModel: ObservableObject, Hashable, Equatable, Identifiable {
    static func == (lhs: EmojiArtDocumentViewModel, rhs: EmojiArtDocumentViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: UUID
    
    static let palette: String =  "🐶🐱🐹🐰🦊🐼🐨🐯🐸🐵🐧🐦🐤🦆🦅🦇🐺"
    
    @Published private var emojiArtModel: EmojiArtModel
    private var emojiArtModelSink: AnyCancellable?
    @Published private(set) var backgroundImage: UIImage?
    var emojis: [EmojiArtModel.Emoji] { emojiArtModel.emojis }

    var backgroundURL: URL? {
        get {
            emojiArtModel.backgroundURL
        }
        set {
            emojiArtModel.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }


    init(id: UUID = UUID()) {
        self.id = id
        let userDefaultsKey = "EmojiArtDocumentViewModel.\(id.uuidString)"
        let emojiArtJson = UserDefaults.standard.data(forKey: userDefaultsKey)
        emojiArtModel = EmojiArtModel(json: emojiArtJson) ?? EmojiArtModel()
        emojiArtModelSink = $emojiArtModel.sink { emojiArtModel in
            print("JSON: \(emojiArtModel.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArtModel.json, forKey: userDefaultsKey)
        }
        fetchBackgroundImageData()
    }
    
    // MARK: - Intents
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArtModel.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }

    private var fetchImageSink: AnyCancellable?
    private func fetchBackgroundImageData() {
        fetchImageSink?.cancel()
        backgroundImage = nil
        if let url = emojiArtModel.backgroundURL {
            fetchImageSink = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, response in UIImage(data: data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .sink { fetchedImage in
                    self.backgroundImage = fetchedImage
                }
        }
    }
}

extension EmojiArtModel.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: x, y: y) }
}
