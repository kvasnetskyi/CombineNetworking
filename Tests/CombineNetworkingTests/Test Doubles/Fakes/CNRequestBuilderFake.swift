//
//  CNRequestBuilderFake.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation

@testable import CombineNetworking

class CNRequestBuilderFake: CNRequestBuilder {
    private(set) var path = String()
    private(set) var query: QueryItems?
    private(set) var body: Data?
    private(set) var method: HTTPMethod = .get
    private(set) var baseURL: URL?
    private(set) var headerFields: HTTPHeaderFields?
    private(set) var multipartBody: CNMultipartFormDataModel?
    
    init(baseURL: URL? = nil) {
        self.baseURL = baseURL
    }
}
