//
//  ViewController.swift
//  speed_d8ting
//
//  Created by Nur Iren on 1/25/19.
//  Copyright © 2019 Nur Iren. All rights reserved.
//

import UIKit
import AVFoundation
import TesseractOCR
import NaturalLanguage

class ViewController: UIViewController, G8TesseractDelegate {
    
    
    var captureSession = AVCaptureSession()
    var backCamera:AVCaptureDevice?
    var frontCamera:AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    //@IBOutlet weak var textView: UITextView!
    
    let tokenizer = NLTokenizer(unit: .word)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
         //Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("Recognition progress \(tesseract.progress) %")
    }
    
    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices{
            if device.position == AVCaptureDevice.Position.back{
                backCamera = device
            }
            else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }
    
    func setupInputOutput(){
        do{

            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray((([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])])), completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        }catch{
            print(error)
        }
       
    }
    
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
    
    @IBAction func captureButton(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    

}
extension ViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput( _ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        if let imageData = photo.fileDataRepresentation(){
            print(imageData)
            image = UIImage(data: imageData)
            
            
            if let tesseract = G8Tesseract(language: "eng"){
                tesseract.delegate = self
                tesseract.image = image?.g8_blackAndWhite()
                //tesseract.image = UIImage(named: "test")?.g8_blackAndWhite()
                tesseract.recognize()
                var text: String!
                text = tesseract.recognizedText.unsafelyUnwrapped
                print(tesseract.recognizedText.unsafelyUnwrapped)
                let strRange = text.startIndex ..< text.endIndex
                tokenizer.string = text
                let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
                tagger.string = text
                tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                    print(text[tokenRange])
                    return true
                }
                let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
                let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
                print("_________________________")
                let range = NSRange(location: 0, length: text.utf16.count)
                //let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
                tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
                    if let tag = tag, tags.contains(tag) {
                        let name = (text as NSString).substring(with: tokenRange)
                        print("\(name): \(tag)")
                    }
                }
                
                
                
                print("##############################################")
                //var testString : NSString = "You may call my number at +6016-337-3081, or visit irekasoft.com, irekasoft.com/blog by next monday at San Jose, California on 1 pm"
                //var testString : NSString = text
                var testString = text as NSString
                
                let types : NSTextCheckingResult.CheckingType = [.address , .date, .phoneNumber, .link ]
                let dataDetector = try? NSDataDetector(types: types.rawValue)
                
                dataDetector?.enumerateMatches(in: testString as String, options: [], range: NSMakeRange(0,testString.length), using: { (match, flags, _) in
                    
                    let matchString = testString.substring(with: (match?.range)!)
                    
                    if match?.resultType == .date {
                        
                        print("date: \(matchString)")
                        
                    }else if match?.resultType == .phoneNumber {
                        
                        print("phoneNumber: \(matchString)")
                        
                        
                    }else if match?.resultType == .address {
                        
                        print("address: \(matchString)")
                        
                        
                    }else if match?.resultType == .link {
                        
                        print("link: \(matchString)")
                        
                        
                    }else{
                        print("else \(matchString)")
                    }
                    
                })
            }
        }
    }
}
