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
    var downloadStatus = "Not Downloaded"
    @Published var downloadStatusIcon = "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90"
    
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
            self.syncDownloadStatus()
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
    
    func getStatusIcon() -> String {
        switch self.downloadStatus {
        case "Not downloaded":
            return "arrow.down.circle"
        case "in progress":
            return "arrow.down.circle.dotted"
        case "complete":
            return "arrow.down.circle.fill"
        default:
            return "arrow.down.app.dashed.trianglebadge.exclamationmark"
        }
    }
    
    func setDownloadStatus(_ status: String) {
        DispatchQueue.main.async {
            self.downloadStatus = status
            self.downloadStatusIcon = self.getStatusIcon()
        }
    }
    
    func syncDownloadStatus() {
        DispatchQueue.main.async {
            var allDownloaded = true
            for track in self.tracks {
                track.syncDownloadStatus()
                if !track.isDownloaded {
                    allDownloaded = false
                }
            }
            self.setDownloadStatus(allDownloaded ? "complete" : "Not downloaded")
        }
    }
    
    func downloadTracks() {
        self.setDownloadStatus("in progress")
        if self.requestBody.isEmpty {
            self.createRequestBody()
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.requestBody, options: .prettyPrinted)
            TwibServerAPI.downloadPlaylist(jsonData) { success in
                success ? self.syncDownloadStatus() : self.setDownloadStatus("failed")
            }
        } catch {
            print("Failed to serialize the JSON: \(error.localizedDescription)")
            syncDownloadStatus()
        }
    }
}

