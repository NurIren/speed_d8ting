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
    
    @IBAction func nextButton(_ sender: Any) {
        performSegue(withIdentifier: "toSummary", sender: self);
        print("now here")
    }
    
    var captureSession = AVCaptureSession()
    var backCamera:AVCaptureDevice?
    var frontCamera:AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    //@IBOutlet weak var textView: UITextView!
    var dates = [String]()
    var location : String!
    var website: String!
    var eventName: String!
    var monthStuff = [String]()
    var timeStuff = [String]()
    
    
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
        print("here")
        //let newViewController = DatingViewController()
        //self.navigationController?.pushViewController(newViewController, animated: true)
        //sleep(30)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondView = segue.destination as! DatingViewController
        secondView.location = location
        secondView.eventName = eventName
        secondView.website = website
        //____________________________
        monthStuff = toMonthDay(stringIn: dates[0])
        if(monthStuff.count == 0){
            secondView.monthNum = ""
            secondView.day = ""
        }else if(monthStuff.count == 1){
            secondView.monthNum = ""
            secondView.day = ""
        }else if(monthStuff.count == 2){
            secondView.monthNum = monthStuff[0]
            secondView.day = monthStuff[1]
        }else{
            secondView.monthNum = monthStuff[0]
            secondView.day = monthStuff[1]
        }
        
        timeStuff = toProperTime(str1: dates[1])
        if(timeStuff.count == 0){
            secondView.hour = "00"
            secondView.minute = "00"
            secondView.endHour = "00"
            secondView.endMinute = "00"
        } else {
            secondView.hour = timeStuff[0]
            secondView.minute = timeStuff[1]
            secondView.endHour = timeStuff[2]
            secondView.endMinute = timeStuff[3]
        }
    
        //_______________________________
        
    }
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("nothing")
            return []
        }
    }
    func toProperTime(str1: String) -> [String]{
        var result = [String]()
        let matched = matches(for: "(\\d)?\\d(:\\d{2})?(A|a|p|P)(M|m)", in: str1 )
        var tempHour = 0
        
        for m in matched{
            var num = m.count
            var test = m
            var newNum = 0
            var mTime = false
            var tempMin = "00"
            
            if(m.contains(":")){
                if m.count == 7 {
                    //it's 10,11,or 12 PM
                    var i = m.index(m.startIndex, offsetBy: num-6)
                    tempHour = Int(String(m[i]))! + 10
                    tempMin = String(m.dropFirst(3))
                }
                else{
                    var i = m.index(m.startIndex, offsetBy: num-6)
                    tempHour = Int(String(m[i]))!
                    tempMin = String(m.dropFirst(2))
                }
                
                tempMin = String(tempMin.dropLast(2))
                
            }
            else{
                if m.count == 4{
                    var i = m.index(m.startIndex, offsetBy: num-3)
                    tempHour = Int(String(m[i]))! + 10
                }
                else{
                    var i = m.index(m.startIndex, offsetBy: num-3)
                    tempHour = Int(String(m[i]))!
                }
            }
            let index = m.index(m.startIndex, offsetBy: num-2)
            //doesn't work for NOON!!!
            
            if (String(m[index]).uppercased() == "P") {
                tempHour = tempHour + 12
            }
            var finalHour = String(tempHour)
            
            result.append(finalHour)
            result.append(tempMin)
            
        }
        
        if(result.count == 2){
            result.append(String(tempHour + 2))
            result.append("00")
        }
        return result
    }
    func toMonthDay(stringIn: String) -> [String] {
        var charset = CharacterSet.letters
        var month = ""
        var day = ""
        var year = "2019"
        if stringIn.lowercased().rangeOfCharacter(from: charset) != nil {
            var mdy = stringIn.split(separator: " ")
            var string: String = String(mdy[0]).lowercased()
            day = String(mdy[1])
            day = day.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if day.count < 2 {
                day = "0" + day
            }
            if(string.contains("jan")){
                month = "01"
            }
            else if(string.contains("feb")){
                month = "02"
            }
            else if(string.contains("mar")){
                month = "03"
            }
            else if(string.contains("apr")){
                month = "04"
            }
            else if(string.contains("may")){
                month = "05"
            }
            else if(string.contains("jun")){
                month = "06"
            }
            else if(string.contains("jul")){
                month = "07"
            }
            else if(string.contains("aug")){
                month = "08"
            }
            else if(string.contains("sep")){
                month = "09"
            }
            else if(string.contains("oct")){
                month = "10"
            }
            else if(string.contains("nov")){
                month = "11"
            }
            else if(string.contains("dec")){
                month = "12"
            }
        }
        else {
            var mdy = stringIn.split(separator: "/")
            month = String(mdy[0])
            day = String(mdy[1])
            
            if mdy.count > 2 {
                year = String(mdy[2])
            }
            if year.count < 3 {
                year = "20" + year
            }
            if month.count < 2 {
                month = "0" + month
            }
            if day.count < 2 {
                day = "0" + day
            }
        }
        var date = [month, day, year]
        return date
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
                var count = 0
                tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                    if( count == 0){
                        eventName = String(text[tokenRange])
                    }else if(count == 1){
                        eventName = eventName + " " + String(text[tokenRange])
                    }
                    print(text[tokenRange])
                    count += 1
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
                        dates.append(matchString)
                        
                    }else if match?.resultType == .phoneNumber {
                        
                        print("phoneNumber: \(matchString)")
                        
                        
                    }else if match?.resultType == .address {
                        
                        print("address: \(matchString)")
                        location = matchString
                        
                        
                    }else if match?.resultType == .link {
                        
                        print("link: \(matchString)")
                        website = matchString
                        
                        
                    }else{
                        print("else \(matchString)")
                    }
                    
                })
            }
        }
        
    }
}
extension StringProtocol {
    
    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
    
    subscript(_ range: CountableRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: CountableClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}
extension Substring {
    var string: String { return String(self) }
}
