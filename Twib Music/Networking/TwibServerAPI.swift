//
//  TwibServerAPI.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/17/24.
//

import Foundation

let hostname = "HOSTNAME"
let port = 8080

var TwibServerAPI = MyTwibServerAPI(hostname: hostname, port: port)

class MyTwibServerAPI: NSObject, URLSessionDownloadDelegate {
    private let base: String
    private let url: URL
    private var progressHandlers: [URLSessionTask: (Double) -> Void] = [:]
    private var completionHandlers: [URLSessionTask: (Bool) -> Void] = [:]
    private var expectedSizes: [URLSessionTask: Int64] = [:]
    
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
    
    func downloadPlaylist(_ jsonData: Data, expectedSize: Int64, completion: @escaping (Bool) -> Void, progress: @escaping (Double) -> Void) {
        let request = prepareDownloadRequest(jsonData)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: request)
        
        completionHandlers[task] = completion
        progressHandlers[task] = progress
        expectedSizes[task] = expectedSize
        
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // Retrieve and invoke the progress handler for this task
        if let progressHandler = progressHandlers[downloadTask] {
            if let expected = expectedSizes[downloadTask] {
                let progress = Double(totalBytesWritten) / Double(expected)
                progressHandler(progress)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Retrieve the completion handler for this task
        if let completionHandler = completionHandlers[downloadTask] {
            do {
                let data = try Data(contentsOf: location)
                let result = StorageManager.handleDownload(data)
                completionHandler(result)
            } catch {
                print("Error handling downloaded data: \(error.localizedDescription)")
                completionHandler(false)
            }
        }
        
        // Clean up the handlers for this task
        completionHandlers[downloadTask] = nil
        progressHandlers[downloadTask] = nil
    }
    
    // Handle errors during download
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Download failed: \(error.localizedDescription)")
            // Retrieve and invoke the completion handler for this task
            if let completionHandler = completionHandlers[task] {
                completionHandler(false)
            }
        }
        
        // Clean up the handlers for this task
        completionHandlers[task] = nil
        progressHandlers[task] = nil
    }
}
