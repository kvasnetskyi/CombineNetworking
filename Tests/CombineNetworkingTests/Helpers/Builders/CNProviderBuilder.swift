//
//  CNProviderBuilder.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation

@testable import CombineNetworking

final class CNProviderBuilder {
    // MARK: - Properties
    private(set) var baseURL: URL = URL(string: "https://CNProviderBuilder.baseURL")!
    private(set) var errorHandler: CNErrorHandlerMock = TestDoublesFactory.Mock.getCNErrorHandler()
    private(set) var plugins: [CNPlugin] = []
    private(set) var decoder: JSONDecoder = .init()
    private(set) var session: URLSession = TestDoublesFactory.Stub.getURLSession(
        response: .init(), statusCode: 200
    )
    
    private(set) var reachability: CNReachabilityManager = TestDoublesFactory.Stub.getReachabilityManager(
        isInternetConnectionAvailable: true
    )
}

// MARK: - Methods
extension CNProviderBuilder {
    func with(baseURL: URL) -> Self {
        self.baseURL = baseURL
        
        return self
    }
    
    func with(errorHandler: CNErrorHandlerMock) -> Self {
        self.errorHandler = errorHandler
        
        return self
    }
    
    func with(plugins: [CNPlugin]) -> Self {
        self.plugins = plugins
        
        return self
    }
    
    func with(decoder: JSONDecoder) -> Self {
        self.decoder = decoder
        
        return self
    }
    
    func with(session: URLSession) -> Self {
        self.session = session
        
        return self
    }
    
    func with(reachability: CNReachabilityManager) -> Self {
        self.reachability = reachability
        
        return self
    }
}

// MARK: -
extension CNProviderBuilder {
    func makeInternetConnectionUnavailable() -> Self {
        reachability = TestDoublesFactory.Stub.getReachabilityManager(
            isInternetConnectionAvailable: false
        )
        
        return self
    }
}

// MARK: -
extension CNProviderBuilder {
    func build() -> CNProvider<CNRequestBuilderMock, CNErrorHandlerMock> {
        .init(
            baseURL: baseURL,
            reachability: reachability,
            session: session,
            errorHandler: errorHandler,
            requestBuilder: CNRequestBuilderMock.self,
            plugins: plugins,
            decoder: decoder
        )
    }
}
