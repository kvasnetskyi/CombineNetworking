//
//  CNPlugin.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 09.11.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Foundation

/// Object protocol for request modification.
///
/// Most often you will use it to customize request headers.
/// An array of such objects is passed to CNProvider, and taken into account when creating a request in CNRequestBuilder.
public protocol CNPlugin {
    func modifyRequest(_ request: inout URLRequest)
}
