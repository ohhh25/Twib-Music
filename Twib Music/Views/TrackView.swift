//
//  TrackView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/5/24.
//

import SwiftUI
import UIKit

struct TrackView: View {
    @StateObject var playlist: Playlist
    @State var isPlaying = false
    @State var downloadImage = "arrow.down.circle"
    @State var addedToQueue = false
    
    var body: some View {
        // MARK: JUST HEADING
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Button("", systemImage: isPlaying ? "pause.circle" : "play.circle") {
                    if (!isPlaying && !addedToQueue) {
                        QueueManager.addPlaylistToQueue(playlist.tracks, sID: playlist.sID, shuffle: playlist.shuffle)
                        addedToQueue = true
                    } else {
                        AudioManager.togglePlayback()
                    }
                    isPlaying.toggle()
                }.disabled(playlist.downloadStatus != "complete")
                .font(.custom("Helvetica", size: 48))
                Text("\(playlist.tracks.count) songs")
                    .font(.custom("Helvetica", size: 12))
                    .italic()
                    .padding(.trailing, 24)
            }
                .padding(.leading, 24)
            Spacer()
            if playlist.downloadStatusIcon == "arrow.down.circle.dotted" {
                CircularProgressView(progress: playlist.downloadProgress, icon: Image(systemName: "arrow.down"))
                    .padding(.trailing, 6)
            } else {
                Button("", systemImage: playlist.downloadStatusIcon) {
                    playlist.downloadTracks()
                }
                .font(.custom("Helvetica", size: 36))
            }
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
            ItemView(track: track, idx: idx, isAlbum: playlist is Twib_Music.Album)
        }
        .onAppear() {
            let url = playlist is Twib_Music.Album ? playlist.tracks_url : playlist.tracks_url + "?limit=50"
            if playlist.tracks.isEmpty {
                SpotifyAPI.fetchTracks(playlist, url: url)
            }
            if QueueManager.getPlaylistUniqueID() == playlist.sID {
                self.isPlaying = AudioManager.isPlaying
                playlist.shuffle = QueueManager.shuffleMode
            } else {
                addedToQueue = false
            }
        }
    }
}


struct CircularProgressView: View {
    var progress: Double // Progress value from 0 to 1
    var icon: Image // Icon to display in the center

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                .frame(width: 36, height: 36)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
                .frame(width: 36, height: 36)

            // Icon in the center
            icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
        }
    }
}
