//
//  ItemView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/21/24.
//

import SwiftUI
import AVFoundation

var player: AVPlayer?

struct ItemView: View {
    @StateObject var track: Song
    let idx: Int
    let isAlbum: Bool
    
    var body: some View {
        HStack {
            if isAlbum {
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
                if track.isDownloaded {
                    Button("Play", systemImage: "play.fill", action: {
                        playSong(track)
                    })
                } else {
                    Text(isAlbum ? "Download Album First" : "Download Playlist First")
                }
            } label: {
                Label("", systemImage: "ellipsis.circle")
                    .font(.custom("Helvetica", size: 18))
            }
            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: -18))
        }
    }
}


func playSong(_ track: Song) {
    if track.isDownloaded {
        AudioManager.play(track: track)
    }
}
