//
//  CNRequestBuilderMock.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation

@testable import CombineNetworking

class CNRequestBuilderMock: CNRequestBuilder {
    // MARK: - Internal Properties
    private(set) var makeRequestMethodHasBeenCalled: Bool = false
    
    private(set) var path = String()
    private(set) var query: QueryItems?
    private(set) var body: Data?
    private(set) var method: HTTPMethod = .get
    private(set) var baseURL: URL?
    private(set) var headerFields: HTTPHeaderFields?
    private(set) var multipartBody: CNMultipartFormDataModel?
    
    // MARK: - Private Properties
    private let url: URL
    
    // MARK: - Init
    init(urlForRequest url: URL) {
        self.url = url
    }
    
    // MARK: - Methods
    func makeRequest(baseURL: URL, plugins: [CNPlugin]) -> URLRequest {
        makeRequestMethodHasBeenCalled = true
        
        return URLRequest(url: url)
    }
}
