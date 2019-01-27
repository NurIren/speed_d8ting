//
//  DatingViewController.swift
//  speed_d8ting
//
//  Created by Nur Iren on 1/25/19.
//  Copyright © 2019 Nur Iren. All rights reserved.
//

import UIKit
import EventKit

class DatingViewController: UIViewController{
    
    @IBOutlet weak var eventBox: UITextField!
    
    @IBOutlet weak var DatBox: UITextField!
    
    @IBOutlet weak var TimeBox: UITextField!
    
    @IBOutlet weak var VenueBox: UITextField!
    var date: String!
    var time: String!
    var location: String!
    var eventName: String!
    var website: String!
    var monthNum: String!
    var day: String!
    var hour: String!
    var endHour: String!
    var minute: String!
    var desc: String!
    var endMinute: String!
    
    @IBOutlet weak var DescTextView: UITextView!

    @IBAction func doneButton(_ sender: Any) {
        //if user presses add event
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event){
        case .authorized:
            insertEvent(store: eventStore)
        case .denied:
            print("Access denied")
        case .notDetermined:
            //3
            eventStore.requestAccess(to: .event, completion: {[weak self] (granted: Bool, error: Error?) -> Void in
                if granted{
                    self!.insertEvent(store: eventStore)
                    
                } else{
                    print("Access denied")
                }
            })
        default:
            print("Case default")
            
        }
        self.performSegue(withIdentifier: "addedToCalendar", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventBox.text = eventName
        DatBox.text = monthNum + "/" + day + "/2019"
        TimeBox.text = hour + ":" + minute + " - " + endHour + ":" + minute
        VenueBox.text = location
        //DescTextView.text = DescTextView
        print("adding to calendar")
        
       
        
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    func insertEvent(store: EKEventStore){
        let calendars = store.calendars(for: .event)
        
        for calendar in calendars{
            if calendar.title == "ioscreator" {
//                var dateComponents = DateComponents()
//                dateComponents.year = 2019
//                dateComponents.month = Int(monthNum)
//                dateComponents.day = Int(day)
//                dateComponents.timeZone = TimeZone(abbreviation: "EST")
//                dateComponents.hour = Int(hour)
//                dateComponents.minute = Int(minute)
                
                //let userCalendar = Calendar.current
                //let someDataTime = userCalendar.date(from: dateComponents)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                print(monthNum)
                print(day)
                print(hour)
                print(minute)
                let someDateTime = formatter.date(from: "2019/" + monthNum + "/" + day + " " + hour + ":" + minute)
                
                let startDate = someDateTime
                //let endDate = startDate.addingTimeInterval(2 * 60 * 60)
                 let someDateTimeEnd = formatter.date(from: "2019/" + monthNum + "/" + day + " " + endHour + ":" + endMinute)
                let endDate = someDateTimeEnd
                
//                var dateComponentsEnd = DateComponents()
//                dateComponents.year = 2019
//                dateComponents.month = Int(monthNum)
//                dateComponents.day = Int(day)
//                dateComponents.timeZone = TimeZone(abbreviation: "EST")
//                dateComponents.hour = Int(endHour)
//                dateComponents.minute = Int(minute)
                
                //let endDate = userCalendar.date(from: dateComponentsEnd)
                
                let event = EKEvent(eventStore: store)
                
                
                event.calendar = calendar
                print(website)
                if(website != nil){
                    do {
                        let url = try NSURL(string: website)
                        try event.url = url as! URL
                    } catch{
                        print("no url found")
                    }
                }
                    do{
                        try event.title = eventName
                    } catch{
                        print("No event name")
                    }
                
                
                
                //event.startDate = someDataTime
                do{
                    try event.startDate = startDate
                    try event.endDate = endDate
                } catch{
                    let startdate = Date()
                    
                    let endDate = startdate.addingTimeInterval(2 * 60 * 60)
                    event.startDate = startdate
                    event.endDate = endDate
                    
                }
                
                do{
                    try event.location = location
                } catch{
                    print("no event location found")
                }
                
                //event.description = desc
                
                
                do{
                    try store.save(event, span: .thisEvent)
                }
                catch{
                    print("Error saving event in calendar")
                }
            }
        }
    }
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


