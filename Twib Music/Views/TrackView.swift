//
//  TrackView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/5/24.
//

import SwiftUI
import UIKit
import AVFoundation

var player: AVPlayer?

struct TrackView: View {
    @StateObject var playlist: Playlist
    @State var isPlaying = false
    @State var downloadImage = "arrow.down.circle"
    
    var body: some View {
        // MARK: JUST HEADING
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Button("", systemImage: isPlaying ? "pause.circle" : "play.circle") {
                    isPlaying.toggle()
                }
                .font(.custom("Helvetica", size: 48))
                Text("\(playlist.tracks.count) songs")
                    .font(.custom("Helvetica", size: 12))
                    .italic()
                    .padding(.trailing, 24)
            }
                .padding(.leading, 24)
            Spacer()
            Button("", systemImage: downloadImage) {
                downloadImage = "arrow.down.circle.dotted"
                playlist.downloadTracks { success in
                    downloadImage = success ? "arrow.down.circle.fill" : "arrow.down.app.dashed.trianglebadge.exclamationmark"
                }
            }
            .font(.custom("Helvetica", size: 36))
            AsyncImage(url: URL(string: playlist.image_url)) { image in
                image
                    .resizable()
            } placeholder: {
                ProgressView()
            }
                .frame(width: 128, height: 128)
                .padding(.trailing, 24)
        }
            .frame(height: 128)
            .padding(.bottom, 6)
        .toolbar {
            Text(playlist.name)
                .font(.custom("Helvetica", size: 16))
                .fontWeight(.medium)
                .frame(height: 48)
                .lineLimit(2)
        }
        // MARK: REAL BODY
        List(Array(playlist.tracks.enumerated()), id: \.offset) { idx, track in
            HStack {
                if playlist is Twib_Music.Album {
                    Text("\(idx + 1)")
                        .font(.custom("Helvetica", size: 16))
                        .frame(width: 18, alignment: .trailing)
                        .padding(.leading, -6)
                }
                else { ImageView(image_url: track.image_url, size: 48).padding(.leading, -6) }
                VStack(alignment: .leading) {
                    Text(track.name)
                        .font(.custom("Helvetica", size: 16))
                        .padding(.bottom, 2)
                        .lineLimit(1)
                    Text(track.artist)
                        .font(.custom("Helvetica", size: 12))
                        .fontWeight(.light)
                        .lineLimit(1)
                }
                .padding(.leading, 12)
                Spacer()
                Menu{
                    Button("YouTube", systemImage: "arrow.up.forward.app", action: {
                        someFunction(track)
                    })
                } label: {
                    Label("", systemImage: "ellipsis.circle")
                        .font(.custom("Helvetica", size: 18))
                }
                .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: -18))
            }
        }
        .onAppear() {
            print(playlist.description)
            let url = playlist is Twib_Music.Album ? playlist.tracks_url : playlist.tracks_url + "?limit=50"
            if playlist.tracks.isEmpty {
                SpotifyAPI.fetchTracks(playlist, url: url)
            }
        }
    }
}

func someFunction(_ track: Song) {
    guard let location = track.location else { print("File not found"); return }
    DispatchQueue.main.async {
        player = AVPlayer(url: location)
        player?.play()
    }
}
