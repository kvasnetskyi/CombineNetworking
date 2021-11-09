//
//  CNReachabilityManagerImpl.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 24.09.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Foundation
import Network

/// Default implementation of the CNReachabilityManager.
/// It is manager to check the Internet connection. Used before attempting to send a request.
public class CNReachabilityManagerImpl: CNReachabilityManager {
    // MARK: - Static Properties
    private static let queueLabel = "CNReachabilityManagerQueue"
    
    // MARK: - Public Properties
    public var isInternetConnectionAvailable: Bool = {
        return false
    }()
    
    // MARK: - Private Properties
    private var connectionMonitor = NWPathMonitor()
    
    // MARK: - Init
    public init() {
        let queue = DispatchQueue(
            label: CNReachabilityManagerImpl.queueLabel
        )
        
        self.connectionMonitor.pathUpdateHandler = { pathUpdateHandler in
            self.isInternetConnectionAvailable = pathUpdateHandler.status == .satisfied
        }
        
        self.connectionMonitor.start(queue: queue)
    }
}
