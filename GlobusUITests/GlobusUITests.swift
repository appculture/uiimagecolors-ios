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
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let tabBarsQuery = app.tabBars
        
        /// globus card
        sleep(1)
        snapshot("0-CustomerCard", waitForLoadingIndicator: false)
        
        /// account
        tablesQuery.staticTexts["My account"].tap()
        sleep(1)
        snapshot("1-AccountSettings", waitForLoadingIndicator: false)
        
        /// vouchers
        tabBarsQuery.buttons["Vouchers"].tap()
        sleep(2)
        tablesQuery.cells.containingType(.StaticText, identifier:"20% Rabatt auf alle JOHN FRIEDA Produkte").staticTexts["13.06.2016"].tap()
        sleep(1)
        snapshot("2-Voucher", waitForLoadingIndicator: false)
        
        /// branches
        tabBarsQuery.buttons["Branches"].tap()
        sleep(1)
        tablesQuery.cells.staticTexts["GLOBUS Westside"].tap()
        sleep(1)
        snapshot("3-Branch", waitForLoadingIndicator: false)
    }
    
}
