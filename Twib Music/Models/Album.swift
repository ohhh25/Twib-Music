//
//  Album.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/9/24.
//

import Foundation

class Album: Playlist {
    let artist: String
    var others: [String] = []
    let type: String
    let total_tracks: Int
    let release_date: String
    let external_ids: [String: Any]
    let popularity: Int
    
    init(name: String, tracks_url: String, image_url: String,
         artists: [[String: Any]], type: String, total_tracks: Int,
         release_date: String, external_ids: [String: Any], popularity: Int) {
        // first subclass init
        self.artist = (artists[0]["name"] as? String) ?? ""
        for artist in artists[1...] {
            self.others.append(artist["name"] as? String ?? "")
        }
        self.type = type
        self.total_tracks = total_tracks
        self.release_date = release_date
        self.external_ids = external_ids
        self.popularity = popularity
        super.init(name: name, tracks_url: tracks_url, image_url: image_url)
    }
}
