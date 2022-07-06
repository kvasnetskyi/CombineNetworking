//
//  CNAuthOutputHandlerAdapter.swift
//  
//
//  Created by Artem Kvasnetskyi on 05.07.2022.
//

import Foundation
import Combine

public struct CNAuthOutputHandlerAdapter<Handler: CNAuthOutputHandler> {
    // MARK: - Private Properties
    private var handler: Handler
    
    // MARK: - Init
    init(_ handler: Handler) {
        self.handler = handler
    }
}

// MARK: - CNOutputHandler
extension CNAuthOutputHandlerAdapter: CNOutputHandler {
    public func outputHandling(
        _ output: NetworingOutput,
        _ retryMethod: @autoclosure @escaping () -> AnyPublisher<Data, Handler.ErrorType>
    ) -> AnyPublisher<Data, Handler.ErrorType> {
        guard let httpResponse = output.response as? HTTPURLResponse,
              httpResponse.statusCode == 401 else {
                  return handler.handleNonUnauthorizedResponse(
                    output, retryMethod()
                  )
              }
        
        return handler.tokenResponseService.getRefreshTokenModel()
            .flatMap { model -> AnyPublisher<Handler.TokenResponseService.Input, ErrorType> in
                handler.tokenRequestService.refreshToken(model)
            }
            .flatMap { tokenModel -> AnyPublisher<Void, ErrorType> in
                handler.tokenResponseService.handle(tokenModel)
            }
            .flatMap {
                retryMethod()
            }
            .eraseToAnyPublisher()
    }
}
