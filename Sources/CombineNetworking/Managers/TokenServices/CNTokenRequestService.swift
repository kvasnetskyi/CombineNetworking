//
//  CNTokenRequestService.swift
//  
//
//  Created by Artem Kvasnetskyi on 05.07.2022.
//

import Combine

public protocol CNTokenRequestService {
    associatedtype ErrorType: Error
    
    func requestToken(_ model: CNTokenRequestModel) -> AnyPublisher<CNTokenResponseModel, ErrorType>
}
