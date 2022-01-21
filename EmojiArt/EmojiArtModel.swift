import Foundation

struct EmojiArtModel: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    var elapsedTime: Int
    var backgroundColor: ColorRGBA


    init() {
        elapsedTime = 0
        backgroundColor = ColorRGBA.white()
    }

    init?(json: Data?) {
        if let json = json, let newEmojiArt = try? JSONDecoder().decode(EmojiArtModel.self, from: json) {
            self = newEmojiArt // structs can be assigned in their init
        } else {
            return nil
        }
    }
    
    struct Emoji: Identifiable, Codable {
        let text: String
        var x: Int //offset from center
        var y: Int //offset from center
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int){
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }

    var json: Data? {
        try? JSONEncoder().encode(self)
    }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }



    // Since we use UIColor in this model for the background-color (from SwiftUI),
    // an additional init was required.
    // Otherwise, the following error occurs:
    // 'Type 'EmojiArtModel' does not conform to protocol 'Decodable'
    //
    // TODO: However, the document is not anymore saved and we would have provide custom encoders and decoders, see
    //  for example guide on https://www.raywenderlich.com/3418439-encoding-and-decoding-in-swift
    //  ---
    //  Solution: Work with a custom color-class which is codable instead and revert to Foundation instead of SwiftUI
    //  => We created the following:    struct ColorRGBA: Codable
//    init(from decoder: Decoder) throws {
//        elapsedTime = 0
//        backgroundColor = Color.white
//    }
//
//    // Needed, because otherwise, the following error occurs:
//    // Type 'EmojiArtModel' does not conform to protocol 'Encodable'
//    func encode(to encoder: Encoder) throws {
//    }
}
