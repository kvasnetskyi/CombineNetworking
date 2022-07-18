//
//  CNRequestBuilder+MakeRequest.swift
//  
//
//  Created by Artem Kvasnetskyi on 16.07.2022.
//

import Foundation
import XCTest

@testable import CombineNetworking

extension CNRequestBuilder {
    func makeRequest(
        baseURL: URL? = nil,
        plugins: [CNPlugin] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> URLRequest {
        let optionalBaseURL = baseURL ?? self.baseURL
        
        let baseURL = try XCTUnwrap(
            optionalBaseURL,
            "Base URL need to be passed to CNRequestBuilder sut",
            file: file,
            line: line
        )
        
        return makeRequest(baseURL: baseURL, plugins: plugins)
    }
}
