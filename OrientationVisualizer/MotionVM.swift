//
//  MotionVM.swift
//  OrientationVisualizer
//
//  Created by francisco eduardo aramburo reyes on 05/11/25.
//

import Foundation
import CoreMotion
import Combine

@MainActor
final class MotionVM: ObservableObject {
    // MARK: - Published Properties
    @Published var rollDeg: Double = 0
    @Published var pitchDeg: Double = 0
    @Published var yawDeg: Double = 0

    @Published var qx: Double = 0
    @Published var qy: Double = 0
    @Published var qz: Double = 0
    @Published var qw: Double = 1

    @Published var sampleHz: Double = 60
    @Published var errorMessage: String? = nil

    // MARK: - Private Properties
    private let mgr = CMMotionManager()
    private var demoTask: Task<Void, Never>?
    private var lastTimestamp: TimeInterval?
    private var offRoll: Double = 0
    private var offPitch: Double = 0
    private var offYaw: Double = 0
    private let alpha: Double = 0.05 // smoothing factor for low-pass filter

    // MARK: - Public Methods
    /// Starts device motion updates or demo mode.
    func start(updateHz: Double = 60, demo: Bool? = nil) {
        if demo == true {
            startDemo(updateHz: updateHz)
            return
        }

        guard mgr.isDeviceMotionAvailable else {
            print("⚠️ Device motion not available, starting demo mode instead.")
            startDemo(updateHz: updateHz)
            return
        }

        mgr.deviceMotionUpdateInterval = 1.0 / updateHz
        mgr.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self, let motion = motion else { return }

            let attitude = motion.attitude
            let q = attitude.quaternion

            Task { @MainActor in
                self.rollDeg = attitude.roll.toDegrees - self.offRoll
                self.pitchDeg = attitude.pitch.toDegrees - self.offPitch
                self.yawDeg = attitude.yaw.toDegrees - self.offYaw

                self.qx = q.x
                self.qy = q.y
                self.qz = q.z
                self.qw = q.w

                self.sampleHz = updateHz
            }
        }
    }

    /// Stops motion updates and demo.
    func stop() {
        mgr.stopDeviceMotionUpdates()
        demoTask?.cancel()
        demoTask = nil
        lastTimestamp = nil
    }

    /// Calibrates the current roll, pitch, and yaw as offset (zero reference).
    func calibrate() {
        offRoll += rollDeg
        offPitch += pitchDeg
        offYaw += yawDeg
    }

    // MARK: - Private Demo Mode
    private func startDemo(updateHz: Double) {
        demoTask?.cancel()
        demoTask = Task { [weak self] in
            guard let self else { return }
            var t: Double = 0
            let dt = 1.0 / updateHz

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(dt * 1_000_000_000))
                t += dt

                let r = sin(t * 1.2) * 8
                let p = cos(t * 0.9) * 6

                await MainActor.run {
                    self.rollDeg = self.lowPass(current: r, previous: self.rollDeg)
                    self.pitchDeg = self.lowPass(current: p, previous: self.pitchDeg)
                    self.yawDeg = 0

                    self.qx = 0
                    self.qy = 0
                    self.qz = 0
                    self.qw = 1

                    self.sampleHz = updateHz
                }
            }
        }
    }

    // MARK: - Helpers
    private func lowPass(current: Double, previous: Double) -> Double {
        previous + alpha * (current - previous)
    }
}

// MARK: - Extensions
private extension Double {
    var toDegrees: Double { self * 180.0 / .pi }
}
