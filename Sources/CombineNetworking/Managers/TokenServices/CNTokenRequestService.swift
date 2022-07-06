//
//  CNTokenRequestService.swift
//  
//
//  Created by Artem Kvasnetskyi on 05.07.2022.
//

import Combine

public protocol CNTokenRequestService {
    associatedtype RefreshTokenModel
    associatedtype Output
    associatedtype ErrorType: CNErrorProtocol
    
    func refreshToken(_ model: RefreshTokenModel) -> AnyPublisher<Output, ErrorType>
}
