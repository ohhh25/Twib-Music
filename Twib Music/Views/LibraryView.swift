//
//  LibraryView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/10/24.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var spotifyAPI = SpotifyAPI
    @State private var selectedList: listType = .parent_list
    
    var body: some View {
        NavigationStack {
            HeadingView()
            Picker("", selection: $selectedList) {
                ForEach(listType.allCases) { selection in
                    Text(selection.rawValue).tag(selection)
                        .font(.custom("Helvetica", size: 24))
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            List(selectedList == .parent_list ? spotifyAPI.playlists : spotifyAPI.albums) { playlist in
                NavigationLink {
                    TrackView(playlist: playlist)
                } label: {
                    PlaylistView(playlist: playlist)
                }
            }
        }
        .listStyle(.plain)
    }
}

struct ImageView: View {
    let image_url: String
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: image_url)) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width: size, height: size)
    }
}

enum listType: String, CaseIterable, Identifiable {
    case parent_list = "Playlists"
    case child_list = "Albums"
    var id: String { self.rawValue }
}
