//
//  CNErrorProtocol.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 26.10.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Foundation

/// The protocol to which any custom error type that can communicate with the CNProvider must be subscribed.
///
/// Includes mandatory errors such as:
/// - **reachabilityError** – related to the reachability of the network.
/// - **decodingError** – related to data decoding to the object.
/// - **unspecifiedError** – associated with cases that are not part of the processed cases.
///
/// You can use the default implementation of this protocol - CNError
///
public protocol CNErrorProtocol: Error {
    static var reachabilityError: Self { get }
    static var decodingError: Self { get }
    static var unspecifiedError: Self { get }
}
