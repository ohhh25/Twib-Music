//
//  PlayingView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/26/24.
//

import SwiftUI

fileprivate let topColor = Color(red:(118.0 / 255.0), green:(214.0 / 255.0), blue:(255.0 / 255.0))
fileprivate let botColor = Color(red:(255.0 / 255.0), green:(252.0 / 255.0), blue:(121.0 / 255.0))
fileprivate let grad = [topColor, botColor, topColor]
var playing: Bool = true

struct PlayingView: View {
    var body: some View {
        VStack {
            Text(playing ? "Playing Song" : "No music playing")
                .font(.custom("Helvetica", size: 24))
                .fontWeight(.medium)
            Image("none")
                .resizable()
                .scaledToFit()
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            Text(playing ? "Suburban Legends (Taylor's Version) (From The Vault)": "[Song Title]")
                .font(.custom("Helvetica", size: 24))
                .fontWeight(.bold)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 72, alignment: .topLeading)
            Text(playing ? "Taylor Swift" : "[Artist Name]")
                .font(.custom("Helvetica", size: 18))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            ProgressView()
                .progressViewStyle(.linear)
                .padding(EdgeInsets(top: 24, leading: 0, bottom: 6, trailing: 0))
            HStack {
                Text(playing ? "0:00" :"--:--")
                    .font(.custom("Helvetica", size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(playing ? "2:52" :"--:--")
                    .font(.custom("Helvetica", size: 16))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 24)
            HStack {
                Button("", systemImage: "shuffle") {
                    print("Shuffle Button Pressed")
                }
                .font(.custom("Helvetica", size: 24))
                Spacer()
                Button("", systemImage: "backward.end.fill") {
                    print("Previous Button Pressed")
                }
                Spacer()
                Button("", systemImage: "play.circle.fill") {
                    print("Play Button Pressed")
                }
                .font(.custom("Helvetica", size: 72))
                Spacer()
                Button("", systemImage: "forward.end.fill") {
                    print("Next Button Pressed")
                }
                Spacer()
                Button("", systemImage: "repeat") {
                    print("Repeat Button Pressed")
                }
                .font(.custom("Helvetica", size: 24))
            }
            .font(.custom("Helvetica", size: 36))
            Spacer()
        }
        .padding(EdgeInsets(top: 12, leading: 24, bottom: 0, trailing: 24))
        .background(AngularGradient(colors: grad, center: UnitPoint(x: 0, y: 0)))
    }
}

#Preview {
    PlayingView()
}
