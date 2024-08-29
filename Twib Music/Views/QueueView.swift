//
//  QueueView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/26/24.
//

import SwiftUI
import UIKit

let gradientImage: UIImage? = createGradientImage(size: CGSize(width: 600, height: 1000))

struct QueueView: View {
    var body: some View {
        VStack {
            Text("Queue is Empty")
                .font(.custom("Helvetica", size: 24))
                .fontWeight(.medium)
                .padding(.top, 12)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(uiImage: gradientImage ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    QueueView()
}

func createGradientImage(size: CGSize) -> UIImage? {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = CGRect(origin: .zero, size: size)
    gradientLayer.colors = [
        UIColor(red: 255.0 / 255.0, green: 252.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0).cgColor,
        UIColor(red: 118.0 / 255.0, green: 214.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor,
        UIColor(red: 255.0 / 255.0, green: 252.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0).cgColor
    ]
    gradientLayer.locations = [0, 0.5, 1]

    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image
}
