//
//  URLProtocolStub.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation

final class URLProtocolStub: URLProtocol {
    static var response: Result<Data, NSError>?
    
    override class func canInit(
        with request: URLRequest
    ) -> Bool { true }
    
    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url,
              let result = URLProtocolStub.response else {
            
            self.client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        switch result {
        case .success(let data):
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )
            
            self.client?.urlProtocol(
                self, didReceive: response!,
                cacheStoragePolicy: .notAllowed
            )
            
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
            
        case .failure(let error):
            self.client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
