//
//  GameViewController.swift
//  VoronoiVisualizer
//
//  Created by Fredrik Sjöberg on 15/02/16.
//  Copyright (c) 2016 FredrikSjoberg. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    @IBOutlet var skView: SKView!
    @IBAction func resetAction(sender: AnyObject) {
        scene.resetPoints()
    }
    
    @IBOutlet weak var selectButton: UISegmentedControl!
    
    @IBOutlet weak var slider: UISlider!
    @IBAction func scaleSlider(sender: UISlider) {
        scene.updateMinScale(sender.value)
    }
    
    @IBAction func selectAction(sender: AnyObject) {
        if selectButton.selectedSegmentIndex == 0 {
            scene.setSelectMode(.Site)
        }
        
        if selectButton.selectedSegmentIndex == 1 {
            scene.setSelectMode(.Cell)
        }
    }
    
    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        print(skView.bounds.size)
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        skView.presentScene(scene)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}