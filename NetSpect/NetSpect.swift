//
//  NetSpect.swift
//  NetSpect
//
//  Created by Pankaj Bawane on 20/11/25.
//

import Foundation

final public class NetSpect {
    
    static let shared: NetSpect = NetSpect()
    
    private let manager: CoreManager
    
    private init() {
        manager = CoreManager()
    }
    
    public func enable() {
        manager.enable()
    }
    
    public func disable() {
        manager.disable()
    }
}
