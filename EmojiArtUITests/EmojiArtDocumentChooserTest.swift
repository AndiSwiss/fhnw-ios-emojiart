//
//  EmojiArtDocumentChooserTest.swift
//  EmojiArtUITests
//
//  Created by Dario Breitenstein on 23.01.22.
//

import XCTest
@testable import EmojiArt

class EmojiArtDocumentChooserTest: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // Ensure that the App starts with an empty document store
        app.launchArguments += ["-EmojiArtDocumentStore.Emoji Art", "null"]
        
        app.launch()
    }

    func testEditName() throws {
        // Ensure the device is in portrait mode
        XCUIDevice.shared.orientation = .portrait

        let emojiArtNavigationBar = app.navigationBars["Emoji Art"]
        
        if (!emojiArtNavigationBar.exists) {
            // Reveal the navigation drawer on iPad if it's not visible
            app.navigationBars/*@START_MENU_TOKEN@*/.buttons["BackButton"]/*[[".buttons[\"Emoji Art\"]",".buttons[\"BackButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        
        emojiArtNavigationBar.buttons["Edit"].tap()
                
        let untitledTextField = app.tables/*@START_MENU_TOKEN@*/.textFields["Untitled"]/*[[".cells",".buttons.textFields[\"Untitled\"]",".textFields[\"Untitled\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        // Double tap to select all text in field
        untitledTextField.doubleTap()
        app.typeText("Test")
        
        emojiArtNavigationBar.buttons["Done"].tap()
        
        XCTAssertEqual(app.tables.cells["Test"].label, "Test")
    }
}
