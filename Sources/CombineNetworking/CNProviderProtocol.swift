//
//  CNProviderProtocol.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 24.09.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Foundation
import Combine

/// Protocol for CNProvider class.
///
/// Contains associatedtypes:
/// - **RequestBuilder** - type of object subscribed to the **CNRequestBuilder** protocol.
/// Responsible for describing and creating the URLRequest object.
/// - **ErrorHandler** - the object type subscribed to the **CNErrorHandler** protocol.
/// Responsible for handling errors received in CNProvider.
/// If necessary, you can use a ready-made implementation - CNErrorHandlerImpl, or create your own.
///
public protocol CNProviderProtocol {
    /// Type of object subscribed to the **CNRequestBuilder** protocol.
    /// Responsible for describing and creating the URLRequest object.
    associatedtype RequestBuilder: CNRequestBuilder
    
    /// The object type subscribed to the **CNErrorHandler** protocol.
    /// Responsible for handling errors received in CNProvider.
    /// If necessary, you can use a ready-made implementation - CNErrorHandlerImpl, or create your own.
    associatedtype ErrorHandler: CNErrorHandler
    
    /// Base URL where the request will be made.
    var baseURL: URL { get }
    
    /// Manager to check the Internet connection.
    /// Used before attempting to send a request.
    var reachability: CNReachabilityManager { get }
    
    /// URLSession with which the request will be executed
    var session: URLSession { get }
    
    /// Responsible for handling errors received in CNProvider.
    var errorHandler: ErrorHandler { get }
    
    /// Array with objects for request modification.
    ///
    /// Most often you will use it to customize request headers.
    var plugins: [CNPlugin] { get }
    
    /// JSONDecoder with which the object will be decoded.
    var decoder: JSONDecoder { get }
    
    /// A method that starts a request task.
    /// Returns the publisher with the Data, or ErrorHandler.ErrorType.
    func generalPerform(
        _ builder: RequestBuilder
    ) -> AnyPublisher<Data, ErrorHandler.ErrorType>
    
    /// A method that starts a request task and decodes the response into an object, relying on a generic parameter.
    /// Returns the publisher with the decoded object, or ErrorHandler.ErrorType.
    func perform<T: Decodable>(
        _ builder: RequestBuilder
    ) -> AnyPublisher<T, ErrorHandler.ErrorType>
    
    /// A method that starts a request task and decodes the response into an object, relying on a decodableType parameter.
    /// Returns the publisher with the generic abstraction object – protocol of the decoded object, or ErrorHandler.ErrorType.
    func perform<DecodableType: Decodable, Abstraction>(
        _ builder: RequestBuilder,
        decodableType: DecodableType.Type
    ) -> AnyPublisher<Abstraction, ErrorHandler.ErrorType>
    
    /// A method that starts a request task. Returns the publisher, which can be completed successfully or with ErrorHandler.ErrorType.
    func perform(
        _ builder: RequestBuilder
    ) -> AnyPublisher<Never, ErrorHandler.ErrorType>
}
