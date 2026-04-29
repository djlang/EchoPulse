//
//  MetronomeView.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//
import SwiftUI

struct MetronomeView: View {
    @StateObject private var viewModel = MetronomeViewModel()
    @State private var pendulumStartDate = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Text("\(viewModel.bpm) BPM")
                        .font(.system(size: 56, weight: .bold, design: .monospaced))

                    Picker("样式", selection: $viewModel.style) {
                        ForEach(MetronomeViewModel.Style.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("拍号", selection: $viewModel.timeSignature) {
                        ForEach(MetronomeViewModel.TimeSignature.allCases) { signature in
                            Text(signature.rawValue).tag(signature)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Group {
                    switch viewModel.style {
                    case .pendulum:
                        pendulumView
                    case .flash:
                        flashView
                    }
                }
                .frame(height: 220)

                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Button {
                            viewModel.bpm = max(40, viewModel.bpm - 1)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 34))
                        }
                        .disabled(viewModel.isRunning)

                        Slider(
                            value: Binding(
                                get: { Double(viewModel.bpm) },
                                set: { viewModel.bpm = Int($0.rounded()) }
                            ),
                            in: 40...240,
                            step: 1
                        )
                        .disabled(viewModel.isRunning)

                        Button {
                            viewModel.bpm = min(240, viewModel.bpm + 1)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 34))
                        }
                        .disabled(viewModel.isRunning)
                    }

                    Toggle("滴答声", isOn: $viewModel.soundEnabled)
                        .padding(.horizontal)

                    Button {
                        viewModel.toggle()
                    } label: {
                        Text(viewModel.isRunning ? "暂停" : "开始")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(viewModel.isRunning ? Color.red.opacity(0.9) : Color.orange)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("节拍器")
        }
        .onChange(of: viewModel.isRunning) { _, _ in
            if viewModel.isRunning {
                pendulumStartDate = Date()
            }
        }
        .onChange(of: viewModel.style) { _, _ in
            pendulumStartDate = Date()
        }
        .onChange(of: viewModel.bpm) { _, _ in
            pendulumStartDate = Date()
        }
        .onAppear { pendulumStartDate = Date() }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var pendulumView: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemGray6))

            VStack(spacing: 10) {
                // Beat indicator
                HStack(spacing: 10) {
                    ForEach(0..<viewModel.timeSignature.beatsPerBar, id: \.self) { i in
                        Circle()
                            .fill(i == viewModel.currentBeatIndex ? Color.orange : Color.gray.opacity(0.35))
                            .frame(width: i == 0 ? 12 : 9, height: i == 0 ? 12 : 9)
                    }
                }
                .padding(.top, 16)

                GeometryReader { proxy in
                    let size = proxy.size

                    ZStack {
                        // Background image (mechanical metronome)
                        Image("metronome")
                            .resizable()
                            .scaledToFit()
                            .frame(width: size.width, height: size.height)

                        // Overlay pendulum needle on top of the image.
                        // Adjust these ratios if the pivot does not align with the image.
                        // Inverted style: bob on top, pivot (center) at bottom.
                        let pivot = CGPoint(x: size.width * 0.50, y: size.height * 0.68)
                        let rodLength = size.height * 0.48
                        let bobDiameter: CGFloat = 10
                        let rodWidth: CGFloat = 5
                        
                        TimelineView(.animation) { context in
                            let phase = pendulumPhase(at: context.date)
                            let angle = Angle.degrees(phase * 30)
                            
                            PendulumNeedleView(
                                pivot: pivot,
                                angle: angle,
                                rodLength: rodLength,
                                rodWidth: rodWidth,
                                bobDiameter: bobDiameter
                            )
                        }

                        // Pivot marker (not rotating).
                        Circle()
                            .fill(Color(.systemGray2))
                            .frame(width: 10, height: 10)
                            .overlay {
                                Circle()
                                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
                            }
                            .position(pivot)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }

    private var flashView: some View {
        let isAccent = viewModel.timeSignature.accentBeatIndices.contains(viewModel.currentBeatIndex)
        let isOn = viewModel.isRunning
        return ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemGray6))

            Circle()
                .fill(isAccent ? Color.orange : Color.blue)
                .frame(width: 110, height: 110)
                .opacity(isOn ? 0.95 : 0.25)
                .scaleEffect(isOn ? 1.0 : 0.92)
                .animation(.easeInOut(duration: 0.08), value: viewModel.currentBeatIndex)

            HStack(spacing: 10) {
                ForEach(0..<viewModel.timeSignature.beatsPerBar, id: \.self) { i in
                    Circle()
                        .fill(i == viewModel.currentBeatIndex ? Color.primary : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            .offset(y: 85)
        }
    }
    
    private func pendulumPhase(at date: Date) -> Double {
        guard viewModel.isRunning, viewModel.style == .pendulum else { return -1 }
        
        let beat = max(0.12, viewModel.beatDurationSeconds)
        // One beat is half a swing cycle (left -> right).
        let period = beat * 2
        let t = date.timeIntervalSince(pendulumStartDate)
        // -1...+1 continuous oscillation.
        return -cos((2 * Double.pi / period) * t)
    }
}

private struct PendulumNeedleView: View {
    let pivot: CGPoint
    let angle: Angle
    let rodLength: CGFloat
    let rodWidth: CGFloat
    let bobDiameter: CGFloat

    var body: some View {
        // Coordinate system for drawing:
        // - pivot is the rotation center
        // - rod spans from y = -rodLength (top) to y = 0 (pivot)
        let topTipDiameter = max(6, rodWidth + 2)
        let sliderWidth = max(18, bobDiameter)
        let sliderHeight: CGFloat = 14
        let sliderCenterY = -(rodLength * 2.0 / 3.0) // 1/3 down from the top

        ZStack {
            // Rod (silver)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.systemGray3))
                .frame(width: rodWidth, height: rodLength)
                .overlay {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                }
                .offset(y: -rodLength / 2)

            // BPM slider weight (silver block on the rod)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(.systemGray2))
                .frame(width: sliderWidth, height: sliderHeight)
                .overlay {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.18), radius: 4, y: 2)
                .offset(y: sliderCenterY)

            // Small top tip
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: topTipDiameter, height: topTipDiameter)
                .offset(y: -rodLength)
        }
        .rotationEffect(angle, anchor: .center)
        .position(pivot)
    }
}

#Preview {
    MetronomeView()
}
