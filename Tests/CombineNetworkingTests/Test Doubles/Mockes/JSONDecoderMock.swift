//
//  JSONDecoderMock.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation
import CombineNetworking

class JSONDecoderMock: JSONDecoder {
    private let isErrorResult: Bool
    private(set) var decodeMethodHasBeenCalled: Bool = false
    
    init(isErrorResult: Bool) {
        self.isErrorResult = isErrorResult
    }
    
    override func decode<T>(
        _ type: T.Type, from data: Data
    ) throws -> T where T : Decodable {
        decodeMethodHasBeenCalled = true
        
        guard !isErrorResult else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: .init(),
                    underlyingError: nil
                )
            )
        }
        
        return try super.decode(type, from: data)
    }
}
