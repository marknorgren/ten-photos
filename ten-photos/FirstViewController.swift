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

    fileprivate var fileWriteQueue:DispatchQueue = DispatchQueue(label: "com.markedsystems.file_write_queue",
                                                               attributes: [])

    @IBAction func handleShutterButton(_ sender: UIButton) {

        print("start")
        for i in 1...10 {
            print("taking \(i) photo")
            cameraController.captureStillImage { [weak self] (image, metadata) -> Void in
                self?.view.layer.contents = image
                self?.fileWriteQueue.async { [weak self] in
                    self?.saveImageToDisk(image: image)
                    print("wrote \(i) photo")
                }
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
        print("done")
    }


    func saveImageToDisk(image: UIImage) {
        // Create path.
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "y.MM.dd'T'H.m.ss.SSS"
        let dateString = df.string(from: date)

        // Save image.
        do {
            let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(dateString).jpg")
            try UIImageJPEGRepresentation(image, 1)?.write(to: fileURL, options: .atomic)
        } catch {
            fatalError(error.localizedDescription)
        }

    }

    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        guard error == nil else {
            //Error saving image
            return
        }
        //Image saved successfully
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

