//
//  MyStorageManager.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/19/24.
//

import Foundation
import Zip

var StorageManager = TwibStorageManager()

class TwibStorageManager: ObservableObject {
    let manager = FileManager.default
    let tmpDirectoryURL = FileManager.default.temporaryDirectory
    let appSupportDirectoryURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let zipsDirectoryURL: URL
    let songsDirectoryURL: URL
    @Published var busy: Bool = false
    @Published var songDownloadsSize: String = "0.000"
    @Published var cacheSize: String = "0.000"
    
    // MARK: BASIC INIT
    init() {
        do {
            self.zipsDirectoryURL = tmpDirectoryURL.appendingPathComponent("zips")
            self.songsDirectoryURL = appSupportDirectoryURL.appendingPathComponent("song_downloads")
            
            try manager.createDirectory(at: zipsDirectoryURL, withIntermediateDirectories: true)
            try manager.createDirectory(at: songsDirectoryURL, withIntermediateDirectories: true)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: CLEARING STORAGE
    private func clearDirectory(at url: URL) throws {
        let contents = try manager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        for fileURL in contents {
            try manager.removeItem(at: fileURL)
        }
    }
    
    func clearCache() throws {
        print("Clearing cache....")
        DispatchQueue.main.async {
            self.busy = true
        }
        try clearDirectory(at: tmpDirectoryURL)
        try manager.createDirectory(at: zipsDirectoryURL, withIntermediateDirectories: true)
        try self.syncCacheSize()
        DispatchQueue.main.async {
            self.busy = false
        }
        print("Done!")
    }
    
    func clearDownloads() throws {
        print("Clearing downloads....")
        DispatchQueue.main.async {
            self.busy = true
        }
        try clearDirectory(at: songsDirectoryURL)
        try self.syncDownloadsSize()
        DispatchQueue.main.async {
            self.busy = false
        }
        print("Done!")
    }
    
    // MARK: CALCULATING SIZE
    func getDirectorySize(at url: URL) throws -> UInt64 {
        var totalSize: UInt64 = 0
        let contents = try manager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for fileURL in contents {
            var isDirectory: ObjCBool = false
            if manager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    // Recursively calculate the size of the subdirectory
                    totalSize += try getDirectorySize(at: fileURL)
                } else {
                    let fileAttributes = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                    if let fileSize = fileAttributes.fileSize {
                        totalSize += UInt64(fileSize)
                    }
                }
            }
        }
        return totalSize
    }
    
    func syncCacheSize() throws {
        let cacheSize = try getDirectorySize(at: tmpDirectoryURL)
        DispatchQueue.main.async {
            let rawValue = Double(cacheSize) / (1024 * 1024)
            self.cacheSize = String(format: "%.3f", rawValue)
        }
    }
    
    func syncDownloadsSize() throws {
        let downloadsSize = try getDirectorySize(at: songsDirectoryURL)
        DispatchQueue.main.async {
            let rawValue = Double(downloadsSize) / (1024 * 1024)
            self.songDownloadsSize = String(format: "%.3f", rawValue)
        }
    }
    
    // MARK: HANDLE DOWNLOADS
    func handleDownload(_ incomingData: Data) -> Bool {
        DispatchQueue.main.async {
            self.busy = true
        }
        let uuid = UUID().uuidString
        let fileURL = zipsDirectoryURL.appendingPathComponent(uuid + ".zip")
        do {
            try incomingData.write(to: fileURL)
            try Zip.unzipFile(fileURL, destination: songsDirectoryURL,
                              overwrite: true, password: nil)
            try manager.removeItem(at: fileURL)
            DispatchQueue.main.async {
                self.busy = false
            }
            return true
        } catch {
            print("Error processing ZIP file: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.busy = false
            }
            return false
        }
    }
}
