import SwiftUI

struct Canvas: View {
    @Binding var image: Image
    @Binding var lineWidth: CGFloat

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 300, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: lineWidth)
                    .foregroundColor(.clear)
                    .shadow(color: Color.red.opacity(0.5), radius: 10, x: 0, y: 0)
            )
    }
}

struct test2: View {
    @State private var image = Image(systemName: "photo")
    @State private var lineWidth: CGFloat = 0

    var body: some View {
        ZStack {
            // 动态变化的光条
            RoundedRectangle(cornerRadius: 20)
                .stroke(AngularGradient(
                    gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ), lineWidth: 15)
                .frame(width: 330, height: 330)
                .rotationEffect(.degrees(360), anchor: .center)
                .animation(Animation.linear(duration: 5).repeatForever(autoreverses: false))
                .shadow(color: Color.red.opacity(0.5), radius: 10, x: 0, y: 0)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .blur(radius: 5)
                .mask(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]), startPoint: .center, endPoint: .bottom)
                        .frame(width: 330, height: 330)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                )
            Canvas(image: $image, lineWidth: $lineWidth)
                .frame(width: 300, height: 300)
                .aspectRatio(contentMode: .fit)
        }
        .onAppear {
            withAnimation {
                // 触发动画
            }
        }
    }
}


#Preview {
    test2()
}
