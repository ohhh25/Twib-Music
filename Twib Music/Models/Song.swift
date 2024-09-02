//
//  Song.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/6/24.
//

import Foundation

class Song: Identifiable, ObservableObject {
    let name: String
    let artist: String
    var others: [String] = []
    let album: String
    var image_url: String
    let track_number: Int
    let duration: Int
    
    // Help with matching
    let sID: String
    var external_ids: [String: Any]
    let preview_url: String
    let explicit: Int
    
    let popularity: Int
    
    let location: URL
    @Published var isDownloaded = false
    var twibIdx: Int = -1
    
    init(name: String, artists: [[String: Any]],
         album: [String: Any], track_number: Int,
         duration: Int, sID: String, external_ids: [String: Any],
         preview_url: String, explicit: Int, popularity: Int) {
        // Yeah, lots to do
        self.name  = name
        self.artist = (artists[0]["name"] as? String) ?? ""
        for artist in artists[1...] {
            self.others.append(artist["name"] as? String ?? "")
        }
        self.album = album["name"] as? String ?? ""
        let album_images = album["images"] as? [[String: Any]]
        self.image_url = album_images?.first?["url"] as? String ?? ""
        self.track_number = track_number
        self.duration = duration
        
        self.sID = sID
        self.external_ids = external_ids
        self.preview_url = preview_url
        self.explicit = explicit
        self.popularity = popularity
        
        self.location = StorageManager.songsDirectoryURL.appendingPathComponent(sID + ".m4a")
        self.syncDownloadStatus()
    }
    
    func syncDownloadStatus() {
        self.isDownloaded = StorageManager.manager.fileExists(atPath: location.path)
    }
}
