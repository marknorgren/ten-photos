//
//  FirstViewController.swift
//  ten-photos
//
//  Created by Mark Norgren on 3/31/17.
//  Copyright © 2017 Marked Systems. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    var cameraController:CameraController!

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraController = CameraController()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraController.startRunning()

    }

    @IBAction func handleShutterButton(_ sender: UIButton) {
        cameraController.captureStillImage { (image, metadata) -> Void in
            self.view.layer.contents = image
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

