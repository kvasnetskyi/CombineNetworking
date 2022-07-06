//
//  CNErrorConverterImpl.swift
//  
//
//  Created by Artem Kvasnetskyi on 05.07.2022.
//

import Foundation

struct CNErrorConverterImpl: CNErrorConverter {
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
