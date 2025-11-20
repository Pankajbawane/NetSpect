//
//  ContentView.swift
//  NewApp
//
//  Created by Pankaj Bawane on 22/06/25.
//

import Foundation

class CallService {
    
    init() {
        let urls: [String] = ["https://reqres.in/api/users?page=2",
                              "https://reqres.in/api/users/2",
                              "https://reqres.in/api/unknown"
        ]
        
        Task {
            
            await withTaskGroup { group in
                for _ in 0...20 {
                    for url in urls {
                        group.addTask {
                            await Self.makeRequest(urlString: url)
                        }
                    }
                }
                
                for _ in 0...1 {
                    group.addTask {
                        await Self.makeRequest(urlString: "https://example.url.unavailable/api/404/error")
                    }
                }
                
                for _ in 0...2 {
                    group.addTask {
                        await Self.makeRequest(urlString: "https://reqres.in/api/users/2", method: "POST")
                    }
                }
            }
        }
    }
    
    static func makeRequest(urlString: String, method: String = "GET") async {
        
        guard let url = URL(string: urlString) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let result = try? await session.data(for: urlRequest)
        guard let result else { return }
        //let json = String(data: result.0, encoding: .utf8)
        //print(json ?? "No response")
        print("status code: ", (result.1 as? HTTPURLResponse)?.statusCode ?? 0)
        print("")
    }
}
