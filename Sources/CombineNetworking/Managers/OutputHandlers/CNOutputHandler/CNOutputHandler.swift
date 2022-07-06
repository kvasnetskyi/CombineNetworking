//
//  CNOutputHandler.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 23.10.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Combine
import Foundation

// MARK: - Typealias
public typealias NetworingOutput = (data: Data, response: URLResponse)

/// Manager for handling CNProvider errors.
///
/// It contains:
/// - **ErrorType associatedtype** – the type of error the manager will work with.
/// You can use your own error type, but it must be subscribed to CNErrorProtocol.
/// - **outputHandling method** – to handle the response from the server.
/// - **convert method** – to convert NSError on unsuccessful request  to ErrorType.
///
/// You can use the default implementation of the CNOutputHandler – **CNOutputHandlerImpl**
///
public protocol CNOutputHandler {
    /// The type of error the manager will work with.
    /// You can use your own error type, but it must be subscribed to CNErrorProtocol.
    associatedtype ErrorType: CNErrorProtocol
    
    /// A method for processing the response from the server. Receives server response and the retryMethod block.
    /// retryMethod can be used to retry a request after an error has been handled.
    func outputHandling(
        _ output: NetworingOutput,
        _ retryMethod: @autoclosure @escaping () -> AnyPublisher<Data, ErrorType>
    ) -> AnyPublisher<Data, ErrorType>
}
