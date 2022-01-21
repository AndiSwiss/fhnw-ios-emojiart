import SwiftUI
import Combine

class EmojiArtDocumentViewModel: ObservableObject, Hashable, Equatable, Identifiable {
    static func ==(lhs: EmojiArtDocumentViewModel, rhs: EmojiArtDocumentViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: UUID
    static let palette: String = "🐶🐱🐹🐰🦊🐼🐨🐯🐸🐵🐧🐦🐤🦆🦅🦇🐺"

    @Published private var emojiArtModel: EmojiArtModel
    private var emojiArtModelSink: AnyCancellable?
    @Published private(set) var backgroundImage: UIImage?
    var emojis: [EmojiArtModel.Emoji] {
        emojiArtModel.emojis
    }
    var elapsedTime: Int
    var backgroundColor: Color

    var backgroundURL: URL? {
        get {
            emojiArtModel.backgroundURL
        }
        set {
            emojiArtModel.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }

    // MARK: - Init
    init(id: UUID = UUID()) {
        self.id = id
        // need to temporarily initialize 'elapsedTime', because if I try to do it after getting the
        // emojiArtModel, there will be the following error:
        //      self' used in property access '$emojiArtModel' before all stored properties are initialized
        elapsedTime = 0
        backgroundColor = Color.white
        let userDefaultsKey = "EmojiArtDocumentViewModel.\(id.uuidString)"
        let emojiArtJson = UserDefaults.standard.data(forKey: userDefaultsKey)
        emojiArtModel = EmojiArtModel(json: emojiArtJson) ?? EmojiArtModel()
        emojiArtModelSink = $emojiArtModel.sink { emojiArtModel in
//            print("JSON: \(emojiArtModel.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArtModel.json, forKey: userDefaultsKey)
        }
        elapsedTime = emojiArtModel.elapsedTime
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
                .map { data, response in
                    UIImage(data: data)
                }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .sink { fetchedImage in
                    self.backgroundImage = fetchedImage
                }
        }
    }

    // MARK: - Elapsed time
    var subscription: AnyCancellable?

    func startTimer() {
        subscription = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.elapsedTime += 1; self.emojiArtModel.elapsedTime = self.elapsedTime
            }
    }

    func cancelTimer() {
        subscription?.cancel()
    }
}

extension EmojiArtModel.Emoji {
    var fontSize: CGFloat {
        CGFloat(size)
    }
    var location: CGPoint {
        CGPoint(x: x, y: y)
    }
}
