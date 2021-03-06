//
//  CNErrorHandlerImpl.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 23.10.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Foundation
import Combine

/// Default implementation of the CNErrorHandler.
/// It is manager for handling CNProvider errors.
///
/// It contains:
/// - **outputHandling method** – to handle the response from the server.
/// - **convert method** – to convert NSError on unsuccessful request  to ErrorType.
///
public struct CNErrorHandlerImpl: CNErrorHandler {
    
    /// A method for processing the response from the server. Receives server response and the retryMethod block.
    /// retryMethod can be used to retry a request after an error has been handled.
    public func outputHandling(
        _ output: NetworingOutput,
        _ retryMethod: @autoclosure @escaping () -> AnyPublisher<Data, CNError>
    ) -> AnyPublisher<Data, CNError> {
            
        guard let httpResponse = output.response as? HTTPURLResponse else {
            return Fail(error: CNError.unspecifiedError)
                .eraseToAnyPublisher()
        }
        
        switch httpResponse.statusCode {
        case 200...399:
            return Just(output.data)
                .setFailureType(to: CNError.self)
                .eraseToAnyPublisher()
            
        case 400...499:
            return Fail(error: CNError.clientError)
                .eraseToAnyPublisher()
            
        case 500...599:
            return Fail(error: CNError.serverError)
                .eraseToAnyPublisher()
            
        default:
            return Fail(error: CNError.unspecifiedError)
                .eraseToAnyPublisher()
        }
    }
    
    /// Method for converting NSError on unsuccessful request  to ErrorType.
    public func convert(error: NSError) -> CNError {
        switch error.code {
        case NSURLErrorBadURL:
            return .badURLError
            
        case NSURLErrorTimedOut:
            return .timedOutError
            
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
            return .hostError
            
        case NSURLErrorHTTPTooManyRedirects:
            return .tooManyRedirectsError
            
        case NSURLErrorResourceUnavailable:
            return .resourceUnavailable
            
        case NSURLErrorNotConnectedToInternet, NSURLErrorCallIsActive,
            NSURLErrorNetworkConnectionLost, NSURLErrorDataNotAllowed:
            return .reachabilityError
            
        default: return .unspecifiedError
        }
    }
}
