//
//  HomeViewController.swift
//  cafoll
//
//  Created by mücahit öztürk on 4.12.2023.
//

import UIKit

class HomeViewController: UIViewController,UITabBarControllerDelegate {
    
    //Header
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateView: UIView!
    //circle
    @IBOutlet weak var circileButton: UIButton!
    @IBOutlet weak var goalTextLAbel: UIStackView!
    @IBOutlet weak var checkMarkMaxValue: UIImageView!
    @IBOutlet weak var stackViewValues: UIStackView!
    @IBOutlet weak var totalCarbon: UILabel!
    @IBOutlet weak var totalFat: UILabel!
    @IBOutlet weak var totalPRotein: UILabel!
    @IBOutlet weak var totalCalori: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var yellowLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var purpleLabel: UILabel!
    @IBOutlet weak var greenV1: UIView!
    @IBOutlet weak var yellowV1: UIView!
    @IBOutlet weak var redV1: UIView!
    @IBOutlet weak var purpleV1: UIView!
    @IBOutlet weak var firstLook: UIView!
    //right of circle
    @IBOutlet weak var markGreen: UIImageView!
    @IBOutlet weak var markYellow: UIImageView!
    @IBOutlet weak var markRed: UIImageView!
    @IBOutlet weak var markPurple: UIImageView!
    @IBOutlet weak var nameOfMeals: UILabel!
    @IBOutlet weak var greenInfoLabel: UILabel!
    @IBOutlet weak var yellowInfoLabel: UILabel!
    @IBOutlet weak var redInfoLabel: UILabel!
    @IBOutlet weak var purpleInfoLabel: UILabel!
    @IBOutlet weak var greenTotal: UILabel!
    @IBOutlet weak var yellowTotal: UILabel!
    @IBOutlet weak var redTotal: UILabel!
    @IBOutlet weak var purpleTotal: UILabel!
    @IBOutlet weak var progressGreen: UIProgressView!
    @IBOutlet weak var progressYellow: UIProgressView!
    @IBOutlet weak var progressRed: UIProgressView!
    @IBOutlet weak var progressPurple: UIProgressView!
    @IBOutlet weak var secondLook: UIView!
    //table view
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var coredata: Coredata!
    var helper: Helper!
    var ui: Ui!
    var settingsViewController: SettingsViewController!
    
    var selectedIndexPath: IndexPath?
    var isInfoVisible = false
    
    let maxPurple = 350
    let maxRed = 30
    let maxYellow = 30
    let maxGreen = 30
    
