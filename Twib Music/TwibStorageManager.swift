//
//  MyStorageManager.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/19/24.
//

import Foundation
import Zip

var StorageManager = TwibStorageManager()
let reset: Bool = false

class TwibStorageManager {
    let manager = FileManager.default
    let tmpDirectoryURL = FileManager.default.temporaryDirectory
    let appSupportDirectoryURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let zipsDirectoryURL: URL
    let songsDirectoryURL: URL
    
    // MARK: BASIC INIT
    func clearDirectory(at url: URL) throws {
        let contents = try manager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        for fileURL in contents {
            try manager.removeItem(at: fileURL)
        }
    }
    
    func resetStorage() throws {
        print("Resetting....")
        try clearDirectory(at: zipsDirectoryURL)
        try clearDirectory(at: songsDirectoryURL)
        print("Done!")
    }
    
    init() {
        do {
            self.zipsDirectoryURL = tmpDirectoryURL.appendingPathComponent("zips")
            self.songsDirectoryURL = appSupportDirectoryURL.appendingPathComponent("song_downloads")
            
            try manager.createDirectory(at: zipsDirectoryURL, withIntermediateDirectories: true)
            try manager.createDirectory(at: songsDirectoryURL, withIntermediateDirectories: true)
            
            if reset { try self.resetStorage() }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func handleDownload(_ incomingData: Data) -> Bool {
        let uuid = UUID().uuidString
        let fileURL = zipsDirectoryURL.appendingPathComponent(uuid + ".zip")
        do {
            try incomingData.write(to: fileURL)
            try Zip.unzipFile(fileURL, destination: songsDirectoryURL,
                              overwrite: true, password: nil)
            try manager.removeItem(at: fileURL)
            return true
        } catch {
            print("Error processing ZIP file: \(error.localizedDescription)")
            return false
        }
    }
}
