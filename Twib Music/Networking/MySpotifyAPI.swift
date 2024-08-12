//
//  MySpotifyAPI.swift
//  Twib Music
//
//  Created by Lukas Cao on 7/31/24.
//

import Foundation

var SpotifyAPI = MySpotifyAPI()

class MySpotifyAPI: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var albums: [Album] = []
    
    private var Session: SPTSession?
    private var accessToken: String = ""
    private var refreshToken: String = ""
    
    init() {
        self.initializeData()
    }
    
    private func initializeData() {
        self.playlists = [Playlist(name: "Liked Songs", description: "",
                                   tracks_url: "https://api.spotify.com/v1/me/tracks",
                                   image_url: "https://raw.githubusercontent.com/ohhh25/Twib-Music/main/Twib%20Music/Assets.xcassets/saved.imageset/saved.png",
                                   visible: -1)]
        self.albums = []
    }
    
    func saveSession(_ session: SPTSession) {
        self.Session = session
        self.accessToken = session.accessToken
        self.refreshToken = session.refreshToken
        self.initializeData()
        self.fetchPlaylists(url: "https://api.spotify.com/v1/me/playlists?limit=50")
        self.fetchAlbums(url: "https://api.spotify.com/v1/me/albums?limit=50")
    }
    
    func handleReponse(_ response: HTTPURLResponse) -> Bool {
        let code = response.statusCode
        switch code {
        case 200:
            return true
        case 401:
            print("Status \(code): Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user.")
            return false
        case 403:
            print("Status \(code): Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won't help here.")
            return false
        case 429:
            print("Status \(code): The app has exceeded its rate limits.")
            return false
        default:
            print("Status \(code)")
            return false
        }
    }
    
    func satisfyRequest(_ request: URLRequest, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Return if error exists
            if let error = error {
                print("Some Error: \(error.localizedDescription)")
                completion(nil); return
            }
            // Return if response is not HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                completion(nil); return
            }
            // Check Status Code
            if !self.handleReponse(httpResponse) {
                completion(nil); return
            }
            // Check If Data was Received
            guard let data = data else {
                print("No data received")
                completion(nil); return
            }
            completion(data)
        }
        task.resume()
    }
    
    func parsePlaylists(_ array: [[String: Any]]) -> [Playlist] {
        let parsedPlaylists = array.compactMap { playlist -> Playlist? in
            guard
                let name = playlist["name"] as? String,
                let description = playlist["description"] as? String,
                let tracks = playlist["tracks"] as? [String: Any],
                let tracks_url = tracks["href"] as? String,
                let images = playlist["images"] as? [[String: Any]],
                let image_url = images.first?["url"] as? String
            else {
                return nil
            }
            let visible = (playlist["public"] as? Int) ?? -1
            return Playlist(name: name, description: description, tracks_url: tracks_url, image_url: image_url, visible: visible)
        }
        return parsedPlaylists
    }
    
    func fetchPlaylists(url: String) {
        // Setup Request
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // Big Stuff
        self.satisfyRequest(request) { data in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let items = json["items"] as? [[String: Any]] {
                    // pass an array of dictionaries get an array of Playlist struct
                    DispatchQueue.main.async {
                        self.playlists.append(contentsOf: self.parsePlaylists(items))
                        print("\(self.playlists.count) Playlists fetched")
                    }
                }
                else {
                    print("Failed to get items from JSON data")
                }
                if let next = json["next"] as? String {
                    self.fetchPlaylists(url: next)
                }
            }
            else {
                print("Failed to parse the JSON data")
            }
        }
    }
    
    func parseAlbums(_ array: [[String: Any]]) -> [Album] {
        let parsedAlbums: [Album] = array.compactMap { item -> Album? in
            guard
                let album = item["album"] as? [String: Any],
                // inherited values
                let name = album["name"] as? String,
                let tracks = album["tracks"] as? [String: Any],
                let tracks_url = tracks["href"] as? String,
                let images = album["images"] as? [[String: Any]],
                let image_url = images.first?["url"] as? String,
                // extended values
                let artists = album["artists"] as? [[String: Any]],
                let type = album["album_type"] as? String,
                let total_tracks = album["total_tracks"] as? Int,
                let release_date = album["release_date"] as? String,
                let external_ids = album["external_ids"] as? [String: Any],
                let popularity = album["popularity"] as? Int
            else {
                return nil
            }
            return Album(name: name, tracks_url: tracks_url, image_url: image_url,
                         artists: artists, type: type, total_tracks: total_tracks,
                         release_date: release_date, external_ids: external_ids,
                         popularity: popularity)
        }
        return parsedAlbums
    }
    
    func fetchAlbums(url: String) {
        // Setup Request
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // Big Stuff
        self.satisfyRequest(request) { data in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let items = json["items"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.albums.append(contentsOf: self.parseAlbums(items))
                        print("\(self.albums.count) Albums fetched")
                    }
                }
                else {
                    print("Failed to get items from JSON data")
                }
                if let next = json["next"] as? String {
                    self.fetchAlbums(url: next)
                }
            }
            else {
                print("Failed to parse the JSON data")
            }
        }
    }
    
    func parseTracks(_ array: [[String: Any]], isAlbum: Bool) -> [Song] {
        let songs: [Song] = array.compactMap { item -> Song? in
            guard let song = isAlbum ? item : item["track"] as? [String: Any] else { return nil }
            let local = song["is_local"] as? Int
            if local == 1 {
                return nil
            }
            guard
                let name = song["name"] as? String,
                let artists = song["artists"] as? [[String: Any]],
                let album = (isAlbum) ? [:] : song["album"] as? [String: Any],
                //let album = song["album"] as? [String: Any],
                let track_number = song["track_number"] as? Int,
                let duration = song["duration_ms"] as? Int,
                let sID = song["id"] as? String
            else {
                return nil
            }
            let external_ids = song["external_ids"] as? [String: Any] ?? [:]
            let preview_url = (song["preview_url"] as? String) ?? ""
            let explicit = (song["explicit"] as? Int) ?? -1
            let popularity = song["popularity"] as? Int ?? -1
            return Song(name: name, artists: artists, album: album, track_number: track_number, duration: duration, sID: sID, external_ids: external_ids, preview_url: preview_url, explicit: explicit, popularity: popularity)
        }
        return songs
    }
    
    func fetchTracks(_ playlist: Playlist, url: String) {
        // Setup Request
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // Big Stuff
        self.satisfyRequest(request) { data in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let items = json["items"] as? [[String: Any]] {
                    let tracks = self.parseTracks(items, isAlbum: playlist is Twib_Music.Album)
                    playlist.addTracks(tracks)
                }
                else {
                    print("Failed to get items from JSON data")
                }
                if let next = json["next"] as? String {
                    self.fetchTracks(playlist, url: next)
                }
            }
            else {
                print("Failed to parse the JSON data")
            }
        }
    }
}
