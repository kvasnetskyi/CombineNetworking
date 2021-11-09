//
//  CNReachabilityManager.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 24.09.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Foundation

/// Manager to check the Internet connection. Used before attempting to send a request.
///
/// You can use default implementation of the CNReachabilityManager – **CNReachabilityManagerImpl.**
public protocol CNReachabilityManager: AnyObject {
    var isInternetConnectionAvailable: Bool { get }
}
