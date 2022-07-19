//
//  CNFatalError.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 23.10.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Foundation

enum CNFatalError: Error {
    case pathIncorrect(_ path: String)
    case pathOrQueryIncorrect(_ path: String, _ query: QueryItems)
    case custom(_ description: String)
    
    var description: String {
        switch self {
        case .pathIncorrect(let path):
            return "Path is incorrect: \(path)"
            
        case .pathOrQueryIncorrect(let path, let query):
            return "URL with path: \(path) and query items:\n\(query)\nis incorrect"
            
        case .custom(let description):
            return description
        }
    }
}
