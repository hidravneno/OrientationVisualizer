//
//  BubbleLevelView.swift
//  OrientationVisualizer
//
//  Created by francisco eduardo aramburo reyes on 05/11/25.
//

//
//  BubbleLevelView.swift
//  OrientationVisualizer
//
//  Created by francisco eduardo aramburo reyes on 05/11/25.
//

import SwiftUI
import Combine

struct BubbleLevelView: View {
    @ObservedObject var vm: MotionVM
    var targetTolerance: Double = 3
    var radius: CGFloat = 110
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2).foregroundColor(.secondary)
                .frame(width: radius * 2, height: radius * 2)
            
            Path { p in
                p.move(to: CGPoint(x: -radius, y: 0))
                p.addLine(to: CGPoint(x: radius, y: 0))
                p.move(to: CGPoint(x: 0, y: -radius))
                p.addLine(to: CGPoint(x: 0, y: radius))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
            .foregroundColor(.secondary.opacity(0.5))  
            .frame(width: radius * 2, height: radius * 2)
            
            Circle()
                .fill(isLevel ? Color.green.opacity(0.75) : Color.orange.opacity(0.75))
                .frame(width: 24, height: 24)
                .shadow(radius: 2)
                .offset(bubbleOffset)
                .animation(.easeOut(duration: 0.08), value: vm.rollDeg)
                .animation(.easeOut(duration: 0.08), value: vm.pitchDeg)
            
                .frame(width: radius * 2, height: radius * 2)
                .overlay(alignment: .bottom) {
                    VStack(spacing: 4) {
                        Text(String(format: "roll %.1f° pitch %.1f°", vm.rollDeg, vm.pitchDeg))
                            .font(.caption).monospacedDigit()
                        Text(String(format: "Hz ~ %.0f", vm.sampleHz))
                            .font(.caption2).foregroundColor(.secondary)
                    }.padding(.top, 8)
                }
        }
        .accessibilityLabel("Bubble level")
    }
    
    private var isLevel: Bool {
        abs(vm.rollDeg) <= targetTolerance && abs(vm.pitchDeg) <= targetTolerance
    }

    private var bubbleOffset: CGSize {
        let scale: CGFloat = radius / 15
        var x = CGFloat(vm.rollDeg) * scale
        var y = CGFloat(-vm.pitchDeg) * scale
        let dist = sqrt(x*x + y*y)

        if dist > radius {
            x *= radius / dist
            y *= radius / dist
        }
        return CGSize(width: x, height: y)
    }
}
