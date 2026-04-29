//
//  TunerView.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//
import SwiftUI
import Combine

struct TunerView: View {
    @State private var presentedInstrument: InstrumentType?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("选择要调音的乐器")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top)
                
                // 乐器选择按钮列表
                ForEach(InstrumentType.allCases) { instrument in
                    Button {
                        presentedInstrument = instrument
                    } label: {
                        InstrumentCard(instrument: instrument)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("调音器")
            .padding()
        }
        .fullScreenCover(item: $presentedInstrument) { instrument in
            NavigationStack {
                TunerDetailView(instrument: instrument)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("关闭") {
                                presentedInstrument = nil
                            }
                        }
                    }
            }
        }
    }
}

// 提取出来的按钮组件
struct InstrumentCard: View {
    let instrument: InstrumentType
    
    var body: some View {
        HStack {
            Image(systemName: instrument.iconName)
                .font(.system(size: 30))
                .frame(width: 60)
            
            Text(instrument.rawValue)
                .font(.title2)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .foregroundColor(.primary)
    }
}
