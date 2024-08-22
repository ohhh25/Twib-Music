//
//  TwibServerAPI.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/17/24.
//

import Foundation
import Zip

//let hostname = "HOMENAME"
let hostname = "192.168.86.46"
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
            let zipFileURL = StorageManager.zipsDirectoryURL.appendingPathComponent("songs.zip")
            do {
                try data.write(to: zipFileURL)
                try Zip.unzipFile(zipFileURL, destination: StorageManager.songsDirectoryURL, overwrite: true, password: nil)
                try StorageManager.manager.removeItem(at: zipFileURL)
                completion(true)
                return
            } catch {
                print("Error processing ZIP file: \(error.localizedDescription)")
                completion(false)
                return
            }
        }
        task.resume()
    }
}
