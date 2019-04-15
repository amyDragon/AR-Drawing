//
//  ViewController.swift
//  AR Drawing
//
//  Created by Swastik Soni on 15/04/2019.
//  Copyright © 2019 amy. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    let sceneView = ARSCNView()
    let configuration = ARWorldTrackingConfiguration()
    
    lazy var drawButton : UIButton = {
        let db = UIButton()
        db.backgroundColor = UIColor.red
        db.setTitle("Draw", for: .normal)
        db.titleLabel?.textColor = .white
        db.addTarget(self, action: #selector(draw), for: .touchUpInside)
        return db
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        sceneView.showsStatistics = true
        sceneView.session.run(configuration)
        sceneView.delegate = self
        setupGUI()
    }

    func setupGUI() {
        view.addSubview(sceneView)
        sceneView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        view.addSubview(drawButton)
        drawButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0), size: CGSize(width: 100, height: 50))
    }
    
    @objc func draw() {
        
    }
    
    func add(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }

}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //get point of view of camera in order to position node
        guard let pointOfView = sceneView.pointOfView else { return }
        //in order to get the orientation and position of the camera, we need to access the transformation matrix embedded in the pointofview
        let transform = pointOfView.transform
        //orientation/rotation/z is the 3rd column of the transformation matrix, transform.m31 = 3rd column row 1 as in x etc
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        //position/location is the 4th column of the t.m
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        //in order to get the view or position in front of the camera "simply" add orientation and location
        let frontViewOfCamera = add(left: orientation, right: location)
        //without the minus signs the orientation appears reversed, as in moving to the right was giving a continuously negative x value while it should have been positive
        print(orientation.x,orientation.y,orientation.z)
        DispatchQueue.main.async {
            if self.drawButton.isHighlighted {
                print("drawing")
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                sphereNode.position = frontViewOfCamera
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
            }
            else {
                //we want to show a pointer so the user knows where they are drawing
                //same as above except we want to delete all the nodes save for the newest one so it shows only a point at all times and not a joint line of nodes that we are using to draw above
                let pointerNode = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointerNode.name = "pointer"
                pointerNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                //to delete previous nodes, basically removing any child nodes inside the root node. the drawing node is also a child hence the name based distinction which should be obvious
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                })
                
                pointerNode.position = frontViewOfCamera
                self.sceneView.scene.rootNode.addChildNode(pointerNode)
            }
        }
    }
}


