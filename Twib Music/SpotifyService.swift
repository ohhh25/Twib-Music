//
//  SpotifyService.swift
//  Twib Music
//
//  Created by Lukas Cao on 7/31/24.
//

import Foundation

class MySpotifyInterfacer: ObservableObject {
    @Published var playlists: [Playlist] = []
    
    private var accessToken: String = ""
    private var refreshToken: String = ""
    private var expirationDate: Date = Date()
    
    func saveSession(_ session: SPTSession) {
        self.accessToken = session.accessToken
        self.refreshToken = session.refreshToken
        self.expirationDate = session.expirationDate
        self.playlists.append(saved)
        self.fetchPlaylists()
    }
    
    func handleReponse(_ response: HTTPURLResponse) -> Bool {
        let code = response.statusCode
        switch code {
        case 200:
            print("Status \(code)")
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
    
    func fetchPlaylists() {
        // Setup Request
        guard let url = URL(string: "https://api.spotify.com/v1/me/playlists?limit=50&offset=0") else { return }
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
                        print("\(self.playlists.count - 1) Playlists fetched")
                        print(self.playlists[0].image_url)
                    }
                }
                else {
                    print("Failed to get items from JSON data")
                }
            }
            else {
                print("Failed to parse the JSON data")
            }
        }
    }
}

struct Playlist: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let tracks_url: String
    let image_url: String
    let visible: Int
}

var Interfacer = MySpotifyInterfacer()
var saved = Playlist(name: "Liked Songs", description: "", tracks_url: "https://api.spotify.com/v1/me/tracks", image_url: "https://raw.githubusercontent.com/ohhh25/Twib-Music/befa16c9a8b5798ef26763197cdb5fe072b70bbc/Twib%20Music/Assets.xcassets/saved.imageset/saved.png", visible: -1)
