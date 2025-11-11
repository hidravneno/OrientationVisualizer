//
//  OrientationCubeView.swift
//  OrientationVisualizer
//
//  Created by francisco eduardo aramburo reyes on 05/11/25.
//

import SwiftUI
import SceneKit

struct OrientationCubeView: UIViewRepresentable {
    var qx: Double; var qy: Double; var qz: Double; var qw: Double

    func makeUIView(context: Context) -> SCNView {
        let v = SCNView()
        v.scene = SCNScene()
        v.backgroundColor = .clear
        v.allowsCameraControl = false

        let cube = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.06)
        let m = SCNMaterial(); m.diffuse.contents = UIColor.systemOrange; cube.materials = [m]
        let node = SCNNode(geometry: cube)
        context.coordinator.node = node
        v.scene?.rootNode.addChildNode(node)

        let light = SCNNode(); light.light = SCNLight(); light.light?.type = .omni; light.position = SCNVector3(2,2,4)
        v.scene?.rootNode.addChildNode(light)

        let cam = SCNNode(); cam.camera = SCNCamera(); cam.position = SCNVector3(0,0,5)
        v.scene?.rootNode.addChildNode(cam)

        return v
    }

    func updateUIView(_: SCNView, context: Context) {
        context.coordinator.node?.orientation = SCNQuaternion(Float(qx), Float(qy), Float(qz), Float(qw))
    }

    func makeCoordinator() -> Coord { Coord() }
}

final class Coord {
    var node: SCNNode?
}
