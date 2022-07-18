//
//  CNPluginFake.swift
//  
//
//  Created by Artem Kvasnetskyi on 17.07.2022.
//

import Foundation

@testable import CombineNetworking

struct CNPluginFake: CNPlugin {
    let url: URL?
    let body: Data?
    let method: String
    let headerFields: [String: String]
    
    func modifyRequest(_ request: inout URLRequest) {
        request.url = url
        request.httpBody = body
        request.httpMethod = method
        
        headerFields.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
    }
}
