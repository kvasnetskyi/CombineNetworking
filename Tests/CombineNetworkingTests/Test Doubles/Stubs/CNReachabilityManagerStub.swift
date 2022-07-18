//
//  CNReachabilityManagerStub.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation

@testable import CombineNetworking

final class CNReachabilityManagerStub: CNReachabilityManager {
    var isInternetConnectionAvailable: Bool
    
    init(isInternetConnectionAvailable: Bool) {
        self.isInternetConnectionAvailable = isInternetConnectionAvailable
    }
}
