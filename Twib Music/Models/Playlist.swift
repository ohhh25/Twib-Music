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

    var requestBody: [String: Any] = [:]
    
    init(name: String, description: String, tracks_url: String, image_url: String, visible: Int) {
        self.name = name
        self.description = description
        self.tracks_url = tracks_url
        self.image_url = image_url
        self.visible = visible
    }
    
    init(name: String, tracks_url: String, image_url: String) {
        self.name = name
        self.tracks_url = tracks_url
        self.image_url = image_url
        self.description = ""
        self.visible = -1
    }
    
    func addTracks(_ tracks: [Song]) {
        DispatchQueue.main.async {
            self.tracks.append(contentsOf: tracks)
        }
    }
    
    func createRequestBody() {
        self.requestBody["metadata"] = self.tracks.map { song in
            return [
                "isrc": song.external_ids["isrc"] as? String ?? "",
                "sID": song.sID,
                "name": song.name,
                "artist": song.artist,
                "album": song.album,
                "other_artists": song.others,
                "duration": song.duration,
                "track_number": song.track_number,
                "explicit": song.explicit
            ]
        }
    }
    
    func addLocation(_ URLs: [URL]) {
        if self.tracks.count != URLs.count {
            print("Number of tracks does not match number of URLs")
            return
        }
        for (index, _) in self.tracks.enumerated() {
            self.tracks[index].location = URLs[index]
        }
    }
    
    func downloadTracks(completion: @escaping (Bool) -> Void) {
        if self.requestBody.isEmpty {
            self.createRequestBody()
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.requestBody, options: .prettyPrinted)
            TwibServerAPI.downloadPlaylist(jsonData) { URLs in
                guard let URLs = URLs else { return }
                DispatchQueue.main.async {
                    self.addLocation(URLs)
                }
                completion(true)
                return
            }
        } catch {
            print("Failed to serialize the JSON: \(error.localizedDescription)")
            completion(false)
            return
        }
    }
}

