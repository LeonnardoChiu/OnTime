//
//  ViewController.swift
//  OnTime
//
//  Created by Leonnardo Benjamin Hutama on 17/09/19.
//  Copyright © 2019 Leonnardo Benjamin Hutama. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import AVFoundation
import LocalAuthentication

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var lblGreeting: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnAlarm: UIButton!
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var model: UserModel?
    
    let formatter = DateFormatter()
    var timeChanger: Timer?
    
    var alarmAudioPlayer = AVAudioPlayer()
    
    let locationManager:CLLocationManager = CLLocationManager()
    var latitudeValueWork:Double = -6.301923
    var longitudeValueWork:Double = 106.652541
    
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    
    var name = "Leon"
    var wakeUpHour = 7
    var wakeUpMin = 0
    var leaveHour = 8
    var leaveMin = 0
    var clockOutHour = 13
    var clockOutMin = 0
    
    var currentAlarmHour = 0
    var currentAlarmMinute = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentAlarmHour = 0
        currentAlarmMinute = 0
        
        if UserDefaults.standard.string(forKey: "Name") != nil{
            loadData()
            
        }
        else{
            model = UserModel(name: name, wakeUpHour: wakeUpHour, wakeUpMin: wakeUpMin, leaveHour: leaveHour, leaveMin: leaveMin, clockOutHour: clockOutHour, clockOutMin: clockOutMin)
            UserDefaults.standard.set(model?.name, forKey: "Name")
            UserDefaults.standard.set(model?.wakeUpHour, forKey: "WakeUpHour")
            UserDefaults.standard.set(model?.wakeUpMin, forKey: "WakeUpMin")
            UserDefaults.standard.set(model?.leaveHour, forKey: "LeaveHour")
            UserDefaults.standard.set(model?.leaveMin, forKey: "LeaveMin")
            UserDefaults.standard.set(model?.clockOutHour, forKey: "ClockOutHour")
            UserDefaults.standard.set(model?.clockOutMin, forKey: "ClockOutMin")
        }
        
        //Update Time every 1 sec
        timeChanger = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        
        //location allow request
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        //geofence for Apple Developer Academy
        let geoFenceWorkRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(latitudeValueWork, longitudeValueWork), radius: 50, identifier: "GOP 9")
        locationManager.startMonitoring(for: geoFenceWorkRegion)
        
        //notification
        showNotificationAtTime(Title: "Go to Work", body: "It's already \(model!.leaveHour):\(model!.leaveMin). Time to go to work now. Have a safe Trip!", hour: model!.leaveHour, minute: model!.leaveMin, identifier: "Go to Work")
        showNotificationAtTime(Title: "Clock Out", body: "It's already \(model!.clockOutHour):\(model!.clockOutMin). Don't forget to Clock Out before leaving the Academy!", hour: model!.clockOutHour, minute: model!.clockOutMin, identifier: "Clock Out")
        showNotificationAtTime(Title: "Wake Up", body: "It's already \(model!.wakeUpHour):\(model!.wakeUpMin). Time to wake up! Click me to turn off alarm.", hour: model!.wakeUpHour, minute: model!.wakeUpMin, identifier: "Wake Up")
        
        //TRY AUDIO PLAYER
        do{
            alarmAudioPlayer = initializePlayer()!
            alarmAudioPlayer.numberOfLoops = 5
//            turnAlarm(hour: model!.wakeUpHour, minute: model!.wakeUpMin)
            do{
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
            }
        }
        catch{
            print(error)
        }
        
        currentAlarmHour = wakeUpHour
        currentAlarmMinute = wakeUpMin
        
        if alarmAudioPlayer.isPlaying {
            btnAlarm.isHidden = false
        }
        else{
            btnAlarm.isHidden = true
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
        lblUserName.text = name
        
        //DATE and TIME
        updateTime()
        formatter.dateFormat = "EEEE, dd MMMM yyyy"
        let currDate = formatter.string(from: Date())
        lblDate.text = currDate
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        if currentHour >= 6 && currentHour < 12 {
            lblGreeting.text = "Good Morning,"
            self.view.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.6549019608, blue: 0.3058823529, alpha: 1)
        }
        else if currentHour >= 12 && currentHour < 17 {
            lblGreeting.text = "Good Afternoon,"
            self.view.backgroundColor = #colorLiteral(red: 0.768627451, green: 0.2784313725, blue: 0.1176470588, alpha: 1)
        }
        else if currentHour >= 17 && currentHour < 20 {
            lblGreeting.text = "Good Evening,"
            self.view.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.3254901961, blue: 0.2549019608, alpha: 1)
        }
        else{
            lblGreeting.text = "Good Night,"
            self.view.backgroundColor = #colorLiteral(red: 0.631372549, green: 0.6941176471, blue: 0.8156862745, alpha: 1)
        }
        
        if wakeUpHour != currentAlarmHour || wakeUpMin != currentAlarmMinute {
            currentAlarmHour = wakeUpHour
            currentAlarmMinute = wakeUpMin
            turnAlarm(hour: currentAlarmHour, minute: currentAlarmMinute)
            showNotificationAtTime(Title: "Wake Up", body: "It's already \(model!.wakeUpHour):\(model!.wakeUpMin). Time to wake up! Click me to turn off alarm.", hour: currentAlarmHour, minute: currentAlarmMinute, identifier: "Wake Up")
            print("Masuk")
        }
        
    }
    
    @objc func updateTime() {
        formatter.dateFormat = "HH:mm:ss"
        let currTime = formatter.string(from: Date())
        lblTime.text = currTime
        if alarmAudioPlayer.isPlaying {
            btnAlarm.isHidden = false
        }
        else{
            btnAlarm.isHidden = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations {
            print("\(currentLocation)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("entered \(region.identifier)")
        let currentHour = Calendar.current.component(.hour, from: Date())
        if currentHour > 8 && currentHour < 10 {
            showNotification(Title: "Clock In", body: "Don't forget to Clock In as soon as you arrived at the Academy!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("exited \(region.identifier)")
        let currentHour = Calendar.current.component(.hour, from: Date())
        if currentHour >= clockOutHour {
            showNotification(Title: "Clock Out", body: "Have you Clocked Out?")
        }
    }
    
    func showNotification(Title: String, body: String){
        self.appDelegate?.scheduleNotification(notificationType: Title, body: body)
    }
    
    func showNotificationAtTime(Title: String, body: String, hour: Int, minute: Int, identifier: String){
        self.appDelegate?.scheduleNotificationAtTime(notificationType: Title, body: body, hour: hour, minute: minute, identifier: identifier)
    }
    
    func turnAlarm(hour: Int, minute: Int){
        
        let calendar = Calendar.current
        
        let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
        
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(self.runAlarm), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        print("fired")
        
    }
    
    @objc func runAlarm(){
        alarmAudioPlayer.play()
        print("GOO")
    }
    
    @IBAction func stopAlarmButton(_ sender: Any) {
        //FACE ID
        let context:LAContext = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Message") { (success, error) in
                if success{
                    
                    if self.alarmAudioPlayer.isPlaying {
                        self.alarmAudioPlayer.stop()
                    }
                }
                else{
                    print("error")
                }
            }
        }
    }
    
    func loadData(){
        name = UserDefaults.standard.string(forKey: "Name")!
        wakeUpHour = UserDefaults.standard.integer(forKey: "WakeUpHour")
        wakeUpMin = UserDefaults.standard.integer(forKey: "WakeUpMin")
        leaveHour = UserDefaults.standard.integer(forKey: "LeaveHour")
        leaveMin = UserDefaults.standard.integer(forKey: "LeaveMin")
        clockOutHour = UserDefaults.standard.integer(forKey: "ClockOutHour")
        clockOutMin = UserDefaults.standard.integer(forKey: "ClockOutMin")
        
        model = UserModel(name: name, wakeUpHour: wakeUpHour, wakeUpMin: wakeUpMin, leaveHour: leaveHour, leaveMin: leaveMin, clockOutHour: clockOutHour, clockOutMin: clockOutMin)
    }
    
    private func initializePlayer() -> AVAudioPlayer? {
        guard let alarmAudioPath = Bundle.main.path(forResource: "analog-watch-alarm", ofType: "wav") else {return nil}
        
        return try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: alarmAudioPath))
    }
    
}

extension Date{
    
    func dateAt(hours: Int, minutes: Int) -> Date
    {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        //get the month/day/year componentsfor today's date.
        
        
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        
        //Create an NSDate for the specified time today.
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        
        let newDate = calendar.date(from: date_components)!
        return newDate
    }
}

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}

