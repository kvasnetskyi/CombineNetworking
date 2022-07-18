//
//  XCTestCase+LifeCycle.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation
import XCTest

@testable import CombineNetworking

extension XCTestCase {
    override open func setUp() {
        super.setUp()
        CNLogManager.isLogsTurnedOn = false
    }

    open override func setUpWithError() throws {
        try super.setUpWithError()
        CNLogManager.isLogsTurnedOn = false
    }

    override open func tearDown() {
        CNLogManager.isLogsTurnedOn = true
        super.tearDown()
    }
    
    open override func tearDownWithError() throws {
        CNLogManager.isLogsTurnedOn = true
        try super.tearDownWithError()
    }
}
