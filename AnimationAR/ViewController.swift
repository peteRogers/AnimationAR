//
//  ViewController.swift
//  AnimationAR
//
//  Created by Peter Rogers on 17/03/2021.
//


import UIKit
import RealityKit
import Combine

//start of our ViewController class
class ViewController: UIViewController {
    //array to hold subscriber events
    var subscribes: [Cancellable] = []
    // the link to ARView that is in storyboard
    @IBOutlet var arView: ARView!
    //Your reality Composer file
    var deptford:Deptford.Scene!
   
    override func viewDidLoad() {
        //no ideaa
        super.viewDidLoad()
        //add our rcFile to the arView
        deptford = try! Deptford.loadScene()
        //create listener for the click from the 'ball bearing'
        deptford.actions.deptfordClick.onAction = {entity in
            //do stuff when clicked
            //self.performSegue(withIdentifier: "ball", sender: nil)
            self.makeBird()
          
        }
        // set the arView scene anchor to our rcFile
        
        arView.scene.anchors.append(deptford)
        //make a bird!
        makeBird()
    }
    
    func makeBird(){
        //get 3D model from file
        let entity = try? Entity.load(named: "White_Eagle_Fly")
        //load to current scene
        deptford.addChild(entity!)
        //resize model
        entity!.transform.scale *= 0.1
        //play the models animation in a continuous loop
        entity?.playAnimation((entity?.availableAnimations[0].repeat())!)
        //make a transform to translate models position over time
        var translationTransform = entity?.transform
        //set the translate position x, y, z
        translationTransform?.translation = SIMD3<Float>(x: 10, y: 0, z: 0)
        //create an animation movement to tween from current position to new transform position over given duration
        entity!.move(to: translationTransform!, relativeTo: entity?.parent, duration: 20, timingFunction: .easeInOut)
        //create a subscriber event that will detect when move animation is complete
        // this then resets the position back to first position and does the move animation again - creating a loop
        //this is the really clever bit using subscribe (combine framework)
        subscribes.append(arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self,on: entity){ event in
            //when animation completes it resets position
            entity?.setPosition(SIMD3<Float>(x: 0, y: 0, z: 0), relativeTo: entity?.parent)
            //reuses the transform animation to create new animation keeping the subscribe event (very clever)
            entity!.move(to: translationTransform!, relativeTo: entity?.parent, duration: 20, timingFunction: .easeInOut)
            
        })
        
    }
}
//End ViewController Class

