//
//  TestDoublesFactory.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation

@testable import CombineNetworking

struct TestDoublesFactory {
    // MARK: - Stubs
    struct Stub {
        static func getURLSession(response: Data, statusCode: Int) -> URLSession {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [URLProtocolStub.self]
            URLProtocolStub.response = response
            URLProtocolStub.statusCode = statusCode
            
            return URLSession(configuration: config)
        }
        
        static func getReachabilityManager(
            isInternetConnectionAvailable: Bool
        ) -> CNReachabilityManager {
            CNReachabilityManagerStub(
                isInternetConnectionAvailable: isInternetConnectionAvailable
            )
        }
    }
    
    // MARK: - Mockes
    struct Mock {
        static func getCNErrorHandler(
            numberOfCyclesThatRetryMethodMustBeCalled numberOfCycles: Int = .zero,
            returnAnErrorWhenHandling handlingMethodError: CNError? = nil,
            returnAnErrorWhenConverting convertMethodError: CNError = .unspecifiedError
        ) -> CNErrorHandlerMock {
            .init(
                numberOfCyclesThatRetryMethodMustBeCalled: numberOfCycles,
                returnAnErrorWhenHandling: handlingMethodError,
                returnAnErrorWhenConverting: convertMethodError
            )
        }
        
        static func getCNRequestBuilder() -> CNRequestBuilderMock {
            .init(
                urlForRequest: URL(
                    string: "https://CNRequestBuilderMock.test/testURL"
                )!
            )
        }
        
        static func getJSONDecoder(isErrorResult: Bool = false) -> JSONDecoderMock {
            .init(isErrorResult: isErrorResult)
        }
    }
    
    // MARK: - Fakes
    struct Fake {
        static func getPugin() -> CNPluginFake {
            let url: URL? = URL(string: "https://CNPluginTestModel.test/testURL")
            let body: Data? = "CNPluginTestModel".data(using: .utf8)
            let method: String = HTTPMethod.options.rawValue
            let headerFields: [String: String] = ["CNPluginTestModel": "Test"]
            
            return CNPluginFake(
                url: url, body: body,
                method: method,
                headerFields: headerFields
            )
        }
    }
}
