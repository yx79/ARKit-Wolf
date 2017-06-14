//
//  ViewController.swift
//  Wolf
//
//  Created by Yuanjie Xie on 6/10/17.
//  Copyright © 2017 Yuanjie Xie. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var wolfNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    /** create and return ARPlaneNode */
    func createARPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        let pos = SCNVector3Make(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
//        print("New surface detected at \(pos)")
        
        // Create the geometry and its materials
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let grassImage = UIImage(named: "grass")
        let grassMaterial = SCNMaterial()
        grassMaterial.diffuse.contents = grassImage
        grassMaterial.isDoubleSided = true
        plane.materials = [grassMaterial]
        // Create a plane node with the plane geometry
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = pos
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        // add the wolf to pos of the plane node
        if wolfNode == nil {
            if let wolfScene = SCNScene(named: "art.scnassets/wolf.dae") {
                wolfNode = wolfScene.rootNode.childNode(withName: "wolf", recursively: true)
                wolfNode.position = pos
                sceneView.scene.rootNode.addChildNode(wolfNode!)
            }
        }
        return planeNode
    }
    
    
    // plane node didAdd when detected
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createARPlaneNode(anchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    // when detected new plane, update
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        // remove existing plane nodes
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let planeNode = createARPlaneNode(anchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    // when detected plane removed, didRemove the plane
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        // remove existing plane nodes
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
    
    
    
    
    
    
    
    
    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}
