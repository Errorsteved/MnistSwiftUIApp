//
//  light.swift
//  mnistapp
//
//  Created by errorsteve on 2024/7/4.
//
import SwiftUI
import Foundation

struct RotatingBorder: ViewModifier {
    @State private var rotation: Double = 0

    func body(content: Content) -> some View {
        ZStack {
            content
                .frame(width: 300, height: 300)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .strokeBorder(
                            AngularGradient(
                                gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
                                center: .center,
                                startAngle: .degrees(rotation),
                                endAngle: .degrees(rotation + 360)
                            ),
                            lineWidth: 15
                        )
                        .frame(width: 320, height: 320)
                )
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 5).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    DrawView(ModelPredict: ModelPredictor())
}
