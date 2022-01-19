import Foundation
import Combine

class EmojiArtDocumentStore: ObservableObject {
    private static let persistenceKeyPrefix = "EmojiArtDocumentStore"

    let name: String
    @Published private var documentNames = [EmojiArtDocumentViewModel: String]()

    func name(for document: EmojiArtDocumentViewModel) -> String {
        if documentNames[document] == nil {
            documentNames[document] = "Untitled"
        }
        return documentNames[document]!
    }

    func setName(_ name: String, for document: EmojiArtDocumentViewModel) {
        documentNames[document] = name
    }

    var documents: [EmojiArtDocumentViewModel] {
        documentNames.keys.sorted { documentNames[$0]! < documentNames[$1]! }
    }

    @discardableResult func addDocument(named name: String = "Untitled") -> EmojiArtDocumentViewModel {
        let document = EmojiArtDocumentViewModel()
        documentNames[document] = name
        return document
    }

    func removeDocument(_ document: EmojiArtDocumentViewModel) {
        documentNames[document] = nil
    }

    private var autosave: AnyCancellable?

    init(named name: String = "Emoji Art") {
        self.name = name
        let defaultsKey = "\(EmojiArtDocumentStore.persistenceKeyPrefix).\(name)"
        documentNames = Dictionary(fromPropertyList: UserDefaults.standard.object(forKey: defaultsKey))
        autosave = $documentNames.sink { names in
            UserDefaults.standard.set(names.asPropertyList, forKey: defaultsKey)
        }
    }
}

extension Dictionary where Key == EmojiArtDocumentViewModel, Value == String {
    init(fromPropertyList plist: Any?) {
        self.init()
        let uuidToName = plist as? [String:String] ?? [:]
        for uuid in uuidToName.keys {
            self[EmojiArtDocumentViewModel(id: UUID(uuidString: uuid)!)] = uuidToName[uuid]
        }
    }

    var asPropertyList: [String:String] {
        var uuidToName = [String:String]()
        for (key, value) in self {
            uuidToName[key.id.uuidString] = value
        }
        return uuidToName
    }
}
