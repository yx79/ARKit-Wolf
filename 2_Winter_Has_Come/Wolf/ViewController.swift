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
import Photos
import ReplayKit

class ViewController: UIViewController, ARSCNViewDelegate, RPPreviewViewControllerDelegate, UIGestureRecognizerDelegate  {

    @IBOutlet var sceneView: ARSCNView!
    var wolfNode: SCNNode!
    var anchorNode: SCNNode?
    var shutterButton: UIButton!
    var objectsWindow: UIWindow!
    var recordIndicator: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupShutterButton()
        
        sceneView.isUserInteractionEnabled = true
        
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Create a new scene
        let scene = SCNScene()
//        wolfNode?.position = SCNVector3(0, 0, -1) // 10m in front of camera
//        scene.rootNode.addChildNode(wolfNode!)
        
        
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    
    
    
    
//    func hitTest() {
//        // add an ARAnchor based on hit-test
//        let point = CGPoint(x: 0.5, y: 0.5) // Image center
////        let frame =
//        // perform hit-test on frame
////        let results = frame.hitTest(point, types: [.existingPlane, .estimatedHorizontalPlane])
//        
//        // Use the first result
//        if let closestResult = results.first {
//            // create an anchor for it
//            let anchor = ARAnchor(transform: closestResult.worldTransform)
//            // add it to the session
//            session.add(anchor: anchor)
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
//        configuration.isLightEstimationEnabled = true
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - ARSCNViewDelegate
    
//    // Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        guard anchorNode == nil else { return nil }
//
//        let node = SCNNode()
//        return node
//    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    /** create and return ARPlaneNode */
    func createARPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        let pos = SCNVector3Make(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
        print("New surface detected at \(pos)")
        
        // Create the geometry and its materials
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let image = UIImage(named: "ice")
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = image
        floorMaterial.isDoubleSided = true
        plane.materials = [floorMaterial]
        // Create a plane node with the plane geometry
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = pos
//            SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        // SCNPlanes are vertically oriented in their local coordinate space.
        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        if wolfNode == nil {
            let wolfScene = SCNScene(named: "art.scnassets/wolf.dae")!
            wolfNode = wolfScene.rootNode.childNode(withName: "wolf", recursively: true)
            wolfNode?.position = pos
            
            if let particles = SCNParticleSystem.init(named: "Snow", inDirectory: nil) {
                wolfNode.addParticleSystem(particles)
            }
            sceneView.scene.rootNode.addChildNode(wolfNode!)
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
        node.enumerateChildNodes {
            (childNode, _) in
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
    
    // MARK: - Shutter Button
    func setupShutterButton() {
        // create UIWindows for UIButtons and labels
        objectsWindow = UIWindow(frame: self.view.frame)
        objectsWindow.rootViewController = HiddenStatusBarVC()
        objectsWindow.makeKeyAndVisible()
        
        // record indicator label
        recordIndicator = UILabel.init(frame: CGRect(x: self.view.frame.width / 2 - 60, y: 20, width: 120, height: 30))
        recordIndicator.backgroundColor = .clear
        recordIndicator.textColor = .red
        recordIndicator.textAlignment = .center
        objectsWindow.addSubview(recordIndicator)
        
        shutterButton = UIButton(type: .system)
        shutterButton.frame = CGRect(x: self.view.frame.width / 2 - 24, y: self.view.frame.height - 88, width: 48, height: 48)
        shutterButton.setImage(UIImage(named: "shutter"), for: .normal)
        shutterButton.addTarget(self, action: #selector(ViewController.shotAction(_:)), for: .touchUpInside)
        objectsWindow.rootViewController?.view.addSubview(shutterButton)
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.recordingVideo(_:)))
        longPressGesture.minimumPressDuration = 0.2
        longPressGesture.allowableMovement = 200
        shutterButton.addGestureRecognizer(longPressGesture)
        longPressGesture.delegate = self
    }
    
    
    
    
    
    // MARK: - Screenshot
    @objc func shotAction(_ sender: Any) {
        guard shutterButton.isEnabled else {
            return
        }
        
        let takeScreenshotBlock = {
            
            UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
            DispatchQueue.main.async {
                // briefly flash the screen
                let flashOverlay = UIView(frame: self.sceneView.frame)
                flashOverlay.backgroundColor = UIColor.white
                self.sceneView.addSubview(flashOverlay)
                UIView.animate(withDuration: 0.25, animations: {
                    flashOverlay.alpha = 0.0
                }, completion: { _ in
                    flashOverlay.removeFromSuperview()
                })
            }
        }
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            takeScreenshotBlock()
        case .restricted, .denied:
            let alertController = UIAlertController(title: "Photo access denied", message: "Please enable Photos Library access for this appliction in Settings > Privacy.", preferredStyle: UIAlertControllerStyle.alert)
            let actionOK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(actionOK)
            present(alertController, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    takeScreenshotBlock()
                }
            })
        }
    }
    
    
    // MARK: - Record with PlayKit
    @objc
    func recordingVideo(_ gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.began {
            print("Gesture.state: began ", gesture.state.rawValue)
            self.shutterButton.setImage(UIImage(named: "shutterPressed"), for: .normal)
            
            if RPScreenRecorder.shared().isAvailable {
                print("RPScreenRecorder.shared().isAvailable")
                RPScreenRecorder.shared().isMicrophoneEnabled = true
                RPScreenRecorder.shared().startRecording(handler: { (error: Error?) in
                    
                    if error != nil {
                        print("Error with RPScreenRecorder.")
                    } else {
                        if gesture.state == UIGestureRecognizerState.began {
                            DispatchQueue.main.async {
                                self.recordIndicator.text = "Recording..."
                            }
                            print("Begin recording")
                        }
                    }
                })
            }
        }
        if gesture.state == UIGestureRecognizerState.ended{
            print("Gesture.state: ended ", gesture.state.rawValue)
            self.recordIndicator.text = ""
            self.shutterButton.setImage(UIImage(named: "shutter"), for: .normal)
            if RPScreenRecorder.shared().isRecording {
                RPScreenRecorder.shared().stopRecording { (previewController: RPPreviewViewController?, error: Error?) in
                    print("RPScreenRecorder.shared().stopRecording")
                    if previewController != nil, error == nil {
                        let alertController = UIAlertController(title: "Recoring", message: "Do you wish to discard or view your recording?", preferredStyle: .alert)
                        let discardAction = UIAlertAction(title: "Discard", style: .destructive, handler: { (action: UIAlertAction) in
                            // Executed once recording has sucssfully been discarded
                        })
                        
                        let viewAction = UIAlertAction(title: "View", style: .default, handler: { (action: UIAlertAction) in
                            previewController?.previewControllerDelegate = self
                            self.objectsWindow?.rootViewController?.present(previewController!, animated: true, completion: nil)
                            
                        })
                        
                        alertController.addAction(discardAction)
                        alertController.addAction(viewAction)
                        self.objectsWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
    
}
