//
//  NetworkInterceptor.swift
//  NewApp
//
//  Created by Pankaj Bawane on 22/06/25.
//

import Foundation

final public class NetworkInterceptor {
    public static let shared = NetworkInterceptor()
    
    private init() {
        URLSessionConfiguration.enableNetworkSwizzling()
    }
}
