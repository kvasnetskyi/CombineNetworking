//
//  CNAuthOutputHandler.swift
//  
//
//  Created by Artem Kvasnetskyi on 05.07.2022.
//

import Foundation
import Combine

public protocol CNAuthOutputHandler {
    /// The type of error the manager will work with.
    /// You can use your own error type, but it must be subscribed to CNErrorProtocol.
    associatedtype ErrorType: CNErrorProtocol
    
    associatedtype TokenRequestService: CNTokenRequestService
    where TokenRequestService.ErrorType == ErrorType
    
    associatedtype TokenResponseService: CNTokenResponseService
    where TokenResponseService.Input == TokenRequestService.Output,
          TokenResponseService.ErrorType == ErrorType,
          TokenResponseService.RefreshTokenModel == TokenRequestService.RefreshTokenModel
    
    var tokenRequestService: TokenRequestService { get }
    var tokenResponseService: TokenResponseService { get }
    
    func handleNonUnauthorizedResponse(
        _ output: NetworingOutput,
        _ retryMethod: @autoclosure @escaping () -> AnyPublisher<Data, ErrorType>
    ) -> AnyPublisher<Data, ErrorType>
}
