//
//  MyStorageManager.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/19/24.
//

import Foundation

var StorageManager = TwibStorageManager()
let reset: Bool = false

class TwibStorageManager {
    let manager = FileManager.default
    let tmpDirectoryURL = FileManager.default.temporaryDirectory
    let appSupportDirectoryURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let zipsDirectoryURL: URL
    let songsDirectoryURL: URL
    
    func clearDirectory(at url: URL) throws {
        let contents = try manager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        for fileURL in contents {
            try manager.removeItem(at: fileURL)
        }
    }
    
    init() {
        do {
            // Define directory URLs
            self.zipsDirectoryURL = tmpDirectoryURL.appendingPathComponent("zips")
            self.songsDirectoryURL = appSupportDirectoryURL.appendingPathComponent("song_downloads")
            
            // Create new directories
            try manager.createDirectory(at: zipsDirectoryURL, withIntermediateDirectories: true)
            try manager.createDirectory(at: songsDirectoryURL, withIntermediateDirectories: true)
            
            if reset {
                // Clear existing contents
                try clearDirectory(at: zipsDirectoryURL)
                try clearDirectory(at: songsDirectoryURL)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
