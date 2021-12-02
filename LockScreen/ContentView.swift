//
//  ContentView.swift
//  LockScreen
//
//  Created by Philipp on 02.12.21.
//

import SwiftUI

struct LockScreenButton: View {
    @State private var pressed = false
    @State private var activated = false

    let image: String

    var body: some View {
        Image(systemName: image)
            .font(.title3)
            .frame(width: 50, height: 50)
            .background(activated ? Color.white :
                            Color.black.opacity(pressed ? 0.8 : 0.4))
            .foregroundColor(activated ? .black : .white)
            .clipShape(Circle())
            .scaleEffect(pressed ? 1.5 : 1)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: pressed)
            .onLongPressGesture(minimumDuration: 0.4) { bool in
                pressed = bool
            } perform: {
                activated.toggle()
                pressed = false

                let generator = UIImpactFeedbackGenerator()
                generator.impactOccurred()
            }
    }
}

struct ContentView: View{

    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.amSymbol = ""
        formatter.pmSymbol = ""
        return formatter
    }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image(decorative: "bigsur")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: geo.size.width)

                Color.black.opacity(0.15)

                VStack(spacing: 0) {
                    Image(systemName: "lock.fill")
                        .font(.largeTitle)
                        .padding(.top, 60)

                    Text(Date(), formatter: timeFormatter)
                        .font(.system(size: 82, weight: .thin))

                    Text(Date(), style: .date)
                        .font(.title2)
                        .offset(y: -10)

                    Spacer()

                    HStack {
                        LockScreenButton(image: "flashlight.off.fill")
                        Spacer()
                        LockScreenButton(image: "camera.fill")
                    }
                    .padding([.leading, .trailing, .bottom])

                    Capsule()
                        .fill(Color.white)
                        .frame(width: 150, height: 5)
                        .padding(.bottom, 10)
                }
                .padding([.leading, .trailing])
                .foregroundColor(.white)
            }
        }.ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
