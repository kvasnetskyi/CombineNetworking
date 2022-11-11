//
//  CNReachabilityManagerImpl.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 24.09.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Foundation
import Network

/// Default implementation of the CNReachabilityManager.
///
/// It is manager to check the Internet connection. Used before attempting to send a request.
/// It is a singleton, which you can get by property shared.
///
/// **For WatchOS, this manager always returns true.**
public class CNReachabilityManagerImpl: CNReachabilityManager {
    // MARK: - Static Properties
    private static let queueLabel = "CNReachabilityManagerQueue"
    
    // MARK: - Public Properties
    public var isInternetConnectionAvailable = false
    
    // MARK: - Private Properties
    private var connectionMonitor = NWPathMonitor()
    
    // MARK: - Singleton Init
    public static let shared = CNReachabilityManagerImpl()
    
    private init() {
        #if os(watchOS)
            isInternetConnectionAvailable = true
        
        #else
            let queue = DispatchQueue(
                label: CNReachabilityManagerImpl.queueLabel
            )
            
            self.connectionMonitor.pathUpdateHandler = { pathUpdateHandler in
                self.isInternetConnectionAvailable = pathUpdateHandler.status == .satisfied
            }
            
            self.connectionMonitor.start(queue: queue)
            
        #endif
    }
}
