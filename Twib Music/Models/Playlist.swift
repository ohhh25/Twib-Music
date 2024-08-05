//
//  Playlist.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/5/24.
//

import Foundation

class Playlist: Identifiable, ObservableObject {
    let name: String
    let description: String
    let tracks_url: String
    let image_url: String
    let visible: Int
    @Published var tracks: [Song] = []
    
    init(name: String, description: String, tracks_url: String, image_url: String, visible: Int) {
        self.name = name
        self.description = description
        self.tracks_url = tracks_url
        self.image_url = image_url
        self.visible = visible
    }
    
    func addTracks(_ tracks: [Song]) {
        DispatchQueue.main.async {
            self.tracks.append(contentsOf: tracks)
        }
    }
}