    var badgeCount: [Int] = [0, 0, 0, 0] {
        didSet {
            updateBadge()
        }
    }
    let indexOSettingsViewController = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startUpSetup()
        rotateLabel(purpleLabel, degrees: 45)
        rotateLabel(redLabel, degrees: -45)
        rotateLabel(yellowLabel, degrees: -45)
        rotateLabel(greenLabel, degrees: 45)
    }
    
    func updateBadge() {
        let totalBadgeCount = badgeCount.reduce(0, +)
        
        if totalBadgeCount > 0 {
            tabBarItem.badgeValue = "\(totalBadgeCount)"
        } else {
            tabBarItem.badgeValue = nil
        }
    }
    
    @IBAction func datePickerSelected(_ sender: UIDatePicker) {
        // 1. Fetch foods for the selected date
        coredata.fetchBreakfast(forDate: sender.date)
        coredata.fetchLunch(forDate: sender.date)
        coredata.fetchDinner(forDate: sender.date)
        coredata.fetchSnack(forDate: sender.date)
        // 2. Update UI based on fetched data
        sumBreakfast(forDate: sender.date)
        sumLunch(forDate: sender.date)
        sumDinner(forDate: sender.date)
        sumSnack(forDate: sender.date)
        // 3. set updated
        updateLabel()
        ui.updateButtonTapped()
        fetchDataAndUpdateUI()
        // 4. Reload table view to reflect changes
        tableView.reloadData()
    }
    
    func rotateLabel(_ label: UILabel, degrees: CGFloat) {
        let radians = degrees * .pi / 180
        label.transform = CGAffineTransform(rotationAngle: -radians)
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is HomeViewController {
            // startup
            coredata.fetchBreakfast(forDate: datePicker.date)
            coredata.fetchLunch(forDate: datePicker.date)
            coredata.fetchDinner(forDate: datePicker.date)
            coredata.fetchSnack(forDate: datePicker.date)
            // 2. Update UI based on fetched data
            sumBreakfast(forDate: datePicker.date) // Assuming this function uses the fetched data
            sumLunch(forDate: datePicker.date)
            sumDinner(forDate: datePicker.date)
            sumSnack(forDate: datePicker.date)
            // 3. set updated
            updateLabel()
            ui.updateButtonTapped()
            fetchDataAndUpdateUI()
            // 4. Reload table view to reflect changes
            tableView.reloadData()
            badgeCount = [0, 0, 0, 0]
        }
    }
    //startup reactions
    func startUpSetup() {
        ///print(coredata?.filePath ?? "Not Found")
        helper = Helper()
        settingsViewController = SettingsViewController()
        ui = Ui()
        setLayers()
        //Fetch items
        coredata = Coredata(homeViewController: self)
        datePicker.maximumDate = Date()
       
        coredata.fetchLunch(forDate: datePicker.date)
        coredata.fetchDinner(forDate: datePicker.date)
        coredata.fetchSnack(forDate: datePicker.date)
        
        fetchDataAndUpdateUI()
        ui.updateButtonTapped()
        updateLabel()
        badgeCount = [0, 0, 0, 0]
        //UI
        ui.uiTools(homeViewController: self)
        firstLook.bringSubviewToFront(stackViewValues)
        firstLook.bringSubviewToFront(circileButton)
        //table View Load
        tabBarController?.delegate = self
        tableView.reloadData()
        
    }
    func getDatePickerDate() -> Date? {
        return datePicker?.date
    }
    //view Shadows
    func setLayers() {
        [redV1, purpleV1, yellowV1, greenV1].forEach { $0.layer.cornerRadius = 5 }
    }
    func fetchDataAndUpdateUI() {
        switch segment.selectedSegmentIndex {
        case 0:
            coredata.fetchBreakfast(forDate: datePicker.date)
            sumBreakfast(forDate: datePicker.date)
            nameOfMeals.text = "Kahvaltı"
        case 1:
            coredata.fetchLunch(forDate: datePicker.date)
            sumLunch(forDate: datePicker.date)
            nameOfMeals.text = "Öğle Y."
        case 2:
            coredata.fetchDinner(forDate: datePicker.date)
            sumDinner(forDate: datePicker.date)
            nameOfMeals.text = "Akşam Y."
        case 3:
            coredata.fetchSnack(forDate: datePicker.date)
            sumSnack(forDate: datePicker.date)
            nameOfMeals.text = "Atıştırma"
        default:
            break
        }
        // Update the table
        tableView.reloadData()
    }
    
    func updateLabel() {
        nameOfMeals.text = "Kahvaltı"
    }
    //segment Button
    @IBAction func segmentButtonPressed(_ sender: UISegmentedControl) {
        let currentSegmentIndex = sender.selectedSegmentIndex
        
        switch currentSegmentIndex {
        case 0:
            tableView.reloadData()
            fetchDataAndUpdateUI()
            ui.updateButtonTapped()
            updateLabel()
            sumBreakfast(forDate: datePicker.date)
            nameOfMeals.text = "Kahvaltı"
            
        case 1:
            tableView.reloadData()
            fetchDataAndUpdateUI()
            ui.updateButtonTapped()
            updateLabel()
            sumLunch(forDate: datePicker.date)
            nameOfMeals.text = "Öğle Y."
            
        case 2:
            tableView.reloadData()
            fetchDataAndUpdateUI()
            ui.updateButtonTapped()
            sumDinner(forDate: datePicker.date)
            nameOfMeals.text = "Akşam Y."
            
        case 3:
            tableView.reloadData()
            fetchDataAndUpdateUI()
            ui.updateButtonTapped()
            sumSnack(forDate: datePicker.date)
            nameOfMeals.text = "Atıştırma"
        default:
            break
        }
        // Update the table
        tableView.reloadData()
    }
    
    func sumBreakfast(forDate date: Date) {
        
        guard let breakfastItems = self.coredata.breakfast else {
            return
        }
        
        // Calculate the sum of values for calories, fat, protein, and carbohydrates for the given date
        var totalCalories: Float = 0.00
        var totalFats: Float = 0.00
        var totalProtein: Float = 0.00
        var totalCarbs: Float = 0.00
        
        for item in breakfastItems {
            // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Float(item.calori ?? "0") ?? 0.00
                totalFats += Float(item.fat ?? "0") ?? 0.00
                totalProtein += Float(item.protein ?? "0") ?? 0.00
                totalCarbs += Float(item.carbon ?? "0") ?? 0.00
            }
        }
        
        if let maxGreen = UserDefaults.standard.value(forKey: "breakfastgreenSliderValue") as? Float,
           let maxYellow = UserDefaults.standard.value(forKey: "breakfastyellowSliderValue") as? Float,
           let maxRed = UserDefaults.standard.value(forKey: "breakfastredSliderValue") as? Float,
           let maxPurple = UserDefaults.standard.value(forKey: "breakfastpurpleSliderValue") as? Float {
            
            updateProgressViews(calories: Float(totalCalories), fat: Float(totalFats), protein: Float(totalProtein), carbs: Float(totalCarbs), maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple))
            
            // Toplam değerleri ekrana yazdır
            purpleInfoLabel.text = String(Int(totalCalories))
            redInfoLabel.text = String(Int(totalProtein))
            yellowInfoLabel.text = String(Int(totalFats))
            greenInfoLabel.text = String(Int(totalCarbs))

            purpleTotal.text = String(Int(maxPurple))
            redTotal.text = String(Int(maxRed))
            yellowTotal.text = String(Int(maxYellow))
            greenTotal.text = String(Int(maxGreen))

            
            updateVisibility(markPurple, value: Float(totalCalories), threshold: maxPurple)
            updateVisibility(markRed, value: Float(totalProtein), threshold: maxRed)
            updateVisibility(markYellow, value: Float(totalFats), threshold: maxYellow)
            updateVisibility(markGreen, value: Float(totalCarbs), threshold: maxGreen)
            
        } else {
            print("Hata: Bir değer nil veya dönüştürülemez.")
            if settingsViewController.progressGreen?.text == nil {
                print("Green is nil")
            }
            if settingsViewController.progressYellow?.text == nil {
                print("Yellow is nil")
            }
            if settingsViewController.progressRed?.text == nil {
                print("Red is nil")
            }
            if settingsViewController.progressPurple?.text == nil {
                print("Purple is nil")
            }
        }
    }
    
    func sumLunch(forDate date: Date) {
        guard let lunchItems = self.coredata.lunch else {
            return
        }
        
        // Calculate the sum of values for calories, fat, protein, and carbohydrates for the given date
        var totalCalories: Float = 0.00
        var totalFats: Float = 0.00
        var totalProtein: Float = 0.00
        var totalCarbs: Float = 0.00
        
        for item in lunchItems {
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Float(item.calori ?? "0") ?? 0.00
                totalFats += Float(item.fat ?? "0") ?? 0.00
                totalProtein += Float(item.protein ?? "0") ?? 0.00
                totalCarbs += Float(item.carbon ?? "0") ?? 0.00
            }
        }
        
        if let maxGreen = UserDefaults.standard.value(forKey: "lunchgreenSliderValue") as? Float,
           let maxYellow = UserDefaults.standard.value(forKey: "lunchyellowSliderValue") as? Float,
           let maxRed = UserDefaults.standard.value(forKey: "lunchredSliderValue") as? Float,
           let maxPurple = UserDefaults.standard.value(forKey: "lunchpurpleSliderValue") as? Float {
            
            updateProgressViews(calories: Float(totalCalories), fat: Float(totalFats), protein: Float(totalProtein), carbs: Float(totalCarbs), maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple))
            
            purpleInfoLabel.text = String(Int(totalCalories))
            redInfoLabel.text = String(Int(totalProtein))
            yellowInfoLabel.text = String(Int(totalFats))
            greenInfoLabel.text = String(Int(totalCarbs))

            purpleTotal.text = String(Int(maxPurple))
            redTotal.text = String(Int(maxRed))
            yellowTotal.text = String(Int(maxYellow))
            greenTotal.text = String(Int(maxGreen))
            
            updateVisibility(markPurple, value: Float(totalCalories), threshold: maxPurple)
            updateVisibility(markRed, value: Float(totalProtein), threshold: maxRed)
            updateVisibility(markYellow, value: Float(totalFats), threshold: maxYellow)
            updateVisibility(markGreen, value: Float(totalCarbs), threshold: maxGreen)
            
        } else {
            print("Hata: Bir değer nil veya dönüştürülemez.")
            if settingsViewController.progressGreen?.text == nil {
                print("sliderValueGreen is nil")
            }
            if settingsViewController.progressYellow?.text == nil {
                print("sliderValueYellow is nil")
            }
            if settingsViewController.progressRed?.text == nil {
                print("sliderValueRed is nil")
            }
            if settingsViewController.progressPurple?.text == nil {
                print("sliderValuePurple is nil")
            }
        }
    }
    
    func sumDinner(forDate date: Date) {
        guard let dinnerItems = self.coredata.dinner else {
            return
        }
        
        // Calculate the sum of values for calories, fat, protein, and carbohydrates for the given date
        var totalCalories: Float = 0.00
        var totalFats: Float = 0.00
        var totalProtein: Float = 0.00
        var totalCarbs: Float = 0.00
        
        for item in dinnerItems {
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Float(item.calori ?? "0") ?? 0.00
                totalFats += Float(item.fat ?? "0") ?? 0.00
                totalProtein += Float(item.protein ?? "0") ?? 0.00
                totalCarbs += Float(item.carbon ?? "0") ?? 0.00
            }
        }
        
        if let maxGreen = UserDefaults.standard.value(forKey: "dinnergreenSliderValue") as? Float,
           let maxYellow = UserDefaults.standard.value(forKey: "dinneryellowSliderValue") as? Float,
           let maxRed = UserDefaults.standard.value(forKey: "dinnerredSliderValue") as? Float,
           let maxPurple = UserDefaults.standard.value(forKey: "dinnerpurpleSliderValue") as? Float {
            
            updateProgressViews(calories: Float(totalCalories), fat: Float(totalFats), protein: Float(totalProtein), carbs: Float(totalCarbs), maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple))
            
            purpleInfoLabel.text = String(Int(totalCalories))
            redInfoLabel.text = String(Int(totalProtein))
            yellowInfoLabel.text = String(Int(totalFats))
            greenInfoLabel.text = String(Int(totalCarbs))

            purpleTotal.text = String(Int(maxPurple))
            redTotal.text = String(Int(maxRed))
            yellowTotal.text = String(Int(maxYellow))
            greenTotal.text = String(Int(maxGreen))
            
            updateVisibility(markPurple, value: Float(totalCalories), threshold: maxPurple)
            updateVisibility(markRed, value: Float(totalProtein), threshold: maxRed)
            updateVisibility(markYellow, value: Float(totalFats), threshold: maxYellow)
            updateVisibility(markGreen, value: Float(totalCarbs), threshold: maxGreen)
            
        } else {
            print("Hata: Bir değer nil veya dönüştürülemez.")
            if settingsViewController.progressGreen?.text == nil {
                print("sliderValueGreen is nil")
            }
            if settingsViewController.progressYellow?.text == nil {
                print("sliderValueYellow is nil")
            }
            if settingsViewController.progressRed?.text == nil {
                print("sliderValueRed is nil")
            }
            if settingsViewController.progressPurple?.text == nil {
                print("sliderValuePurple is nil")
            }
        }
    }
    
    func sumSnack(forDate date: Date) {
        guard let snackItems = self.coredata.snack else {
            return
        }
        // Calculate the sum of values for calories, fat, protein, and carbohydrates for the given date
        var totalCalories: Float = 0.00
        var totalFats: Float = 0.00
        var totalProtein: Float = 0.00
        var totalCarbs: Float = 0.00
        
        for item in snackItems {
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Float(item.calori ?? "0") ?? 0.00
                totalFats += Float(item.fat ?? "0") ?? 0.00
                totalProtein += Float(item.protein ?? "0") ?? 0.00
                totalCarbs += Float(item.carbon ?? "0") ?? 0.00
            }
        }
        
        if let maxGreen = UserDefaults.standard.value(forKey: "snackgreenSliderValue") as? Float,
           let maxYellow = UserDefaults.standard.value(forKey: "snackyellowSliderValue") as? Float,
           let maxRed = UserDefaults.standard.value(forKey: "snackredSliderValue") as? Float,
           let maxPurple = UserDefaults.standard.value(forKey: "snackpurpleSliderValue") as? Float {
            
            updateProgressViews(calories: Float(totalCalories), fat: Float(totalFats), protein: Float(totalProtein), carbs: Float(totalCarbs), maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple))
            
            purpleInfoLabel.text = String(Int(totalCalories))
            redInfoLabel.text = String(Int(totalProtein))
            yellowInfoLabel.text = String(Int(totalFats))
            greenInfoLabel.text = String(Int(totalCarbs))

            purpleTotal.text = String(Int(maxPurple))
            redTotal.text = String(Int(maxRed))
            yellowTotal.text = String(Int(maxYellow))
            greenTotal.text = String(Int(maxGreen))
            
            updateVisibility(markPurple, value: Float(totalCalories), threshold: maxPurple)
            updateVisibility(markRed, value: Float(totalProtein), threshold: maxRed)
            updateVisibility(markYellow, value: Float(totalFats), threshold: maxYellow)
            updateVisibility(markGreen, value: Float(totalCarbs), threshold: maxGreen)
            
        } else {
            print("Hata: Bir değer nil veya dönüştürülemez.")
            if settingsViewController.progressGreen?.text == nil {
                print("sliderValueGreen is nil")
            }
            if settingsViewController.progressYellow?.text == nil {
                print("sliderValueYellow is nil")
            }
            if settingsViewController.progressRed?.text == nil {
                print("sliderValueRed is nil")
            }
            if settingsViewController.progressPurple?.text == nil {
                print("sliderValuePurple is nil")
            }
        }
    }
    
    func updateVisibility(_ mark: UIImageView, value: Float, threshold: Float) {
        mark.isHidden = value < threshold
    }
    
    func updateProgressViews(calories: Float, fat: Float, protein: Float, carbs: Float, maxGreen: Float, maxYellow: Float, maxRed: Float, maxPurple: Float, duration: TimeInterval = 1.0) {
        // Set initial progress to 0.0
        progressPurple.progress = 0
        progressYellow.progress = 0
        progressRed.progress = 0
        progressGreen.progress = 0
        
        // Calculate target progress values
        let targetProgressPurple = min(Float(calories) / maxPurple, 1.0)
        let targetProgressYellow = min(Float(fat) / maxYellow, 1.0)
        let targetProgressRed = min(Float(protein) / maxRed, 1.0)
        let targetProgressGreen = min(Float(carbs) / maxGreen, 1.0)
        
        // Animate progress to target values
        UIView.animate(withDuration: duration) {
            self.progressPurple.setProgress(targetProgressPurple, animated: true)
            self.progressYellow.setProgress(targetProgressYellow, animated: true)
            self.progressRed.setProgress(targetProgressRed, animated: true)
            self.progressGreen.setProgress(targetProgressGreen, animated: true)
        }
        sumMeals(forDate: self.datePicker.date)
    }
    
    func sumMeals(forDate date: Date) {
        
        var totalCalories: Float = 0.00
        var totalFats: Float = 0.00
        var totalProtein: Float = 0.00
        var totalCarbs: Float = 0.00
        guard let breakfastItems = self.coredata.breakfast else {
            return
        }
        
        for item in breakfastItems {
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Float(item.calori ?? "0") ?? 0.00
                totalFats += Float(item.fat ?? "0") ?? 0.00
                totalProtein += Float(item.protein ?? "0") ?? 0.00
                totalCarbs += Float(item.carbon ?? "0") ?? 0.00
            }
        }
        guard let lunchItems = self.coredata.lunch else {
            return
        }
        
        for item in lunchItems {
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Float(item.calori ?? "0") ?? 0.00
                totalFats += Float(item.fat ?? "0") ?? 0.00
                totalProtein += Float(item.protein ?? "0") ?? 0.00
                totalCarbs += Float(item.carbon ?? "0") ?? 0.00
            }
        }
        guard let dinnerItems = self.coredata.dinner else {
            return
        }
        
        for item in dinnerItems {
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Float(item.calori ?? "0") ?? 0.00
                totalFats += Float(item.fat ?? "0") ?? 0.00
                totalProtein += Float(item.protein ?? "0") ?? 0.00
                totalCarbs += Float(item.carbon ?? "0") ?? 0.00
            }
        }
        
        guard let snackItems = self.coredata.snack else {
            return
        }
        for item in snackItems {
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Float(item.calori ?? "0") ?? 0.00
                totalFats += Float(item.fat ?? "0") ?? 0.00
                totalProtein += Float(item.protein ?? "0") ?? 0.00
                totalCarbs += Float(item.carbon ?? "0") ?? 0.00
            }
        }
        
        totalCalori.text = String(format: "%.2f", totalCalories)
        totalPRotein.text = String(format: "%.2f", totalProtein)
        totalFat.text = String(format: "%.2f", totalFats)
        totalCarbon.text = String(format: "%.2f", totalCarbs)
        
        let circleTotalValues = ui.circleTotal()
      
        if Float(totalCalories) >= Float(circleTotalValues.3),
           Float(totalProtein) >= circleTotalValues.2,
           Float(totalFats) >= circleTotalValues.1,
           Float(totalCarbs) >= circleTotalValues.0
        {
         
            checkMarkMaxValue.isHidden = false
            goalTextLAbel.isHidden = true
        } else {
           
            checkMarkMaxValue.isHidden = true
            goalTextLAbel.isHidden = false
        }
    }
    
    @IBAction func rightDate(_ sender: UIButton) {
        var currentDate = datePicker.date
            let today = Date()

            // Check if the selected date is today or in the past
            if currentDate <= today {
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                datePicker.setDate(currentDate, animated: true)
            }
        coredata.fetchBreakfast(forDate: datePicker.date)
        coredata.fetchLunch(forDate: datePicker.date)
        coredata.fetchDinner(forDate: datePicker.date)
        coredata.fetchSnack(forDate: datePicker.date)
        // 2. Update UI based on fetched data
        sumBreakfast(forDate: datePicker.date)
        sumLunch(forDate: datePicker.date)
        sumDinner(forDate: datePicker.date)
        sumSnack(forDate: datePicker.date)
        // 3. set updated
        updateLabel()
        ui.updateButtonTapped()
        fetchDataAndUpdateUI()
        // 4. Reload table view to reflect changes
        tableView.reloadData()
    }

    @IBAction func leftDate(_ sender: UIButton) {
        var currentDate = datePicker.date

            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            datePicker.setDate(currentDate, animated: true)
        
        coredata.fetchBreakfast(forDate: datePicker.date)
        coredata.fetchLunch(forDate: datePicker.date)
        coredata.fetchDinner(forDate: datePicker.date)
        coredata.fetchSnack(forDate: datePicker.date)
        // 2. Update UI based on fetched data
        sumBreakfast(forDate: datePicker.date)
        sumLunch(forDate: datePicker.date)
        sumDinner(forDate: datePicker.date)
        sumSnack(forDate: datePicker.date)
        // 3. set updated
        updateLabel()
        ui.updateButtonTapped()
        fetchDataAndUpdateUI()
        // 4. Reload table view to reflect changes
        tableView.reloadData()
    }
    
    @IBAction func circleButtonShowInfo(_ sender: UIButton) {
        guard let date = datePicker?.date else {
            print("Error: Selected date is nil.")
            return
        }
        if isInfoVisible {
            let currentSegmentIndex = segment.selectedSegmentIndex
            
            switch currentSegmentIndex {
            case 0:
                tableView.reloadData()
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumBreakfast(forDate: datePicker.date)
                nameOfMeals.text = "Kahvaltı"
                
            case 1:
                tableView.reloadData()
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumLunch(forDate: datePicker.date)
                nameOfMeals.text = "Öğle Y."
                
            case 2:
                tableView.reloadData()
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumDinner(forDate: datePicker.date)
                nameOfMeals.text = "Akşam Y."
                
            case 3:
                tableView.reloadData()
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumSnack(forDate: datePicker.date)
                nameOfMeals.text = "Atıştırma"
                
            default:
                break
            }
            tableView.reloadData()
        } else {
            let (greenTotal0, yellowTotal1, redTotal2, purpleTotal3) = ui.circleTotal()
                    
            var totalCalories: Float = 0.00
            var totalFats: Float = 0.00
            var totalProtein: Float = 0.00
            var totalCarbs: Float = 0.00
            guard let breakfastItems = self.coredata.breakfast else {
                return
            }
            
            for item in breakfastItems {
                if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                    totalCalories += Float(item.calori ?? "0") ?? 0.00
                    totalFats += Float(item.fat ?? "0") ?? 0.00
                    totalProtein += Float(item.protein ?? "0") ?? 0.00
                    totalCarbs += Float(item.carbon ?? "0") ?? 0.00
                }
            }
            guard let lunchItems = self.coredata.lunch else {
                return
            }
            
            for item in lunchItems {
                if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                    totalCalories += Float(item.calori ?? "0") ?? 0.00
                    totalFats += Float(item.fat ?? "0") ?? 0.00
                    totalProtein += Float(item.protein ?? "0") ?? 0.00
                    totalCarbs += Float(item.carbon ?? "0") ?? 0.00
                }
            }
            guard let dinnerItems = self.coredata.dinner else {
                return
            }
            
            for item in dinnerItems {
                if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                    totalCalories += Float(item.calori ?? "0") ?? 0.00
                    totalFats += Float(item.fat ?? "0") ?? 0.00
                    totalProtein += Float(item.protein ?? "0") ?? 0.00
                    totalCarbs += Float(item.carbon ?? "0") ?? 0.00
                }
            }
            
            guard let snackItems = self.coredata.snack else {
                return
            }
            for item in snackItems {
                if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                    totalCalories += Float(item.calori ?? "0") ?? 0.00
                    totalFats += Float(item.fat ?? "0") ?? 0.00
                    totalProtein += Float(item.protein ?? "0") ?? 0.00
                    totalCarbs += Float(item.carbon ?? "0") ?? 0.00
                }
            }
            
            nameOfMeals.text = "Günlük Hedef"
            
            purpleInfoLabel.text = String(Int(totalCalories))
            redInfoLabel.text = String(Int(totalProtein))
            yellowInfoLabel.text = String(Int(totalFats))
            greenInfoLabel.text = String(Int(totalCarbs))

            purpleTotal.text = String(Int(purpleTotal3))
            redTotal.text = String(Int(redTotal2))
            yellowTotal.text = String(Int(yellowTotal1))
            greenTotal.text = String(Int(greenTotal0))

            
            totalCalori.text = String(purpleTotal3)
            totalFat.text = String(yellowTotal1)
            totalPRotein.text = String(redTotal2)
            totalCarbon.text = String(greenTotal0)
            
            updateProgressViews(calories: Float(totalCalories), fat: Float(totalFats), protein: Float(totalProtein), carbs: Float(totalCarbs), maxGreen: Float(greenTotal0), maxYellow: Float(yellowTotal1), maxRed: Float(redTotal2), maxPurple: Float(purpleTotal3))
            
            updateVisibility(markPurple, value: Float(totalCalories), threshold: Float(purpleTotal3))
            updateVisibility(markRed, value: Float(totalProtein), threshold: Float(redTotal2))
            updateVisibility(markYellow, value: Float(totalFats), threshold: Float(yellowTotal1))
            updateVisibility(markGreen, value: Float(totalCarbs), threshold: Float(greenTotal0))
           
        }
        // Toggle the state
        isInfoVisible.toggle()
        
    }
}
// MARK: - Home Table View
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segment.selectedSegmentIndex {
        case 0:
            return self.coredata.breakfast?.count ?? 0
        case 1:
            return self.coredata.lunch?.count ?? 0
        case 2:
            return self.coredata.dinner?.count ?? 0
        case 3:
            return self.coredata.snack?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
        let row = indexPath.row
        
        var highestValueColor: UIColor = .clear
        
        switch segment.selectedSegmentIndex {
        case 0:
            if let indexBreakfast = self.coredata.breakfast?[row] {
                cell.titleLabel?.text = indexBreakfast.title?.capitalized
                highestValueColor = determineHighestValueColor(carbons: indexBreakfast.carbon ?? "0", fat: indexBreakfast.fat ?? "0", protein: indexBreakfast.protein ?? "0")
                cell.homeVC = self
                if let calories = Float(indexBreakfast.calori ?? "0"),
                   let fat = Float(indexBreakfast.fat ?? "0"),
                   let protein = Float(indexBreakfast.protein ?? "0"),
                   let carbs = Float(indexBreakfast.carbon ?? "0") {
                   // Update progress views in HomeCell
                    cell.updateProgressViews(calories: calories, fat: fat, protein: protein, carbs: carbs, maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple), duration: 1.0)
                }
            }

        case 1:
            if let indexBreakfast = self.coredata.lunch?[row] {
                cell.titleLabel?.text = indexBreakfast.title?.capitalized
                highestValueColor = determineHighestValueColor(carbons: indexBreakfast.carbon ?? "0", fat: indexBreakfast.fat ?? "0", protein: indexBreakfast.protein ?? "0")
                cell.homeVC = self
                if let calories = Float(indexBreakfast.calori ?? "0"),
                   let fat = Float(indexBreakfast.fat ?? "0"),
                   let protein = Float(indexBreakfast.protein ?? "0"),
                   let carbs = Float(indexBreakfast.carbon ?? "0") {
                   // Update progress views in HomeCell
                    cell.updateProgressViews(calories: calories, fat: fat, protein: protein, carbs: carbs, maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple), duration: 1.0)
                }
            }
        case 2:
            if let indexBreakfast = self.coredata.dinner?[row] {
                // Baş harfi büyük yap
                cell.titleLabel?.text = indexBreakfast.title?.capitalized
                highestValueColor = determineHighestValueColor(carbons: indexBreakfast.carbon ?? "0", fat: indexBreakfast.fat ?? "0", protein: indexBreakfast.protein ?? "0")
                cell.homeVC = self
                if let calories = Float(indexBreakfast.calori ?? "0"),
                   let fat = Float(indexBreakfast.fat ?? "0"),
                   let protein = Float(indexBreakfast.protein ?? "0"),
                   let carbs = Float(indexBreakfast.carbon ?? "0") {
                   // Update progress views in HomeCell
                    cell.updateProgressViews(calories: calories, fat: fat, protein: protein, carbs: carbs, maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple), duration: 1.0)
                }
            }
        case 3:
            if let indexBreakfast = self.coredata.snack?[row] {
                cell.titleLabel?.text = indexBreakfast.title?.capitalized
                highestValueColor = determineHighestValueColor(carbons: indexBreakfast.carbon ?? "0", fat: indexBreakfast.fat ?? "0", protein: indexBreakfast.protein ?? "0")
                cell.homeVC = self
                if let calories = Float(indexBreakfast.calori ?? "0"),
                   let fat = Float(indexBreakfast.fat ?? "0"),
                   let protein = Float(indexBreakfast.protein ?? "0"),
                   let carbs = Float(indexBreakfast.carbon ?? "0") {
                   // Update progress views in HomeCell
                    cell.updateProgressViews(calories: calories, fat: fat, protein: protein, carbs: carbs, maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple), duration: 1.0)
                }
            }
        default:
            break
        }
        // Set the background color of colorView based on the highest value
        cell.colorView.backgroundColor = highestValueColor
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let maxCal = 350
        let maxPro = 30
        let maxFat = 30
        let maxCarbs = 30
        // Get the selected index path
        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("Selected index path is nil.")
            return
        }
      
        if selectedIndexPath == indexPath {
            // If the same cell is selected again, reset the state
            selectedIndexPath = nil
            let currentSegmentIndex = self.segment.selectedSegmentIndex
            
            switch currentSegmentIndex {
            case 0:
                tableView.reloadData()
                coredata.fetchBreakfast(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumBreakfast(forDate: datePicker.date)
                nameOfMeals.text = "Kahvaltı"
                
            case 1:
                tableView.reloadData()
                coredata.fetchLunch(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumLunch(forDate: datePicker.date)
                nameOfMeals.text = "Öğle Y."
                
            case 2:
                tableView.reloadData()
                coredata.fetchDinner(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumDinner(forDate: datePicker.date)
                nameOfMeals.text = "Akşam Y."
                
            case 3:
                tableView.reloadData()
                coredata.fetchSnack(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumSnack(forDate: datePicker.date)
                nameOfMeals.text = "Atıştırma"
                
            default:
                break
            }
        } else {
            let currentSegmentIndex = self.segment.selectedSegmentIndex
            
            switch currentSegmentIndex {
            case 0:
                
                selectedIndexPath = indexPath
                
                var food: Any?
                
                if let selectedFood = coredata.breakfast?[indexPath.row] {
                    food = selectedFood
                }
             
                let foodName = (food as? Breakfast)?.title ?? ""
                let protein = (food as? Breakfast)?.protein ?? ""
                let carbon = (food as? Breakfast)?.carbon ?? ""
                let fat = (food as? Breakfast)?.fat ?? ""
                let calori = (food as? Breakfast)?.calori ?? ""
                
                nameOfMeals.text = foodName
                purpleInfoLabel.text = String(format: "%.2f", Float(calori) ?? 0.0)
                redInfoLabel.text = String(format: "%.2f", Float(protein) ?? 0.0)
                yellowInfoLabel.text = String(format: "%.2f", Float(fat) ?? 0.0)
                greenInfoLabel.text = String(format: "%.2f", Float(carbon) ?? 0.0)
                
                purpleTotal.text = String(maxCal)
                redTotal.text = "\(maxPro)"
                yellowTotal.text = "\(maxFat)"
                greenTotal.text = "\(maxCarbs)"
                
                // Convert String values to Float
                if let caloriDouble = Float(calori),
                   let proteinDouble = Float(protein),
                   let fatDouble = Float(fat),
                   let carbonDouble = Float(carbon) {
                    
                    updateProgressViews(calories: caloriDouble, fat: fatDouble, protein: proteinDouble, carbs: carbonDouble, maxGreen: Float(maxCarbs), maxYellow: Float(maxFat), maxRed: Float(maxPro), maxPurple: Float(maxCal))
                } else {
                    // Handle the case where conversion fails
                    print("Error: Could not convert one or more values to Double.")
                }
                
                updateVisibility(markPurple, value: Float(calori)!, threshold: Float(maxCal))
                updateVisibility(markRed, value: Float(protein)!, threshold: Float(maxPro))
                updateVisibility(markYellow, value: Float(fat)!, threshold: Float(maxFat))
                updateVisibility(markGreen, value: Float(carbon)!, threshold: Float(maxCarbs))
                
            case 1:
                
                selectedIndexPath = indexPath
                
                var food: Any?
                
                if let selectedFood = coredata.lunch?[indexPath.row] {
                    food = selectedFood
                }
             
                
                let foodName = (food as? Lunch)?.title ?? ""
                let protein = (food as? Lunch)?.protein ?? ""
                let carbon = (food as? Lunch)?.carbon ?? ""
                let fat = (food as? Lunch)?.fat ?? ""
                let calori = (food as? Lunch)?.calori ?? ""
                
                nameOfMeals.text = foodName
                purpleInfoLabel.text = String(format: "%.2f", Float(calori) ?? 0.0)
                redInfoLabel.text = String(format: "%.2f", Float(protein) ?? 0.0)
                yellowInfoLabel.text = String(format: "%.2f", Float(fat) ?? 0.0)
                greenInfoLabel.text = String(format: "%.2f", Float(carbon) ?? 0.0)
                
                purpleTotal.text = "\(maxCal)"
                redTotal.text = "\(maxPro)"
                yellowTotal.text = "\(maxFat)"
                greenTotal.text = "\(maxCarbs)"
                
                // Convert String values to Double
                if let caloriDouble = Float(calori),
                   let proteinDouble = Float(protein),
                   let fatDouble = Float(fat),
                   let carbonDouble = Float(carbon) {
                    
                    updateProgressViews(calories: Float(caloriDouble), fat: Float(fatDouble), protein: Float(proteinDouble), carbs: Float(carbonDouble), maxGreen: Float(maxCarbs), maxYellow: Float(maxFat), maxRed: Float(maxPro), maxPurple: Float(maxCal))
                } else {
                    // Handle the case where conversion fails
                    print("Error: Could not convert one or more values to Double.")
                }
                
                updateVisibility(markPurple, value: Float(calori)!, threshold: Float(maxCal))
                updateVisibility(markRed, value: Float(protein)!, threshold: Float(maxPro))
                updateVisibility(markYellow, value: Float(fat)!, threshold: Float(maxFat))
                updateVisibility(markGreen, value: Float(carbon)!, threshold: Float(maxCarbs))
                
            case 2:
                
                selectedIndexPath = indexPath
                
                var food: Any?
                
                if let selectedFood = coredata.dinner?[indexPath.row] {
                    food = selectedFood
                }
           
                let foodName = (food as? Dinner)?.title ?? ""
                let protein = (food as? Dinner)?.protein ?? ""
                let carbon = (food as? Dinner)?.carbon ?? ""
                let fat = (food as? Dinner)?.fat ?? ""
                let calori = (food as? Dinner)?.calori ?? ""
                
                nameOfMeals.text = foodName
                purpleInfoLabel.text = String(format: "%.2f", Float(calori) ?? 0.0)
                redInfoLabel.text = String(format: "%.2f", Float(protein) ?? 0.0)
                yellowInfoLabel.text = String(format: "%.2f", Float(fat) ?? 0.0)
                greenInfoLabel.text = String(format: "%.2f", Float(carbon) ?? 0.0)
                
                purpleTotal.text = "\(maxCal)"
                redTotal.text = "\(maxPro)"
                yellowTotal.text = "\(maxFat)"
                greenTotal.text = "\(maxCarbs)"
                
                // Convert String values to Double
                if let caloriDouble = Float(calori),
                   let proteinDouble = Float(protein),
                   let fatDouble = Float(fat),
                   let carbonDouble = Float(carbon) {
                    
                    updateProgressViews(calories: caloriDouble, fat: fatDouble, protein: proteinDouble, carbs: carbonDouble, maxGreen: Float(maxCarbs), maxYellow: Float(maxFat), maxRed: Float(maxPro), maxPurple: Float(maxCal))
                } else {
                    // Handle the case where conversion fails
                    print("Error: Could not convert one or more values to Double.")
                }
                
                updateVisibility(markPurple, value: Float(calori)!, threshold: Float(maxCal))
                updateVisibility(markRed, value: Float(protein)!, threshold: Float(maxPro))
                updateVisibility(markYellow, value: Float(fat)!, threshold: Float(maxFat))
                updateVisibility(markGreen, value: Float(carbon)!, threshold: Float(maxCarbs))
                
            case 3:
                selectedIndexPath = indexPath
                
                var food: Any?
                
                if let selectedFood = coredata.snack?[indexPath.row] {
                    food = selectedFood
                }
                
                let foodName = (food as? Snack)?.title ?? ""
                let protein = (food as? Snack)?.protein ?? ""
                let carbon = (food as? Snack)?.carbon ?? ""
                let fat = (food as? Snack)?.fat ?? ""
                let calori = (food as? Snack)?.calori ?? ""
                
                nameOfMeals.text = foodName
                purpleInfoLabel.text = String(format: "%.2f", Float(calori) ?? 0.0)
                redInfoLabel.text = String(format: "%.2f", Float(protein) ?? 0.0)
                yellowInfoLabel.text = String(format: "%.2f", Float(fat) ?? 0.0)
                greenInfoLabel.text = String(format: "%.2f", Float(carbon) ?? 0.0)
                
                purpleTotal.text = "\(maxCal)"
                redTotal.text = "\(maxPro)"
                yellowTotal.text = "\(maxFat)"
                greenTotal.text = "\(maxCarbs)"
                
                // Convert String values to Double
                if let caloriDouble = Float(calori),
                   let proteinDouble = Float(protein),
                   let fatDouble = Float(fat),
                   let carbonDouble = Float(carbon) {
                    
                    updateProgressViews(calories: caloriDouble, fat: fatDouble, protein: proteinDouble, carbs: carbonDouble, maxGreen: Float(maxCarbs), maxYellow: Float(maxFat), maxRed: Float(maxPro), maxPurple: Float(maxCal))
                } else {
                    // Handle the case where conversion fails
                    print("Error: Could not convert one or more values to Double.")
                }
                
                updateVisibility(markPurple, value: Float(calori)!, threshold: Float(maxCal))
                updateVisibility(markRed, value: Float(protein)!, threshold: Float(maxPro))
                updateVisibility(markYellow, value: Float(fat)!, threshold: Float(maxFat))
                updateVisibility(markGreen, value: Float(carbon)!, threshold: Float(maxCarbs))
                
            default:
                break
            }
        }
    }
    // Helper function to determine the highest value and return the corresponding color
    func determineHighestValueColor(carbons: String, fat: String, protein: String) -> UIColor {
        var highestValueColor: UIColor = .clear
        
        // Convert string representations to float
        if let carbsValue = Float(carbons), let fatValue = Float(fat), let proteinValue = Float(protein) {
            let maxValue = max(carbsValue, fatValue, proteinValue)
            if maxValue == carbsValue {
                highestValueColor = .systemGreen
            } else if maxValue == fatValue {
                highestValueColor = .systemYellow
            } else if maxValue == proteinValue {
                highestValueColor = .systemRed
            }
        }
        return highestValueColor
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            // Haptic feedback
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.impactOccurred()
            // Handle deletion logic here
            self?.deleteItem(at: indexPath)
            completionHandler(true)
        }
        // Customize the appearance of the delete action if needed
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeConfig.performsFirstActionWithFullSwipe = false // Swipe only triggers the delete action
        
        return swipeConfig
    }
    //helper for deleting
    func deleteItem(at indexPath: IndexPath) {
        let context = coredata.context
        
        switch segment.selectedSegmentIndex {
        case 0:
            if let breakfastItem = self.coredata.breakfast?[indexPath.row] {
                context.delete(breakfastItem)
                self.coredata.breakfast?.remove(at: indexPath.row)
                sumBreakfast(forDate: datePicker.date)
                ui.updateButtonTapped()
            }
        case 1:
            if let lunchItem = self.coredata.lunch?[indexPath.row] {
                context.delete(lunchItem)
                self.coredata.lunch?.remove(at: indexPath.row)
                sumLunch(forDate: datePicker.date) // Öğün türüne özel sum fonksiyonunu çağır
                ui.updateButtonTapped()
            }
        case 2:
            if let dinnerItem = self.coredata.dinner?[indexPath.row] {
                context.delete(dinnerItem)
                self.coredata.dinner?.remove(at: indexPath.row)
                sumDinner(forDate: datePicker.date) // Öğün türüne özel sum fonksiyonunu çağır
                ui.updateButtonTapped()
            }
        case 3:
            if let snackItem = self.coredata.snack?[indexPath.row] {
                context.delete(snackItem)
                self.coredata.snack?.remove(at: indexPath.row)
                sumSnack(forDate: datePicker.date) // Öğün türüne özel sum fonksiyonunu çağır
                ui.updateButtonTapped()
            }
        default:
            break
        }
        do {
            try context.save()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } catch {
            // Handle the error appropriately
            print("Error deleting item: \(error.localizedDescription)")
        }
    }
}

