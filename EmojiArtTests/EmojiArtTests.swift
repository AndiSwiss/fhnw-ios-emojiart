//
//  EmojiArtTests.swift
//  EmojiArtTests
//
//  Created by Oliver Gepp on 28.10.21.
//

import XCTest
@testable import EmojiArt

class EmojiArtTests: XCTestCase {
    var document: EmojiArtDocumentViewModel!
    
    override func setUpWithError() throws {
        document = EmojiArtDocumentViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddEmoji_whenTextIsEmpty_doesNothing() throws {
        XCTAssertEqual(document.emojis.count, 0)
        document.addEmoji("", at: CGPoint.zero, size: 40)
        XCTAssertEqual(document.emojis.count, 0)
    }
}
