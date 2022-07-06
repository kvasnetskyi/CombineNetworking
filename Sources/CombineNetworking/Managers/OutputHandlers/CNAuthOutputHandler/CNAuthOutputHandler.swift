//
//  CNAuthOutputHandler.swift
//  
//
//  Created by Artem Kvasnetskyi on 05.07.2022.
//

import Foundation
import Combine

public protocol CNAuthOutputHandler: CNOutputHandler {
    associatedtype TokenRequestService: CNTokenRequestService
    where TokenRequestService.ErrorType == ErrorType
    
    associatedtype TokenResponseService: CNTokenResponseService
    where TokenResponseService.ErrorType == ErrorType
    
    var tokenRequestService: TokenRequestService? { get }
    var tokenResponseService: TokenResponseService? { get }
    
    func handleNonUnauthorizedResponse(
        _ output: NetworingOutput,
        _ retryMethod: @autoclosure @escaping () -> AnyPublisher<Data, ErrorType>
    ) -> AnyPublisher<Data, ErrorType>
}

// MARK: - CNAuthOutputHandler
public extension CNAuthOutputHandler {
    func outputHandling(
        _ output: NetworingOutput,
        _ retryMethod: @autoclosure @escaping () -> AnyPublisher<Data, ErrorType>
    ) -> AnyPublisher<Data, ErrorType> {
        guard let tokenResponseService = tokenResponseService,
              let tokenRequestService = tokenRequestService,
              let httpResponse = output.response as? HTTPURLResponse,
              httpResponse.statusCode == 401 else {
                  return handleNonUnauthorizedResponse(
                    output, retryMethod()
                  )
              }
        
        return tokenResponseService.getTokenRequestModel()
            .flatMap { model -> AnyPublisher<CNTokenResponseModel, ErrorType> in
                tokenRequestService.requestToken(model)
            }
            .flatMap { model -> AnyPublisher<Void, ErrorType> in
                tokenResponseService.handle(token: model)
            }
            .flatMap {
                retryMethod()
            }
            .eraseToAnyPublisher()
    }
}
