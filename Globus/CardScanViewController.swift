//
//  CardScanViewController.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/12/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit
import AVFoundation

class CardScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var qrCodeRegister = ""
    
    @IBOutlet weak var previewView: UIView!
    
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code,
                             AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code,
                             AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code,
                             AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureQRScaner()
    }
    
    func configureQRScaner() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            addPreview()
            // Start video capture
            captureSession?.startRunning()
            addHighlightFrame()
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    func addPreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(videoPreviewLayer!)
    }
    
    func addHighlightFrame() {
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.black.cgColor
            qrCodeFrameView.layer.borderWidth = 4
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        configurePreview()
    }

    func configurePreview() {
        let previewFrame = CGRect(x: 0, y: 0, width: previewView.frame.size.width, height: previewView.frame.size.height)
        videoPreviewLayer?.frame = previewFrame
    }

    // Mark: - AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!,
                       from connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
           print("No Code detected")
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedBarCodes.contains(metadataObj.type) {
                    if metadataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            guard
                let qrCodeString = metadataObj.stringValue
                else {
                    return
            }
                captureSession?.stopRunning()
                print("Your code : \(qrCodeString)")
                qrCodeRegister = qrCodeString
                self.performSegue(withIdentifier: "RegistrationSegue", sender: self)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination:RegistrationViewController = segue.destination as! RegistrationViewController
        destination.qrCodeRegister = qrCodeRegister
    }
    
    // Mark: - Actions
    
    @IBAction func manualEnterTapped(_ sender: UIButton) {
        qrCodeRegister = ""
        performSegue(withIdentifier: "RegistrationSegue", sender: self)
    }
    
}
