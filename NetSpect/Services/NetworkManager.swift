//
//  NetworkInterceptor.swift
//  NewApp
//
//  Created by Pankaj Bawane on 22/06/25.
//

import Foundation

class NetworkInterceptor {
    static let shared = NetworkInterceptor()
    
    private init() {
        URLSessionConfiguration.enableProtocolSwizzling()
    }
}

class InterceptingURLProtocol: URLProtocol {
    private var sessionTask: URLSessionDataTask?
    private static let taskCacheKey = "TRACKED_TASK"

    override class func canInit(with request: URLRequest) -> Bool {
        // Avoid intercepting requests twice
        URLProtocol.property(forKey: taskCacheKey, in: request) == nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let thisRequest = request as? NSMutableURLRequest else {
            super.startLoading()
            return
        }
        URLProtocol.setProperty(true, forKey: Self.taskCacheKey, in: thisRequest)
        
        var log = NWLogItem(url: request.url?.absoluteString ?? "")
        logger(log: &log, request: thisRequest)
        NWItemManager.shared.add(log)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)

        sessionTask = session.dataTask(with: thisRequest as URLRequest) { data, response, error in
            let random = Int.random(in: 0..<5)
            sleep(UInt32(random))
            
            self.logger(log: &log, response: response, data: data, error: error)
            NWItemManager.shared.add(log)

            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = response {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }

        sessionTask?.resume()
    }

    override func stopLoading() {
        sessionTask?.cancel()
    }
    
    private func logger(log: inout NWLogItem, request: NSMutableURLRequest) {
        print("➡️ Request: \(request.httpMethod) \(request.url?.absoluteString ?? "")")
        log.method = request.httpMethod
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("🧾 Request Headers:\n\(headers.prettyPrintedJSON)")
            log.headers = headers.prettyPrintedJSON
        }

        if let body = request.httpBody {
            if let json = try? JSONSerialization.jsonObject(with: body, options: []),
               let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
               let pretty = String(data: data, encoding: .utf8) {
                print("📦 Request Body:\n\(pretty)")
                log.requestBody = pretty
            } else if let string = String(data: body, encoding: .utf8) {
                print("📦 Request Body (raw):\n\(string)")
                log.requestBody = string
            }
        }
    }
    
    private func logger(log: inout NWLogItem, response: URLResponse?, data: Data?, error: Error?) {
        if let httpResponse = response as? HTTPURLResponse {
            print("📄 Response Headers:\n\(httpResponse.allHeaderFields.prettyPrintedHeaders)" as Any)
            log.statusCode = httpResponse.statusCode
            log.responseHeaders = httpResponse.allHeaderFields.prettyPrintedHeaders
            log.mimetype = httpResponse.mimeType
            log.textEncodingName = httpResponse.textEncodingName
        }
        
        if let data = data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
               let pretty = String(data: jsonData, encoding: .utf8) {
                print("📬 Response Body:\n\(pretty)")
                log.responseBody = pretty
            } else if let string = String(data: data, encoding: .utf8) {
                print("📬 Response Body (raw):\n\(string)")
                log.responseBody = string
            }
        }
        log.error = error
        log.finishTime = Date()
    }
}

extension Dictionary {
    var prettyPrintedJSON: String {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "\(self)"
    }
    
    var prettyPrintedHeaders: String {
        var headers = ""
        for (key, value) in self {
            headers += "\(key): \(value)\n"
        }
        return headers
    }
}

fileprivate extension URLSessionConfiguration {
    static func enableProtocolSwizzling() {
        let defaultSelector = #selector(getter: URLSessionConfiguration.default)
        let ephemeralSelector = #selector(getter: URLSessionConfiguration.ephemeral)

        guard let defaultMethod = class_getClassMethod(URLSessionConfiguration.self, defaultSelector),
              let swizzledDefaultMethod = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.myDefault)),

              let ephemeralMethod = class_getClassMethod(URLSessionConfiguration.self, ephemeralSelector),
              let swizzledEphemeralMethod = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.myEphemeral)) else {
            return
        }

        method_exchangeImplementations(defaultMethod, swizzledDefaultMethod)
        method_exchangeImplementations(ephemeralMethod, swizzledEphemeralMethod)
    }

    @objc class func myDefault() -> URLSessionConfiguration {
        let config = myDefault()
        injectInterceptor(into: config)
        return config
    }

    @objc class func myEphemeral() -> URLSessionConfiguration {
        let config = myEphemeral()
        injectInterceptor(into: config)
        return config
    }

    private static func injectInterceptor(into config: URLSessionConfiguration) {
        var classes = config.protocolClasses ?? []
        if !classes.contains(where: { $0 == InterceptingURLProtocol.self }) {
            classes.insert(InterceptingURLProtocol.self, at: 0)
            config.protocolClasses = classes
        }
    }
}
