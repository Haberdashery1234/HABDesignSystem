//
//  HABUIKitTests.swift
//  HABUIKitTests
//
//  Created by Christian Grise on 6/29/26.
//
//  Smoke test — verifies the module imports and the shared theme manager
//  initialises without crashing.
//

import XCTest
import HABUIKit

final class HABUIKitSmokeTests: XCTestCase {
    func testModuleImports() {
        // If this file compiles and runs, the module is importable.
        XCTAssertTrue(true)
    }

    func testSharedThemeManagerExists() {
        XCTAssertNotNil(HABThemeManager.shared)
    }

    func testDefaultThemeHasName() {
        XCTAssertFalse(HABThemeManager.shared.theme.name.isEmpty)
    }
}
