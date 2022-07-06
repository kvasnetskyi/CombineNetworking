//
//  CNTokenRequestModel.swift
//  
//
//  Created by Artem Kvasnetskyi on 06.07.2022.
//

import Foundation

public protocol CNTokenRequestModel {
    var refreshToken: String { get }
}
