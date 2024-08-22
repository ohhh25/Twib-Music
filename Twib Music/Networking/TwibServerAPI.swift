//
//  TwibServerAPI.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/17/24.
//

import Foundation

let hostname = "HOSTNAME"
let port = 3000

var TwibServerAPI = MyTwibServerAPI(hostname: hostname, port: port)

class MyTwibServerAPI {
    private let base: String
    private let url: URL
    
    init(hostname: String, port: Int) {
        self.base = "http://\(hostname):\(port)/api/Twib-Music"
        self.url = URL(string: self.base)!
    }
    
    func prepareDownloadRequest(_ jsonData: Data) -> URLRequest {
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.httpBody = jsonData
        return request
    }
    
    func downloadPlaylist(_ jsonData: Data, completion: @escaping (Bool) -> Void) {
        let request = prepareDownloadRequest(jsonData)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error downloading data: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            completion(StorageManager.handleDownload(data))
            return
        }
        task.resume()
    }
}
