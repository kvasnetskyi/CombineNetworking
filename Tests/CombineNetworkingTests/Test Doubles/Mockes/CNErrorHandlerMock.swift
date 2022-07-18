//
//  CNErrorHandlerMock.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation
import Combine

@testable import CombineNetworking

final class CNErrorHandlerMock: CNErrorHandler {
    // MARK: - Internal Properties
    private(set) var countOfOutputHandlingMethodsCalled: Int = .zero
    private(set) var countOfConvertMethodsCalled: Int = .zero
    
    // MARK: - Private Properties
    private var numberOfCyclesThatRetryMethodMustBeCalled: Int
    private var handlingMethodError: CNError?
    private var convertMethodError: CNError
    
    init(
        numberOfCyclesThatRetryMethodMustBeCalled: Int,
        returnAnErrorWhenHandling handlingMethodError: CNError?,
        returnAnErrorWhenConverting convertMethodError: CNError
    ) {
        self.numberOfCyclesThatRetryMethodMustBeCalled = numberOfCyclesThatRetryMethodMustBeCalled
        self.handlingMethodError = handlingMethodError
        self.convertMethodError = convertMethodError
    }
    
    func outputHandling(
        _ output: NetworingOutput,
        _ retryMethod: @autoclosure @escaping () -> AnyPublisher<Data, CNError>
    ) -> AnyPublisher<Data, CNError> {
        countOfOutputHandlingMethodsCalled += 1
        
        guard numberOfCyclesThatRetryMethodMustBeCalled == .zero else {
            numberOfCyclesThatRetryMethodMustBeCalled -= 1
            return retryMethod()
        }
        
        guard let error = handlingMethodError else {
            return Just(output.data)
                .setFailureType(to: CNError.self)
                .eraseToAnyPublisher()
        }
        
        return Fail(error: error)
            .eraseToAnyPublisher()
    }
    
    func convert(error: NSError) -> CNError {
        countOfConvertMethodsCalled += 1
        
        return convertMethodError
    }
}
