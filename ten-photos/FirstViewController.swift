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

    let df = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        df.dateFormat = "y.MM.dd'T'H.m.ss.SSS"
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
        let date = Date()

        let dateString = df.string(from: date)

        // Save image.
        do {
            let fileURL = try FileManager.default.url(for: .documentDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil,
                                                      create: false).appendingPathComponent("\(dateString).jpg")
            guard let imageJPEG = UIImageJPEGRepresentation(image, 1) else {
                fatalError("Could not create JPEG")
            }
            // Saves image data to documents folder, in-secure
            // try imageJPEG.write(to: fileURL, options: .atomic)
            DispatchQueue.main.async {
                // Saves image data to keychain secure
                let result = KeyChain.save(key: dateString, data: imageJPEG)
                print("Saved: \(dateString) -> Keychain save result: \(result)")
            }
        } catch {
            fatalError(error.localizedDescription)
        }

    }

}

