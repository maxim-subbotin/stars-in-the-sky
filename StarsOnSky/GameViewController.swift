//
//  GameViewController.swift
//  StarsOnSky
//
//  Created by Max Subbotin on 1/7/20.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    private var sgmHemisperes = UISegmentedControl(items: ["North", "South"])
    private var skyScene: SkyScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            skyScene = SkyScene(size: view.bounds.size)
            skyScene?.scaleMode = .aspectFill
            view.presentScene(skyScene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        self.view.addSubview(sgmHemisperes)
        sgmHemisperes.addTarget(self, action: #selector(onSegmentControl), for: .valueChanged)
        sgmHemisperes.selectedSegmentIndex = 0
        sgmHemisperes.tintColor = .white
        sgmHemisperes.translatesAutoresizingMaskIntoConstraints = false
        let cxC = sgmHemisperes.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let wC = sgmHemisperes.widthAnchor.constraint(equalToConstant: 260)
        let hC = sgmHemisperes.heightAnchor.constraint(equalToConstant: 40)
        let tC = sgmHemisperes.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20)
        NSLayoutConstraint.activate([cxC, wC, hC, tC])
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func onSegmentControl() {
        if sgmHemisperes.selectedSegmentIndex == 0 {
            skyScene?.hemisphere = .north
        }
        if sgmHemisperes.selectedSegmentIndex == 1 {
            skyScene?.hemisphere = .south
        }
    }
}
