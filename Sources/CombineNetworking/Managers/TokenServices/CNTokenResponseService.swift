//
//  CNTokenResponseService.swift
//  
//
//  Created by Artem Kvasnetskyi on 05.07.2022.
//

import Combine

public protocol CNTokenResponseService {
    associatedtype ErrorType: Error
    
    func getTokenRequestModel() -> AnyPublisher<CNTokenRequestModel, ErrorType>
    func handle(token model: CNTokenResponseModel) -> AnyPublisher<Void, ErrorType>
}
