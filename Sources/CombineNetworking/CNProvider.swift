//
//  CNProvider.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 24.09.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Combine
import Foundation

/// A class that serves as a provider to run requests to the server.
/// This is an implementation of the CNProviderProtocol.
///
/// Contains associatedtypes:
/// - **RequestBuilder** - type of object subscribed to the **CNRequestBuilder** protocol.
/// Responsible for describing and creating the URLRequest object.
/// - **ErrorHandler** - the object type subscribed to the **CNErrorHandler** protocol.
/// Responsible for handling errors received in CNProvider.
/// If necessary, you can use a ready-made implementation - CNErrorHandlerImpl, or create your own.
///

final public class CNProvider<RequestBuilder: CNRequestBuilder, ErrorHandler: CNErrorHandler>: CNProviderProtocol {
    // MARK: - Public Properties
    /// Base URL where the request will be made.
    public var baseURL: URL
    
    /// Manager to check the Internet connection.
    /// Used before attempting to send a request.
    public var reachability: CNReachabilityManager
    
    /// URLSession with which the request will be executed
    public var session: URLSession
    
    /// Responsible for handling errors received in CNProvider.
    public var errorHandler: ErrorHandler
    
    /// Array with objects for request modification.
    ///
    /// Most often you will use it to customize request headers.
    public var plugins: [CNPlugin]
    
    /// JSONDecoder with which the object will be decoded.
    public var decoder: JSONDecoder
    
    // MARK: - Init
    public init(
        baseURL: URL,
        reachability: CNReachabilityManager = CNReachabilityManagerImpl.shared,
        session: URLSession = .shared,
        requestBuilder: RequestBuilder.Type,
        plugins: [CNPlugin] = [],
        decoder: JSONDecoder = JSONDecoder()
    ) where ErrorHandler == CNErrorHandlerImpl {
        
        self.baseURL = baseURL
        self.reachability = reachability
        self.session = session
        self.errorHandler = CNErrorHandlerImpl()
        self.plugins = plugins
        self.decoder = decoder
    }
    
    public required init(
        baseURL: URL,
        reachability: CNReachabilityManager = CNReachabilityManagerImpl.shared,
        session: URLSession = .shared,
        errorHandler: ErrorHandler,
        requestBuilder: RequestBuilder.Type,
        plugins: [CNPlugin] = [],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        
        self.baseURL = baseURL
        self.reachability = reachability
        self.session = session
        self.errorHandler = errorHandler
        self.plugins = plugins
        self.decoder = decoder
    }
}

// MARK: - Public Methods
extension CNProvider {
    /// A method that starts a request task and decodes the response into an object, relying on a generic parameter.
    /// Returns the publisher with the decoded object, or ErrorHandler.ErrorType.
    public func perform<T: Decodable>(
        _ builder: RequestBuilder
    ) -> AnyPublisher<T, ErrorHandler.ErrorType> {
            
            generalPerform(builder)
                .decode(
                    type: T.self,
                    decoder: decoder
                )
                .mapError { error -> ErrorHandler.ErrorType in
                    guard let _ = error as? DecodingError else {
                        guard let error = error as? ErrorHandler.ErrorType else {
                            return .unspecifiedError
                        }
                        
                        return error
                    }
                    
                    return ErrorHandler.ErrorType.decodingError
                }
                .eraseToAnyPublisher()
    }
    
    /// A method that starts a request task and decodes the response into an object, relying on a decodableType parameter.
    /// Returns the publisher with the generic abstraction object – protocol of the decoded object, or ErrorHandler.ErrorType.
    public func perform<DecodableType: Decodable, Abstraction>(
        _ builder: RequestBuilder,
        decodableType: DecodableType.Type
    ) -> AnyPublisher<Abstraction, ErrorHandler.ErrorType> {
        (perform(builder) as AnyPublisher<DecodableType, ErrorHandler.ErrorType>)
            .compactMap { $0 as? Abstraction }
            .eraseToAnyPublisher()
    }
    
    /// A method that starts a request task. Returns the publisher, which can be completed successfully or with ErrorHandler.ErrorType.
    public func perform(_ builder: RequestBuilder) -> AnyPublisher<Never, ErrorHandler.ErrorType> {
        generalPerform(builder)
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
    
    /// A method that starts a request task.
    /// Returns the publisher with the Data, or ErrorHandler.ErrorType.
    public func generalPerform(_ builder: RequestBuilder) -> AnyPublisher<Data, ErrorHandler.ErrorType> {
            guard reachability.isInternetConnectionAvailable else {
                return Fail(error: ErrorHandler.ErrorType.reachabilityError)
                    .eraseToAnyPublisher()
            }
            
            let request = builder.makeRequest(baseURL: baseURL, plugins: plugins)
            
            return session.dataTaskPublisher(for: request)
                .mapError { [weak self] error -> ErrorHandler.ErrorType in
                    guard let self = self else {
                        return .unspecifiedError
                    }
                    
                    return self.errorHandler.convert(error: error as NSError)
                }
                .flatMap { [weak self] output -> AnyPublisher<Data, ErrorHandler.ErrorType> in
                    guard let self = self else {
                        return Fail(error: .unspecifiedError)
                            .eraseToAnyPublisher()
                    }
                    
                    CNLogManager.log(output)
                    
                    return self.errorHandler.outputHandling(
                        output,
                        self.generalPerform(builder)
                    )
                }
                .eraseToAnyPublisher()
    }
}
