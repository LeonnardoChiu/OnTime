//
//  SettingViewController.swift
//  OnTime
//
//  Created by Leonnardo Benjamin Hutama on 19/09/19.
//  Copyright © 2019 Leonnardo Benjamin Hutama. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtWakeUpTime: UITextField!
    @IBOutlet weak var txtGoToWorkTime: UITextField!
    @IBOutlet weak var txtClockOutTime: UITextField!
    @IBOutlet weak var switchReminder: UISwitch!
    
    private var datePicker: UIDatePicker?
    
    var txtWakeUpClicked = false
    var txtGoToWorkClicked = false
    var txtClockOutClicked = false
    
    var name = ""
    var wakeUpHour = 0
    var wakeUpMin = 0
    var leaveHour = 0
    var leaveMin = 0
    var clockOutHour = 0
    var clockOutMin = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        initTextField()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .time
        
        txtWakeUpTime.inputView = datePicker
        txtGoToWorkTime.inputView = datePicker
        txtClockOutTime.inputView = datePicker
        
        datePicker?.addTarget(self, action: #selector(SettingViewController.dateChanged(datePicker: )), for: .valueChanged)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
        txtWakeUpClicked = false
        txtGoToWorkClicked = false
        txtClockOutClicked = false
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if txtWakeUpClicked == true {
            txtWakeUpTime.text = dateFormatter.string(from: datePicker.date)
            let components = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)
            wakeUpHour = components.hour!
            wakeUpMin = components.minute!

        }
        else if txtGoToWorkClicked == true {
            txtGoToWorkTime.text = dateFormatter.string(from: datePicker.date)
            let components = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)
            leaveHour = components.hour!
            leaveMin = components.minute!
        }
        else if txtClockOutClicked == true {
            txtClockOutTime.text = dateFormatter.string(from: datePicker.date)
            let components = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)
            clockOutHour = components.hour!
            clockOutMin = components.minute!
        }
        
    }

    @IBAction func txtWakeUpEdited(_ sender: Any) {
        txtWakeUpClicked = true
        txtGoToWorkClicked = false
        txtClockOutClicked = false
    }
    
    @IBAction func txtGoToWorkEdited(_ sender: Any) {
        txtGoToWorkClicked = true
        txtWakeUpClicked = false
        txtClockOutClicked = false
    }
    
    @IBAction func txtClockOutEdited(_ sender: Any) {
        txtClockOutClicked = true
        txtWakeUpClicked = false
        txtGoToWorkClicked = false
    }
    
//    @IBAction func cancelClicked(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//        
//        dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func doneClicked(_ sender: Any) {
        saveData()
        let firstController = ViewController()
        firstController.loadData()
        firstController.showNotificationAtTime(Title: "Go to Work", body: "It's already \(leaveHour):\(leaveMin). Time to go to work now. Have a safe Trip!", hour: leaveHour, minute: leaveMin, identifier: "Go to Work")
        firstController.showNotificationAtTime(Title: "Clock Out", body: "It's already \(clockOutHour):\(clockOutMin). Don't forget to Clock Out before leaving the Academy!", hour: clockOutHour, minute: clockOutMin, identifier: "Clock Out")
        firstController.showNotificationAtTime(Title: "Wake Up", body: "It's already \(wakeUpHour):\(wakeUpMin). Time to wake up! Click me to turn off alarm.", hour: wakeUpHour, minute: wakeUpMin, identifier: "Wake Up")
        
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchClicked(_ sender: Any) {
        if switchReminder.isOn{
            
        }
        else{
            
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
        
    }
    
    func saveData(){
        UserDefaults.standard.set(txtName.text, forKey: "Name")
        UserDefaults.standard.set(wakeUpHour, forKey: "WakeUpHour")
        UserDefaults.standard.set(wakeUpMin, forKey: "WakeUpMin")
        UserDefaults.standard.set(leaveHour, forKey: "LeaveHour")
        UserDefaults.standard.set(leaveMin, forKey: "LeaveMin")
        UserDefaults.standard.set(clockOutHour, forKey: "ClockOutHour")
        UserDefaults.standard.set(clockOutMin, forKey: "ClockOutMin")
        
    }
    
    func initTextField(){
        
        txtName.text = name
        
        if wakeUpHour < 10 && wakeUpMin < 10 {
            txtWakeUpTime.text = "0\(wakeUpHour):0\(wakeUpMin)"
        }
        else if wakeUpHour < 10 {
            txtWakeUpTime.text = "0\(wakeUpHour):\(wakeUpMin)"
        }
        else if wakeUpMin < 10 {
            txtWakeUpTime.text = "\(wakeUpHour):0\(wakeUpMin)"
        }
        else{
            txtWakeUpTime.text = "\(wakeUpHour):\(wakeUpMin)"
        }
        
        if leaveHour < 10 && leaveMin < 10 {
            txtGoToWorkTime.text = "0\(leaveHour):0\(leaveMin)"
        }
        else if leaveHour < 10 {
            txtGoToWorkTime.text = "0\(leaveHour):\(leaveMin)"
        }
        else if leaveMin < 10 {
            txtGoToWorkTime.text = "\(leaveHour):0\(leaveMin)"
        }
        else{
            txtGoToWorkTime.text = "\(leaveHour):\(leaveMin)"
        }
        
        if clockOutHour < 10 && clockOutMin < 10 {
            txtClockOutTime.text = "0\(clockOutHour):0\(clockOutMin)"
        }
        else if clockOutHour < 10 {
            txtClockOutTime.text = "0\(clockOutHour):\(clockOutMin)"
        }
        else if clockOutMin < 10 {
            txtClockOutTime.text = "\(clockOutHour):0\(clockOutMin)"
        }
        else{
            txtClockOutTime.text = "\(clockOutHour):\(clockOutMin)"
        }
    }
    
}
