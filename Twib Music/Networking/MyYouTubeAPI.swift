//
//  MyYouTubeAPI.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/12/24.
//

import Foundation

var YouTubeAPI = MyYouTubeAPI()

class MyYouTubeAPI {
    private let APIkey = "APIKEY"
    let isrc_base = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&type=video"
    
    func isrcSearch(_ isrc: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: isrc_base + "&q=\(isrc)&key=\(APIkey)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        SpotifyAPI.satisfyRequest(request) { data in
            guard let data = data else { completion(nil); return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let pI = json["pageInfo"] as? [String: Any]
                guard let count = pI?["totalResults"] as? Int else { completion(nil); return }
                if count <= 5 {
                    print("Yay! less than 5!")
                    if count == 1 {
                        print("EXACT MATCH??? :///")
                        let item = (json["items"] as? [Any])?.first as? [String: Any]
                        let YTid = (item?["id"] as? [String: Any])?["videoId"] as? String ?? nil
                        completion(YTid)
                        return
                    }
                }
            }
            else {
                print("Failed to parse the data in JSON")
            }
            completion(nil)
        }
    }
}
