//
//  Song.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/6/24.
//

import Foundation

class Song: Identifiable {
    let name: String
    let artist: String = ""
    let others: [String] = []
    let album: String = ""
    let image_url: String = ""
    let track_number: Int = 0
    let duration: Int = 0
    
    // Help with matching
    let sID: String = ""
    let external_ids: [String: Any] = [:]
    let preview_url: String = ""
    let explicit: Int = -1
    
    let popularity: Int = -1    // fun
    
    init(name: String, artists: [[String: Any]],
         album: [String: Any], track_number: Int,
         duration: Int, sID: String, external_ids: [String: Any],
         preview_url: String, explicit: Int, popularity: Int) {
        // Yeah, lots to do
        self.name  = name
    }
}
