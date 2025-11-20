//
//  NetworkInterceptor.swift
//  NewApp
//
//  Created by Pankaj Bawane on 22/06/25.
//

import Foundation

final internal class CoreManager {
    
    func enable() {
        URLSessionConfiguration.enableNetworkSwizzling()
    }
    
    func disable() {
        URLSessionConfiguration.disableNetworkSwizzling()
        NetworkLogManager.shared.cancel()
    }
}
