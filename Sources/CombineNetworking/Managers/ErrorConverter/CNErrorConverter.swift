//
//  CNErrorConverter.swift
//  
//
//  Created by Artem Kvasnetskyi on 05.07.2022.
//

import Foundation

public protocol CNErrorConverter {
    /// The type of error the manager will work with.
    /// You can use your own error type, but it must be subscribed to CNErrorProtocol.
    associatedtype ErrorType: CNErrorProtocol
    
    /// Method for converting NSError on unsuccessful request  to ErrorType.
    func convert(error: NSError) -> ErrorType
}
