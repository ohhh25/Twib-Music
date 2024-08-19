//
//  TwibServerAPI.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/17/24.
//

import Foundation

let hostname = "192.168.86.46"
let port = 3000

var TwibServerAPI = MyTwibServerAPI(hostname: hostname, port: port)

class MyTwibServerAPI {
    private let base: String
    
    init(hostname: String, port: Int) {
        self.base = "http://\(hostname):\(port)/api/Twib-Music"
    }
    
    func isrcSearch(_ isrc: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: self.base + "?isrc=" + isrc) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        SpotifyAPI.satisfyRequest(request) { data in
            guard let data = data else { completion(nil); return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                completion(json["youtube"])
                return
            }
            else {
                print("Failed to parse the data in JSON")
            }
            completion(nil)
        }
    }
    
    func downloadPlaylist(_ jsonData: Data, completion: @escaping ([String]?) -> Void) {
        guard let url = URL(string: self.base) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.httpBody = jsonData
        SpotifyAPI.satisfyRequest(request) { data in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [String]] {
                completion(json["youtube"])
                return
            }
            else {
                print("Failed to parse the data in JSON")
            }
            completion(nil)
        }
    }
}
