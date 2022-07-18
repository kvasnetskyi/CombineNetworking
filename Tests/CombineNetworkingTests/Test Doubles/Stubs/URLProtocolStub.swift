//
//  URLProtocolStub.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation

final class URLProtocolStub: URLProtocol {
    static var response: Data = .init()
    static var statusCode: Int = 200
    
    override class func canInit(
        with request: URLRequest
    ) -> Bool { true }
    
    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else {
            self.client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: URLProtocolStub.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        
        self.client?.urlProtocol(
            self, didReceive: response!,
            cacheStoragePolicy: .notAllowed
        )
        
        self.client?.urlProtocol(self, didLoad: URLProtocolStub.response)
        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
