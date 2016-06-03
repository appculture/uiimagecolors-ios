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
        let key1 = localizedString("Profile.TitleText")
        tablesQuery.staticTexts[key1].tap()
        sleep(1)
        snapshot("1-AccountSettings", waitForLoadingIndicator: false)
        
        /// vouchers
        let key2 = localizedString("TabBarItem1")
        tabBarsQuery.buttons[key2].tap()
        sleep(2)
        tablesQuery.cells.elementBoundByIndex(0).tap()
        sleep(1)
        snapshot("2-Voucher", waitForLoadingIndicator: false)
        
        /// branches
        let key3 = localizedString("TabBarItem2")
        tabBarsQuery.buttons[key3].tap()
        sleep(1)
        tablesQuery.cells.staticTexts["GLOBUS Westside"].tap()
        sleep(1)
        snapshot("3-Branch", waitForLoadingIndicator: false)
    }
    
    /// SEE: https://github.com/fastlane-old/snapshot/issues/321#issuecomment-159660882
    func localizedString(key:String) -> String {
        let localizationBundle = NSBundle(forClass: GlobusUITests.self)
        let language = deviceLanguage.componentsSeparatedByString("-").first!
        let languagePath = localizationBundle.pathForResource(language, ofType: "lproj")!
        let bundle = NSBundle(path: languagePath)!
        let result = NSLocalizedString(key, bundle: bundle, comment: "")
        return result
    }
    
}
