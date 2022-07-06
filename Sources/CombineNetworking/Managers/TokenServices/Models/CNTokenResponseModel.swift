//
//  CNTokenResponseModel.swift
//  
//
//  Created by Artem Kvasnetskyi on 06.07.2022.
//

import Foundation

public protocol CNTokenResponseModel {
    var refreshToken: String { get }
    var token: String { get }
}
