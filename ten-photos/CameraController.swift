//
//  CameraController.swift
//  ten-photos
//
//  Created by Mark Norgren on 3/31/17.
//  Copyright © 2017 Marked Systems. All rights reserved.
//

import AVFoundation
import UIKit

let CameraControllerDidStartSession = "CameraControllerDidStartSession"
let CameraControllerDidStopSession = "CameraControllerDidStopSession"

class CameraController: NSObject {
    fileprivate var currentCameraDevice:AVCaptureDevice?

    fileprivate var sessionQueue:DispatchQueue = DispatchQueue(label: "com.markedsystems.session_access_queue",
                                                               attributes: [])

    fileprivate var session:AVCaptureSession!
    fileprivate var backCameraDevice:AVCaptureDevice?
    fileprivate var frontCameraDevice:AVCaptureDevice?
    fileprivate var stillCameraOutput:AVCaptureStillImageOutput!

    // MARK: - Initialization

    required override init() {
        super.init()

        initializeSession()
    }

    func initializeSession() {

        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto

        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)

        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                                          completionHandler: { (granted:Bool) -> Void in
                                            if granted {
                                                self.configureSession()
                                            }
                                            else {
                                                self.showAccessDeniedMessage()
                                            }
            })
        case .authorized:
            configureSession()
        case .denied, .restricted:
            showAccessDeniedMessage()
        }
    }

    func configureSession() {
        configureDeviceInput()
        configureStillImageCameraOutput()
        /*
         if previewType == .manual {
         configureVideoOutput()
         }*/
    }

    func configureStillImageCameraOutput() {
        performConfiguration { () -> Void in
            self.stillCameraOutput = AVCaptureStillImageOutput()
            self.stillCameraOutput.outputSettings = [
                AVVideoCodecKey  : AVVideoCodecJPEG,
                AVVideoQualityKey: 0.9
            ]

            if self.session.canAddOutput(self.stillCameraOutput) {
                self.session.addOutput(self.stillCameraOutput)
            }
        }
    }

    func configureDeviceInput() {

        performConfiguration {
            let availableCameraDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            for device in availableCameraDevices as! [AVCaptureDevice] {
                if device.position == .back {
                    self.backCameraDevice = device
                }
                else if device.position == .front {
                    self.frontCameraDevice = device
                }
            }

            // Set the front camera as the initial device
            self.currentCameraDevice = self.frontCameraDevice

            if let frontCameraInput = try? AVCaptureDeviceInput(device: self.frontCameraDevice) {
                if self.session.canAddInput(frontCameraInput) {
                    self.session.addInput(frontCameraInput)
                }
            }
        }
    }

    func showAccessDeniedMessage() {

    }

    func performConfiguration(_ block: @escaping (() -> Void)) {
        sessionQueue.async { () -> Void in
            block()
        }
    }

    // MARK: - Camera Control

    func startRunning() {
        performConfiguration { () -> Void in
            self.session.startRunning()
            NotificationCenter.default.post(name: Notification.Name(rawValue: CameraControllerDidStartSession), object: self)
        }
    }

    // MARK: Still image capture
    func captureStillImage(completionHandler handler:@escaping ((_ image:UIImage, _ metadata:NSDictionary) -> Void)) {
        captureSingleStillImage(completionHandler:handler)
    }

    /*!
     Capture a photo

     :param: handler executed on the main queue
     */
    func captureSingleStillImage(completionHandler handler: @escaping ((_ image:UIImage, _ metadata:NSDictionary) -> Void)) {
        sessionQueue.async { () -> Void in

            let connection = self.stillCameraOutput.connection(withMediaType: AVMediaTypeVideo)

            connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!

            self.stillCameraOutput.captureStillImageAsynchronously(from: connection) {
                (imageDataSampleBuffer, error) -> Void in

                if error == nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)


                    let metadata: NSDictionary = CMCopyDictionaryOfAttachments(nil, imageDataSampleBuffer!, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))!

                    if let image = UIImage(data: imageData!) {
                        DispatchQueue.main.async { () -> Void in
                            handler(image, metadata)
                        }
                    }
                }
                else {
                    NSLog("error while capturing still image: \(String(describing: error))")
                }
            }
        }
    }
}
