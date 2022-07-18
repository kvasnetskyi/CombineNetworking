//
//  CNRequestBuilderBuilder.swift
//  
//
//  Created by Artem Kvasnetskyi on 16.07.2022.
//

import Foundation
import XCTest

@testable import CombineNetworking

final class CNRequestBuilderBuilder {
    // MARK: - Properties
    private(set) var path: String = "/test/path"
    private(set) var query: QueryItems?
    private(set) var body: Data?
    private(set) var method: HTTPMethod = .post
    private(set) var baseURL: URL?
    private(set) var headerFields: HTTPHeaderFields?
    private(set) var multipartBody: CNMultipartFormDataModel?
}

// MARK: - Methods
extension CNRequestBuilderBuilder {
    func with(path: String) -> Self {
        self.path = path
        
        return self
    }
    
    func with(query: QueryItems) -> Self {
        self.query = query
        
        return self
    }
    
    func with(body: Data) -> Self {
        self.body = body
        
        return self
    }
    
    func with(method: HTTPMethod) -> Self {
        self.method = method
        
        return self
    }
    
    func with(baseURL: URL) -> Self {
        self.baseURL = baseURL
        
        return self
    }
    
    func with(headerFields: HTTPHeaderFields) -> Self {
        self.headerFields = headerFields
        
        return self
    }
    
    func with(multipartBody: CNMultipartFormDataModel) -> Self {
        self.multipartBody = multipartBody
        
        return self
    }
}

// MARK: -
extension CNRequestBuilderBuilder {
    func makeQuery() -> Self {
        with(query: ["testQueryKey": "testQueryValue"])
    }
    
    func makeHeaderFields() -> Self {
        with(headerFields: ["testHeaderFieldKey": "testHeaderFieldValue"])
    }
    
    func makeBaseURL() -> Self {
        with(baseURL: .init(string: "https://testURL.test")!)
    }
    
    func makeMultipartBody() -> Self {
        let item = CNMultipartFormItem(
            name: "Test field name",
            fileName: "Test file name",
            mimeType: "Test mime type",
            data: "Test Data".data(using: .utf8)!
        )
        
        return with(
            multipartBody: CNMultipartFormDataModel(items: [item])
        )
    }
}

// MARK: -
extension CNRequestBuilderBuilder {
    func build() -> CNRequestBuilder {
        CNRequestBuilderTestObject(
            path: path,
            query: query,
            body: body,
            method: method,
            baseURL: baseURL,
            headerFields: headerFields,
            multipartBody: multipartBody
        )
    }
}

// MARK: - Model
private extension CNRequestBuilderBuilder {
    struct CNRequestBuilderTestObject: CNRequestBuilder {
        var path: String
        var query: QueryItems?
        var body: Data?
        var method: HTTPMethod
        var baseURL: URL?
        var headerFields: HTTPHeaderFields?
        var multipartBody: CNMultipartFormDataModel?
    }
}
