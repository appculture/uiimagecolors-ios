//
//  GlobusUITests.swift
//  GlobusUITests
//
//  Created by Marko Tadic on 6/3/16.
//
//

import XCTest

class GlobusUITests: XCTestCase {
        
    // MARK: - Setup / Tear Down
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Screenshots
    
    func testTakeScreenshots() {
        snapshot("0-CustomerCard")
    }
    
}
