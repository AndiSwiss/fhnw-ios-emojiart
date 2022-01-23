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


    // MARK: - Computed Properties
    var backgroundURL: URL? {
        get {
            emojiArtModel.backgroundURL
        }
        set {
            emojiArtModel.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }

    var backgroundColor: UIColor {
        get {
            // Conversion from ColorRGBA to UIColor via constructor
            UIColor(
                    red: CGFloat(emojiArtModel.backgroundColor.r),
                    green: CGFloat(emojiArtModel.backgroundColor.g),
                    blue: CGFloat(emojiArtModel.backgroundColor.b),
                    alpha: CGFloat(emojiArtModel.backgroundColor.a))
        }
        set {
            // Conversion from UIColor to ColorRGBA via extension
            emojiArtModel.backgroundColor = newValue.asColorRGBA
        }
    }

    var opacity: Double {
        get {
            emojiArtModel.backgroundColor.a
        }
        set {
            emojiArtModel.backgroundColor.a = newValue
        }
    }

    // MARK: - Init
    init(id: UUID = UUID()) {
        self.id = id
        // We need to temporarily initialize 'elapsedTime', because if we try to do it after getting the
        // emojiArtModel, there will be the following error:
        //      self' used in property access '$emojiArtModel' before all stored properties are initialized
        elapsedTime = 0
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
        if (!emoji.isEmpty) {
            emojiArtModel.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
        }
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
