//
//  XCTestCase+Data.swift
//  
//
//  Created by Artem Kvasnetskyi on 16.07.2022.
//

import Foundation
import XCTest

extension XCTestCase {
    func getDataForTest(
        _ method: StaticString = #function
    ) -> Data {
        method.description.data(using: .utf8)!
    }
}
