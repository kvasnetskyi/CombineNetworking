//
//  CNTokenResponseService.swift
//  
//
//  Created by Artem Kvasnetskyi on 05.07.2022.
//

import Combine

public protocol CNTokenResponseService {
    associatedtype RefreshTokenModel
    associatedtype Input
    associatedtype ErrorType: CNErrorProtocol
    
    func getRefreshTokenModel() -> AnyPublisher<RefreshTokenModel, ErrorType>
    func handle(_ response: Input) -> AnyPublisher<Void, ErrorType>
}
