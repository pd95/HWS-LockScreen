//
//  ContentView.swift
//  LockScreen
//
//  Created by Philipp on 02.12.21.
//

import SwiftUI
import AVFoundation

extension DateFormatter {
    fileprivate static var hoursAndMinutes: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.amSymbol = ""
        formatter.pmSymbol = ""
        return formatter
    }()
}

extension Date {
    fileprivate var hoursAndMinutesString: String {
        DateFormatter.hoursAndMinutes.string(from: self)
            .trimmingCharacters(in: .whitespaces)
    }
}

struct LockScreenButton: View {
    @State private var pressed = false

    let image: String
    var active: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Image(systemName: image)
            .font(.title3)
            .frame(width: 50, height: 50)
            .background(active ? Color.white :
                            Color.black.opacity(pressed ? 0.8 : 0.4))
            .foregroundColor(active ? .black : .white)
            .clipShape(Circle())
            .scaleEffect(pressed ? 1.5 : 1)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: pressed)
            .onLongPressGesture(minimumDuration: 0.4) { bool in
                pressed = bool
            } perform: {
                action?()
                pressed = false
            }
    }
}

struct ContentView: View{

    // DateComponents(calendar: .current, year: 2021, month: 12, day: 2, hour:9, minute: 41).date!
    @State private var currentDate = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var flashlightActive = false

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

                    Text(currentDate.hoursAndMinutesString)
                        .font(.system(size: 82, weight: .thin))

                    Text(currentDate, style: .date)
                        .font(.title2)
                        .offset(y: -10)

                    Spacer()

                    HStack {
                        LockScreenButton(
                            image: "flashlight.off.fill",
                            active: flashlightActive,
                            action: toggleFlashlight
                        )
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
                .onReceive(timer) { input in
                    currentDate = input
                }
            }
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
    }

    private func toggleFlashlight() {
        let generator = UIImpactFeedbackGenerator()
        generator.impactOccurred()
        flashlightActive.toggle()

        // Toggle the real 'torch' of a physical device
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            defer {
                device.unlockForConfiguration()
            }

            if device.torchMode == .on {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: 1.0)
            }
        } catch {
            print("Unable to update torch: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
