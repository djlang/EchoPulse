//
//  MetronomeView.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//
import SwiftUI

struct MetronomeView: View {
    @StateObject private var viewModel = MetronomeViewModel()
    @State private var pendulumDirection: Double = -1

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
        .onChange(of: viewModel.currentBeatIndex) { _, _ in
            guard viewModel.isRunning else { return }
            // 每拍摆一次：左右交替
            let halfBeat = max(0.12, viewModel.beatDurationSeconds / 2)
            withAnimation(.easeInOut(duration: halfBeat)) {
                pendulumDirection *= -1
            }
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var pendulumView: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemGray6))

            VStack(spacing: 10) {
                // Beat indicator (4/4)
                HStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(i == viewModel.currentBeatIndex ? Color.orange : Color.gray.opacity(0.35))
                            .frame(width: i == 0 ? 12 : 9, height: i == 0 ? 12 : 9)
                    }
                }
                .padding(.top, 16)

                GeometryReader { proxy in
                    let size = proxy.size
                    let angle = Angle.degrees(pendulumDirection * 22)

                    ZStack {
                        // Background image (mechanical metronome)
                        Image("metronome")
                            .resizable()
                            .scaledToFit()
                            .frame(width: size.width, height: size.height)

                        // Overlay pendulum needle on top of the image.
                        // Adjust these ratios if the pivot does not align with the image.
                        let pivot = CGPoint(x: size.width * 0.50, y: size.height * 0.12)
                        let rodLength = size.height * 0.62

                        VStack(spacing: 0) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange.opacity(0.9))
                                .frame(width: 4, height: rodLength)
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 28, height: 28)
                                .shadow(color: Color.black.opacity(0.12), radius: 6, y: 3)
                        }
                        .position(x: pivot.x, y: pivot.y + rodLength / 2)
                        .rotationEffect(angle, anchor: .top)
                        .overlay(alignment: .top) {
                            Circle()
                                .fill(Color.orange.opacity(0.9))
                                .frame(width: 10, height: 10)
                                .position(pivot)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }

    private var flashView: some View {
        let isAccent = viewModel.currentBeatIndex == 0
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
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(i == viewModel.currentBeatIndex ? Color.primary : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            .offset(y: 85)
        }
    }
}

#Preview {
    MetronomeView()
}
