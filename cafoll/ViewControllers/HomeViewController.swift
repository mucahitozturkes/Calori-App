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
    @IBOutlet weak var goalTextLAbel: UILabel!
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
        
        sumBreakfast(forDate: datePicker.date)
    }
    
    func updateBadge() {
        let totalBadgeCount = badgeCount.reduce(0, +)

        if totalBadgeCount > 0 {
            // Eğer toplam badge sayısı 0'dan büyükse, tabBarItem'a badge ekleyin
            tabBarItem.badgeValue = "\(totalBadgeCount)"
        } else {
            // Eğer toplam badge sayısı 0 veya daha küçükse, badge'i kaldırın
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
        sumBreakfast(forDate: sender.date) // Assuming this function uses the fetched data
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
        // Dereceyi radyana çevir
        let radians = degrees * .pi / 180
        
        // UILabel'ı belirtilen dereceyle döndür
        label.transform = CGAffineTransform(rotationAngle: -radians)
    }
    // UITabBarControllerDelegate metodunu implement et
     func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            if viewController is HomeViewController {
                // start up
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
        
        coredata.fetchBreakfast(forDate: datePicker.date)
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
                nameOfMeals.text = "Breakfast"
            case 1:
                coredata.fetchLunch(forDate: datePicker.date)
                sumLunch(forDate: datePicker.date)
                nameOfMeals.text = "Lunch"
            case 2:
                coredata.fetchDinner(forDate: datePicker.date)
                sumDinner(forDate: datePicker.date)
                nameOfMeals.text = "Dinner"
            case 3:
                coredata.fetchSnack(forDate: datePicker.date)
                sumSnack(forDate: datePicker.date)
                nameOfMeals.text = "Snack"
            default:
                break
            }
            
            // Update the table
            tableView.reloadData()
        }
   
    func updateLabel() {
        nameOfMeals.text = "Breakfast"
    }
    //segment Button
    @IBAction func segmentButtonPressed(_ sender: UISegmentedControl) {
            let currentSegmentIndex = sender.selectedSegmentIndex

            switch currentSegmentIndex {
            case 0:
                tableView.reloadData()
                coredata.fetchBreakfast(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                updateLabel()
                sumBreakfast(forDate: datePicker.date)
                nameOfMeals.text = "Breakfast"
                           
            case 1:
                tableView.reloadData()
                coredata.fetchLunch(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                updateLabel()
                sumLunch(forDate: datePicker.date)
                nameOfMeals.text = "Lunch"
              
            case 2:
                tableView.reloadData()
                coredata.fetchDinner(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumDinner(forDate: datePicker.date)
                nameOfMeals.text = "Dinner"
            
            case 3:
                tableView.reloadData()
                coredata.fetchSnack(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumSnack(forDate: datePicker.date)
                nameOfMeals.text = "Snack"
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
        var totalCalories = 0.0
        var totalFats = 0.0
        var totalProtein = 0.0
        var totalCarbs = 0.0
        
        for item in breakfastItems {
            // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Double(item.calori ?? "0") ?? 0.0
                totalFats += Double(item.fat ?? "0") ?? 0.0
                totalProtein += Double(item.protein ?? "0") ?? 0.0
                totalCarbs += Double(item.carbon ?? "0") ?? 0.0
            }
        }
        
        if let maxGreen = UserDefaults.standard.value(forKey: "breakfastgreenSliderValue") as? Double,
           let maxYellow = UserDefaults.standard.value(forKey: "breakfastyellowSliderValue") as? Double,
           let maxRed = UserDefaults.standard.value(forKey: "breakfastredSliderValue") as? Double,
           let maxPurple = UserDefaults.standard.value(forKey: "breakfastpurpleSliderValue") as? Double {
            
            updateProgressViews(calories: totalCalories, fat: totalFats, protein: totalProtein, carbs: totalCarbs, maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple))
            
            // Toplam değerleri ekrana yazdır
            purpleInfoLabel.text = String(format: "%.0f", totalCalories)
            redInfoLabel.text = String(format: "%.0f", totalProtein)
            yellowInfoLabel.text = String(format: "%.0f", totalFats)
            greenInfoLabel.text = String(format: "%.0f", totalCarbs)
            
            purpleTotal.text = String(format: "%.0f", maxPurple)
            redTotal.text = String(format: "%.0f", maxRed)
            yellowTotal.text = String(format: "%.0f", maxYellow)
            greenTotal.text = String(format: "%.0f", maxGreen)
            
            updateVisibility(markPurple, value: totalCalories, threshold: maxPurple)
            updateVisibility(markRed, value: totalProtein, threshold: maxRed)
            updateVisibility(markYellow, value: totalFats, threshold: maxYellow)
            updateVisibility(markGreen, value: totalCarbs, threshold: maxGreen)
            
        } else {
            // Eğer bir değer nil veya dönüştürülemezse buraya girecek
            print("Hata: Bir değer nil veya dönüştürülemez.")
            if settingsViewController.progressGreen?.text == nil {
                print("Green is nil")
            }
            if settingsViewController.progressYellow?.text == nil {
                print("Yellow is nil")
            }
            if settingsViewController.progressRed?.text == nil {
                print("sRed is nil")
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
        var totalCalories = 0.0
        var totalFats = 0.0
        var totalProtein = 0.0
        var totalCarbs = 0.0

        for item in lunchItems {
            // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Double(item.calori ?? "0") ?? 0.0
                totalFats += Double(item.fat ?? "0") ?? 0.0
                totalProtein += Double(item.protein ?? "0") ?? 0.0
                totalCarbs += Double(item.carbon ?? "0") ?? 0.0
            }
        }
      
        if let maxGreen = UserDefaults.standard.value(forKey: "lunchgreenSliderValue") as? Double,
           let maxYellow = UserDefaults.standard.value(forKey: "lunchyellowSliderValue") as? Double,
           let maxRed = UserDefaults.standard.value(forKey: "lunchredSliderValue") as? Double,
           let maxPurple = UserDefaults.standard.value(forKey: "lunchpurpleSliderValue") as? Double {
            
            updateProgressViews(calories: totalCalories, fat: totalFats, protein: totalProtein, carbs: totalCarbs, maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple))
            
            // Toplam değerleri ekrana yazdır
            purpleInfoLabel.text = String(format: "%.0f", totalCalories)
            redInfoLabel.text = String(format: "%.0f", totalProtein)
            yellowInfoLabel.text = String(format: "%.0f", totalFats)
            greenInfoLabel.text = String(format: "%.0f", totalCarbs)
            
            purpleTotal.text = String(format: "%.0f", maxPurple)
            redTotal.text = String(format: "%.0f", maxRed)
            yellowTotal.text = String(format: "%.0f", maxYellow)
            greenTotal.text = String(format: "%.0f", maxGreen)
            
            updateVisibility(markPurple, value: totalCalories, threshold: maxPurple)
            updateVisibility(markRed, value: totalProtein, threshold: maxRed)
            updateVisibility(markYellow, value: totalFats, threshold: maxYellow)
            updateVisibility(markGreen, value: totalCarbs, threshold: maxGreen)
            
        } else {
            // Eğer bir değer nil veya dönüştürülemezse buraya girecek
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
        var totalCalories = 0.0
        var totalFats = 0.0
        var totalProtein = 0.0
        var totalCarbs = 0.0

        for item in dinnerItems {
            // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Double(item.calori ?? "0") ?? 0.0
                totalFats += Double(item.fat ?? "0") ?? 0.0
                totalProtein += Double(item.protein ?? "0") ?? 0.0
                totalCarbs += Double(item.carbon ?? "0") ?? 0.0
            }
        }
     
        if let maxGreen = UserDefaults.standard.value(forKey: "dinnergreenSliderValue") as? Double,
           let maxYellow = UserDefaults.standard.value(forKey: "dinneryellowSliderValue") as? Double,
           let maxRed = UserDefaults.standard.value(forKey: "dinnerredSliderValue") as? Double,
           let maxPurple = UserDefaults.standard.value(forKey: "dinnerpurpleSliderValue") as? Double {
            
            updateProgressViews(calories: totalCalories, fat: totalFats, protein: totalProtein, carbs: totalCarbs, maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple))
            
            // Toplam değerleri ekrana yazdır
            purpleInfoLabel.text = String(format: "%.0f", totalCalories)
            redInfoLabel.text = String(format: "%.0f", totalProtein)
            yellowInfoLabel.text = String(format: "%.0f", totalFats)
            greenInfoLabel.text = String(format: "%.0f", totalCarbs)
            
            purpleTotal.text = String(format: "%.0f", maxPurple)
            redTotal.text = String(format: "%.0f", maxRed)
            yellowTotal.text = String(format: "%.0f", maxYellow)
            greenTotal.text = String(format: "%.0f", maxGreen)
            
            updateVisibility(markPurple, value: totalCalories, threshold: maxPurple)
            updateVisibility(markRed, value: totalProtein, threshold: maxRed)
            updateVisibility(markYellow, value: totalFats, threshold: maxYellow)
            updateVisibility(markGreen, value: totalCarbs, threshold: maxGreen)
            
        } else {
            // Eğer bir değer nil veya dönüştürülemezse buraya girecek
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
        var totalCalories = 0.0
        var totalFats = 0.0
        var totalProtein = 0.0
        var totalCarbs = 0.0

        for item in snackItems {
            // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Double(item.calori ?? "0") ?? 0.0
                totalFats += Double(item.fat ?? "0") ?? 0.0
                totalProtein += Double(item.protein ?? "0") ?? 0.0
                totalCarbs += Double(item.carbon ?? "0") ?? 0.0
            }
        }

        if let maxGreen = UserDefaults.standard.value(forKey: "snackgreenSliderValue") as? Double,
           let maxYellow = UserDefaults.standard.value(forKey: "snackyellowSliderValue") as? Double,
           let maxRed = UserDefaults.standard.value(forKey: "snackredSliderValue") as? Double,
           let maxPurple = UserDefaults.standard.value(forKey: "snackpurpleSliderValue") as? Double {
            
            updateProgressViews(calories: totalCalories, fat: totalFats, protein: totalProtein, carbs: totalCarbs, maxGreen: Float(maxGreen), maxYellow: Float(maxYellow), maxRed: Float(maxRed), maxPurple: Float(maxPurple))
            
            // Toplam değerleri ekrana yazdır
            purpleInfoLabel.text = String(format: "%.0f", totalCalories)
            redInfoLabel.text = String(format: "%.0f", totalProtein)
            yellowInfoLabel.text = String(format: "%.0f", totalFats)
            greenInfoLabel.text = String(format: "%.0f", totalCarbs)
            
            purpleTotal.text = String(format: "%.0f", maxPurple)
            redTotal.text = String(format: "%.0f", maxRed)
            yellowTotal.text = String(format: "%.0f", maxYellow)
            greenTotal.text = String(format: "%.0f", maxGreen)
            
            updateVisibility(markPurple, value: totalCalories, threshold: maxPurple)
            updateVisibility(markRed, value: totalProtein, threshold: maxRed)
            updateVisibility(markYellow, value: totalFats, threshold: maxYellow)
            updateVisibility(markGreen, value: totalCarbs, threshold: maxGreen)
            
        } else {
            // Eğer bir değer nil veya dönüştürülemezse buraya girecek
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
    
    func updateVisibility(_ mark: UIImageView, value: Double, threshold: Double) {
        mark.isHidden = value < threshold
    
    }

    func updateProgressViews(calories: Double, fat: Double, protein: Double, carbs: Double, maxGreen: Float, maxYellow: Float, maxRed: Float, maxPurple: Float, duration: TimeInterval = 1.0) {
        // Set initial progress to 0.0
        progressPurple.progress = 0.0
        progressYellow.progress = 0.0
        progressRed.progress = 0.0
        progressGreen.progress = 0.0

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
        
        var totalCalories = 0.0
        var totalFats = 0.0
        var totalProtein = 0.0
        var totalCarbs = 0.0
        guard let breakfastItems = self.coredata.breakfast else {
            return
        }

        for item in breakfastItems {
            // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Double(item.calori ?? "0") ?? 0.0
                totalFats += Double(item.fat ?? "0") ?? 0.0
                totalProtein += Double(item.protein ?? "0") ?? 0.0
                totalCarbs += Double(item.carbon ?? "0") ?? 0.0
            }
        }
        guard let lunchItems = self.coredata.lunch else {
            return
        }
    
        for item in lunchItems {
            // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Double(item.calori ?? "0") ?? 0.0
                totalFats += Double(item.fat ?? "0") ?? 0.0
                totalProtein += Double(item.protein ?? "0") ?? 0.0
                totalCarbs += Double(item.carbon ?? "0") ?? 0.0
            }
        }
        guard let dinnerItems = self.coredata.dinner else {
            return
        }

        for item in dinnerItems {
            // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Double(item.calori ?? "0") ?? 0.0
                totalFats += Double(item.fat ?? "0") ?? 0.0
                totalProtein += Double(item.protein ?? "0") ?? 0.0
                totalCarbs += Double(item.carbon ?? "0") ?? 0.0
            }
        }
        
        guard let snackItems = self.coredata.snack else {
            return
        }
        for item in snackItems {
            // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
            if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                totalCalories += Double(item.calori ?? "0") ?? 0.0
                totalFats += Double(item.fat ?? "0") ?? 0.0
                totalProtein += Double(item.protein ?? "0") ?? 0.0
                totalCarbs += Double(item.carbon ?? "0") ?? 0.0
            }
        }
        
        totalCalori.text = String(format: "%.0f", totalCalories)
        totalPRotein.text = String(format: "%.0f", totalProtein)
        totalFat.text = String(format: "%.0f", totalFats)
        totalCarbon.text = String(format: "%.0f", totalCarbs)
        
        if totalCalories >= Double(ui.circleTotal().0),
           totalProtein >= Double(ui.circleTotal().1),
           totalFats >= Double(ui.circleTotal().2),
           totalCarbs >= Double(ui.circleTotal().3)
        {
            checkMarkMaxValue.isHidden = false
            goalTextLAbel.isHidden = true
        } else {
            checkMarkMaxValue.isHidden = true
            goalTextLAbel.isHidden = false
        }
        
        
    }
    
    // Sağa tıklandığında tarihi bir gün ileri al
    @IBAction func rightDate(_ sender: UIButton) {
        var currentDate = datePicker.date
            // Bir gün ekleyerek tarihi güncelle
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            datePicker.setDate(currentDate, animated: true)
        
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
    }

    // Sola tıklandığında tarihi bir gün geri al
    @IBAction func leftDate(_ sender: UIButton) {
        var currentDate = datePicker.date
            // Bir gün çıkartarak tarihi güncelle
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            datePicker.setDate(currentDate, animated: true)
        
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
                coredata.fetchBreakfast(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumBreakfast(forDate: datePicker.date)
                nameOfMeals.text = "Breakfast"
                
            case 1:
                tableView.reloadData()
                coredata.fetchLunch(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumLunch(forDate: datePicker.date)
                nameOfMeals.text = "Lunch"
                
            case 2:
                tableView.reloadData()
                coredata.fetchDinner(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumDinner(forDate: datePicker.date)
                nameOfMeals.text = "Dinner"
                
            case 3:
                tableView.reloadData()
                coredata.fetchSnack(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumSnack(forDate: datePicker.date)
                nameOfMeals.text = "Snack"
                
            default:
                break
            }
            // Update the table
            tableView.reloadData()
        
    
        } else {
            let maxCalories = 2800
            let maxFats = 100
            let maxProtein = 100
            let maxCarbs = 100
            
            var totalCalories = 0.0
            var totalFats = 0.0
            var totalProtein = 0.0
            var totalCarbs = 0.0
            guard let breakfastItems = self.coredata.breakfast else {
                return
            }
            
            for item in breakfastItems {
                // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
                if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                    totalCalories += Double(item.calori ?? "0") ?? 0.0
                    totalFats += Double(item.fat ?? "0") ?? 0.0
                    totalProtein += Double(item.protein ?? "0") ?? 0.0
                    totalCarbs += Double(item.carbon ?? "0") ?? 0.0
                }
            }
            guard let lunchItems = self.coredata.lunch else {
                return
            }
            
            for item in lunchItems {
                // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
                if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                    totalCalories += Double(item.calori ?? "0") ?? 0.0
                    totalFats += Double(item.fat ?? "0") ?? 0.0
                    totalProtein += Double(item.protein ?? "0") ?? 0.0
                    totalCarbs += Double(item.carbon ?? "0") ?? 0.0
                }
            }
            guard let dinnerItems = self.coredata.dinner else {
                return
            }
            
            for item in dinnerItems {
                // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
                if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                    totalCalories += Double(item.calori ?? "0") ?? 0.0
                    totalFats += Double(item.fat ?? "0") ?? 0.0
                    totalProtein += Double(item.protein ?? "0") ?? 0.0
                    totalCarbs += Double(item.carbon ?? "0") ?? 0.0
                }
            }
            
            guard let snackItems = self.coredata.snack else {
                return
            }
            for item in snackItems {
                // Eğer öğünün tarihi, istediğiniz tarih ile aynıysa, değerleri topla
                if let itemDate = item.date, Calendar.current.isDate(itemDate, inSameDayAs: date) {
                    totalCalories += Double(item.calori ?? "0") ?? 0.0
                    totalFats += Double(item.fat ?? "0") ?? 0.0
                    totalProtein += Double(item.protein ?? "0") ?? 0.0
                    totalCarbs += Double(item.carbon ?? "0") ?? 0.0
                }
            }
            
            nameOfMeals.text = "Daily Goal!"
            
            purpleInfoLabel.text = String(format: "%.0f", totalCalories)
            redInfoLabel.text = String(format: "%.0f", totalProtein)
            yellowInfoLabel.text = String(format: "%.0f", totalFats)
            greenInfoLabel.text = String(format: "%.0f", totalCarbs)
            
            purpleTotal.text = String(maxCalories)
            redTotal.text = String(maxProtein)
            yellowTotal.text = String(maxFats)
            greenTotal.text = String(maxCarbs)
            
            totalCalori.text = String(maxCalories)
            totalFat.text = String(maxFats)
            totalPRotein.text = String(maxProtein)
            totalCarbon.text = String(maxCarbs)
            
            updateProgressViews(calories: totalCalories, fat: totalFats, protein: totalProtein, carbs: totalCarbs, maxGreen: Float(maxCarbs), maxYellow: Float(maxFats), maxRed: Float(maxProtein), maxPurple: Float(maxCalories))
            
            updateVisibility(markPurple, value: totalCalories, threshold: Double(maxCalories))
            updateVisibility(markRed, value: totalProtein, threshold: Double(maxFats))
            updateVisibility(markYellow, value: totalFats, threshold: Double(maxProtein))
            updateVisibility(markGreen, value: totalCarbs, threshold: Double(maxCarbs))
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
                cell.titleLabel?.text = indexBreakfast.title
                highestValueColor = determineHighestValueColor(carbons: indexBreakfast.carbon ?? "0", fat: indexBreakfast.fat ?? "0", protein: indexBreakfast.protein ?? "0")
            }
        case 1:
            if let indexLunch = self.coredata.lunch?[row] {
                cell.titleLabel?.text = indexLunch.title
                highestValueColor = determineHighestValueColor(carbons: indexLunch.carbon ?? "0", fat: indexLunch.fat ?? "0", protein: indexLunch.protein ?? "0")
            }
        case 2:
            if let indexDinner = self.coredata.dinner?[row] {
                cell.titleLabel?.text = indexDinner.title
                highestValueColor = determineHighestValueColor(carbons: indexDinner.carbon ?? "0", fat: indexDinner.fat ?? "0", protein: indexDinner.protein ?? "0")
            }
        case 3:
            if let indexSnack = self.coredata.snack?[row] {
                cell.titleLabel?.text = indexSnack.title
                highestValueColor = determineHighestValueColor(carbons: indexSnack.carbon ?? "0", fat: indexSnack.fat ?? "0", protein: indexSnack.protein ?? "0")
            }
        default:
            break
        }

        // Set the background color of colorView based on the highest value
        cell.colorView.backgroundColor = highestValueColor

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
                nameOfMeals.text = "Breakfast"
             
            case 1:
                tableView.reloadData()
                coredata.fetchLunch(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumLunch(forDate: datePicker.date)
                nameOfMeals.text = "Lunch"
              
            case 2:
                tableView.reloadData()
                coredata.fetchDinner(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumDinner(forDate: datePicker.date)
                nameOfMeals.text = "Dinner"
            
            case 3:
                tableView.reloadData()
                coredata.fetchSnack(forDate: datePicker.date)
                fetchDataAndUpdateUI()
                ui.updateButtonTapped()
                sumSnack(forDate: datePicker.date)
                nameOfMeals.text = "Snack"
              
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
                let maxCal = 500
                let maxPro = 35
                let maxFat = 35
                let maxCarbs = 35
                
                let foodName = (food as? Breakfast)?.title ?? ""
                let protein = (food as? Breakfast)?.protein ?? ""
                let carbon = (food as? Breakfast)?.carbon ?? ""
                let fat = (food as? Breakfast)?.fat ?? ""
                let calori = (food as? Breakfast)?.calori ?? ""
                
                nameOfMeals.text = foodName
                purpleInfoLabel.text = calori
                redInfoLabel.text = protein
                yellowInfoLabel.text = fat
                greenInfoLabel.text = carbon
                
                purpleTotal.text = String(maxCal)
                redTotal.text = "\(maxPro)"
                yellowTotal.text = "\(maxFat)"
                greenTotal.text = "\(maxCarbs)"
                
               
                // Convert String values to Double
                if let caloriDouble = Double(calori),
                   let proteinDouble = Double(protein),
                   let fatDouble = Double(fat),
                   let carbonDouble = Double(carbon) {

                    updateProgressViews(calories: caloriDouble, fat: fatDouble, protein: proteinDouble, carbs: carbonDouble, maxGreen: Float(maxCarbs), maxYellow: Float(maxFat), maxRed: Float(maxPro), maxPurple: Float(maxCal))
                } else {
                    // Handle the case where conversion fails
                    print("Error: Could not convert one or more values to Double.")
                }
                
                updateVisibility(markPurple, value: Double(calori)!, threshold: Double(maxCal))
                updateVisibility(markRed, value: Double(protein)!, threshold: Double(maxPro))
                updateVisibility(markYellow, value: Double(fat)!, threshold: Double(maxFat))
                updateVisibility(markGreen, value: Double(carbon)!, threshold: Double(maxCarbs))
                           
            case 1:
              
                selectedIndexPath = indexPath

                        var food: Any?

                if let selectedFood = coredata.lunch?[indexPath.row] {
                    food = selectedFood
                }
                let maxCal = 500
                let maxPro = 35
                let maxFat = 35
                let maxCarbs = 35
                
                let foodName = (food as? Lunch)?.title ?? ""
                let protein = (food as? Lunch)?.protein ?? ""
                let carbon = (food as? Lunch)?.carbon ?? ""
                let fat = (food as? Lunch)?.fat ?? ""
                let calori = (food as? Lunch)?.calori ?? ""
                
                nameOfMeals.text = foodName
                purpleInfoLabel.text = calori
                redInfoLabel.text = protein
                yellowInfoLabel.text = fat
                greenInfoLabel.text = carbon
                
                purpleTotal.text = "\(maxCal)"
                redTotal.text = "\(maxPro)"
                yellowTotal.text = "\(maxFat)"
                greenTotal.text = "\(maxCarbs)"
                
               
                // Convert String values to Double
                if let caloriDouble = Double(calori),
                   let proteinDouble = Double(protein),
                   let fatDouble = Double(fat),
                   let carbonDouble = Double(carbon) {

                    updateProgressViews(calories: caloriDouble, fat: fatDouble, protein: proteinDouble, carbs: carbonDouble, maxGreen: Float(maxCarbs), maxYellow: Float(maxFat), maxRed: Float(maxPro), maxPurple: Float(maxCal))
                } else {
                    // Handle the case where conversion fails
                    print("Error: Could not convert one or more values to Double.")
                }
                updateVisibility(markPurple, value: Double(calori)!, threshold: Double(maxCal))
                updateVisibility(markRed, value: Double(protein)!, threshold: Double(maxPro))
                updateVisibility(markYellow, value: Double(fat)!, threshold: Double(maxFat))
                updateVisibility(markGreen, value: Double(carbon)!, threshold: Double(maxCarbs))
            case 2:
              
                selectedIndexPath = indexPath

                        var food: Any?

                if let selectedFood = coredata.dinner?[indexPath.row] {
                    food = selectedFood
                }
                let maxCal = 500
                let maxPro = 35
                let maxFat = 35
                let maxCarbs = 35
                
                let foodName = (food as? Dinner)?.title ?? ""
                let protein = (food as? Dinner)?.protein ?? ""
                let carbon = (food as? Dinner)?.carbon ?? ""
                let fat = (food as? Dinner)?.fat ?? ""
                let calori = (food as? Dinner)?.calori ?? ""
                
                nameOfMeals.text = foodName
                purpleInfoLabel.text = calori
                redInfoLabel.text = protein
                yellowInfoLabel.text = fat
                greenInfoLabel.text = carbon
                
                purpleTotal.text = "\(maxCal)"
                redTotal.text = "\(maxPro)"
                yellowTotal.text = "\(maxFat)"
                greenTotal.text = "\(maxCarbs)"
                
               
                // Convert String values to Double
                if let caloriDouble = Double(calori),
                   let proteinDouble = Double(protein),
                   let fatDouble = Double(fat),
                   let carbonDouble = Double(carbon) {

                    updateProgressViews(calories: caloriDouble, fat: fatDouble, protein: proteinDouble, carbs: carbonDouble, maxGreen: Float(maxCarbs), maxYellow: Float(maxFat), maxRed: Float(maxPro), maxPurple: Float(maxCal))
                } else {
                    // Handle the case where conversion fails
                    print("Error: Could not convert one or more values to Double.")
                }
                updateVisibility(markPurple, value: Double(calori)!, threshold: Double(maxCal))
                updateVisibility(markRed, value: Double(protein)!, threshold: Double(maxPro))
                updateVisibility(markYellow, value: Double(fat)!, threshold: Double(maxFat))
                updateVisibility(markGreen, value: Double(carbon)!, threshold: Double(maxCarbs))
            case 3:
                selectedIndexPath = indexPath

                        var food: Any?

                if let selectedFood = coredata.snack?[indexPath.row] {
                    food = selectedFood
                }
                let maxCal = 500
                let maxPro = 35
                let maxFat = 35
                let maxCarbs = 35
                
                let foodName = (food as? Snack)?.title ?? ""
                let protein = (food as? Snack)?.protein ?? ""
                let carbon = (food as? Snack)?.carbon ?? ""
                let fat = (food as? Snack)?.fat ?? ""
                let calori = (food as? Snack)?.calori ?? ""
                
                nameOfMeals.text = foodName
                purpleInfoLabel.text = calori
                redInfoLabel.text = protein
                yellowInfoLabel.text = fat
                greenInfoLabel.text = carbon
                
                purpleTotal.text = "\(maxCal)"
                redTotal.text = "\(maxPro)"
                yellowTotal.text = "\(maxFat)"
                greenTotal.text = "\(maxCarbs)"
                
               
                // Convert String values to Double
                if let caloriDouble = Double(calori),
                   let proteinDouble = Double(protein),
                   let fatDouble = Double(fat),
                   let carbonDouble = Double(carbon) {

                    updateProgressViews(calories: caloriDouble, fat: fatDouble, protein: proteinDouble, carbs: carbonDouble, maxGreen: Float(maxCarbs), maxYellow: Float(maxFat), maxRed: Float(maxPro), maxPurple: Float(maxCal))
                } else {
                    // Handle the case where conversion fails
                    print("Error: Could not convert one or more values to Double.")
                }
                updateVisibility(markPurple, value: Double(calori)!, threshold: Double(maxCal))
                updateVisibility(markRed, value: Double(protein)!, threshold: Double(maxPro))
                updateVisibility(markYellow, value: Double(fat)!, threshold: Double(maxFat))
                updateVisibility(markGreen, value: Double(carbon)!, threshold: Double(maxCarbs))
            default:
                break
            }
        }
    }
    // Helper function to determine the highest value and return the corresponding color
    func determineHighestValueColor(carbons: String, fat: String, protein: String) -> UIColor {
        var highestValueColor: UIColor = .clear
        
        // Convert string representations to doubles
        if let carbsValue = Double(carbons), let fatValue = Double(fat), let proteinValue = Double(protein) {
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

