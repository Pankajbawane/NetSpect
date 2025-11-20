//
//  NWLogItem.swift
//  NewApp
//
//  Created by Pankaj Bawane on 19/07/25.
//

import Foundation

struct NWLogItem: Identifiable {
    let id = UUID()
    let startTime: Date = Date()
    let url: String
    
    var method: String = ""
    var headers: String = ""
    var statusCode: Int = 0
    var requestBody: String = ""
    var responseBody: String = ""
    var responseHeaders: String = ""
    var responseTime: TimeInterval = 0
    var mimetype: String?
    var textEncodingName: String?
    var error: Error?
    var finishTime: Date? {
        didSet {
            if let finishTime {
                responseTime = finishTime.timeIntervalSince(startTime)
                isLoading = false
            }
        }
    }
    var isLoading: Bool = true
    
    var host: String {
        guard let urlComponents = URLComponents(string: url) else { return url }
        return urlComponents.host ?? url
    }
}
