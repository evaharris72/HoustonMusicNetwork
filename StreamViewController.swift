

import UIKit
import AVKit
import AVFoundation


class StreamViewController: UIViewController {
    
    //outlets of headings
    
    @IBOutlet weak var titleHeading: UILabel!
    @IBOutlet weak var titleAuthor: UILabel!
    @IBOutlet weak var tableViewStream: UITableView!
    @IBOutlet weak var videoViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleviewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewVideoStream: UIView!
    @IBOutlet weak var titleLogo: UIImageView!
    @IBOutlet weak var viewTitleBar: UIView!
    
    var scheduleProgramList = [Schedule]()
    var videoStreamUrl : String = ""
    var avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var playerItem:AVPlayerItem!
    var paused:Bool = false
    var videoPaused:Bool = false
    var videoStreamId:String?
    static var currentScheduleList = [Schedule]()
    var todayScheduleList = [Schedule]()
    var todayEventList = [Event]()
    var weekDay:String = ""
    var weekDayIndex:Int = 0
    var timer1:Timer? // Timer for Delay to hide Pause button
    var timer2:Timer? // Timer for Delay to hide Pause button
    var initalContentViewFrame : CGRect! = nil

     // Declaring and initializing the Week Array
    var weekArray:[String] = [NSLocalizedString("day1", comment: "Day of the week"),NSLocalizedString("day2", comment: "Day of the week"),NSLocalizedString("day3", comment: "Day of the week"),NSLocalizedString("day4", comment: "Day of the week"),NSLocalizedString("day5", comment: "Day of the week"),NSLocalizedString("day6", comment: "Day of the week"),NSLocalizedString("day7", comment: "Day of the week")]
    var orientationChanged : Bool = false
    var updater :Int!
    var orientationchanged : Bool = false
    var Toggle : Bool = false
    var Toggleplaypause : Bool = false
    var screenTapped_Flag : Bool = false
    var loadingdone:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLogo.image = #imageLiteral(resourceName: "logo")
        setupUI()
        // Do any additional setup after loading the view.
        tableViewStream.delegate = self
        tableViewStream.dataSource = self
        videoStreamId = videoStreamUrl
        viewTitleBar.backgroundColor = hexToUiColor().hexStringToUIColor(hex: unselectedDaySelectionColor)
        StartPlayingWhenloadingCompleted()
        weekDayIndex = getWeekDayIndex(week: getDayInWeek())
        
        if(scheduleProgramList.count - 1 >= weekDayIndex)
        {
            self.todayEventList = scheduleProgramList[self.weekDayIndex].events
        }
        self.tableViewStream.reloadData()
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateSchedule), userInfo: nil, repeats: true)
      
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
        if videoPaused == true {
            avPlayer.isMuted = false
            avPlayer.pause() // Start the playback
         }
        else if videoPaused == false{
            avPlayer.isMuted = false
            avPlayer.play() // Start the playback
         }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
        avPlayer.isMuted = true
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       updateSchedule()
    }
    
    @objc func updateSchedule()
    {
        if(todayEventList.count > 0)
        {
        for i in 0...todayEventList.count - 1
        {
            var componentsFirst = todayEventList[i].showTimeStart.components(separatedBy: " ")
            var componentssecond = todayEventList[i].showTimeEnd.components(separatedBy: " ")
            let showTimeStartTimeZone = componentsFirst[1]
            let showTimeEndTimeZone = componentssecond[1]
            
            if componentsFirst != [] &&  componentssecond != []
            {
                var componentsFirstFirst = componentsFirst[0].components(separatedBy: ":")
                let hoursFirst = componentsFirstFirst[0]
                let minutesFirst = componentsFirstFirst[1]
                //print("hoursFirst,minutesFirst ",hoursFirst,minutesFirst)
                var componentssecondsecond = componentssecond[0].components(separatedBy: ":")
                let hoursFirst2 = componentssecondsecond[0]
                let minutesFirst2 = componentssecondsecond[1]
                let today = NSDate()
                let dateFormatter = DateFormatter()
                let dateFormat = "hh:mm"
                dateFormatter.dateFormat = dateFormat
                let stringDate = dateFormatter.string(from: today as Date)
                let dateString = String(describing: Date().localDateString())
                let currentTimeZone = dateString.components(separatedBy: " ").last
                var componensOriginal = stringDate.components(separatedBy: ":")
                
                if(currentTimeZone == showTimeStartTimeZone)
                {
                if String(hoursFirst) <= String(describing: componensOriginal[0]) && String(minutesFirst) <= String(describing: componensOriginal[1]) && String(hoursFirst2) >= String(componensOriginal[0]) && String(minutesFirst2) >= String(componensOriginal[1])
                {
                    updater = i
                    print(" date : ", stringDate,String(hoursFirst),String(minutesFirst),updater)
                    tableViewStream.reloadData()
                    return
                }
                else
                {
                    if String(hoursFirst) <= String(describing: componensOriginal[0]) && String(minutesFirst) <= String(describing: componensOriginal[1]) && String(hoursFirst2) > String(componensOriginal[0])
                    {
                        updater = i
                        print(" date : second :  ", stringDate,String(hoursFirst),String(minutesFirst),updater)
                        tableViewStream.reloadData()
                        return
                    }
                }
            }
            }
        }
        }
    }

    func StartPlayingWhenloadingCompleted()
    {
        let videoURL = URL(string: videoStreamURL)
        avPlayer = AVPlayer(url: videoURL!)
        let playerController = AVPlayerViewController()
        playerController.player = avPlayer
        playerController.showsPlaybackControls = true
        self.addChild(playerController)
        viewVideoStream.addSubview(playerController.view)
        playerController.view.frame = CGRect.init(x: 0, y: 0, width: viewVideoStream.frame.size.width, height: viewVideoStream.frame.size.height)
        avPlayer.play()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    public func isVideoPlaying() -> Bool {
        if ((avPlayer.rate != 0) && (avPlayer.error == nil)) {
        // player is playing
            return true
        }
        else{
            return false
        }
    }
    
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
    }
    
    public func playVideoStream(){
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        viewVideoStream.layer.insertSublayer(avPlayerLayer, at: 0)
        let url = NSURL(string: videoStreamId!)
        playerItem = AVPlayerItem(url: url! as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
    }

    public func getDayInWeek() -> String {
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "EEEE"//"EE" to get short style
        let dayInWeek = dateFormatter.string(from: date as Date)//"Sunday"
        return dayInWeek
    }
    
    public func getWeekDayIndex(week:String) -> Int {
        var weekIndex:Int = -1
        switch week {
        case "Sunday":
            weekIndex = 0
            break
        case "Monday":
            weekIndex = 1
            break
        case "Tuesday":
            weekIndex = 2
            break
        case "Wednesday":
            weekIndex = 3
            break
        case "Thursday":
            weekIndex = 4
            break
        case "Friday":
            weekIndex = 5
            break
        case "Saturday":
            weekIndex = 6
            break
        case "dimanche":
            weekIndex = 0
            break
        case "lundi":
            weekIndex = 1
            break
        case "mardi":
            weekIndex = 2
            break
        case "mercredi":
            weekIndex = 3
            break
        case "jeudi":
            weekIndex = 4
            break
        case "vendredi":
            weekIndex = 5
            break
        case "samedi":
            weekIndex = 6
            break
        default:
            break
        }
        return weekIndex
    }
}

extension StreamViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableViewStream.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StreamTableViewCell
       if let currentTimeIndicatorIndex = updater
        {
            if indexPath.row == currentTimeIndicatorIndex
            {
                let event:Event = todayEventList[indexPath.row]
                cell.labelProgramName.text = event.showTitle
                cell.labelProgramTime.text = event.showTimeStart
                cell.secondaryLabel.text = event.showDescription
                cell.selectionStyle = .none
                cell.contentView.backgroundColor = hexToUiColor().hexStringToUIColor(hex: dayTextColor)
            }
            else
            {
                let event:Event = todayEventList[indexPath.row]
                cell.labelProgramName.text = event.showTitle
                cell.labelProgramTime.text = event.showTimeStart
                cell.secondaryLabel.text = event.showDescription
                cell.selectionStyle = .none
                cell.contentView.backgroundColor = hexToUiColor().hexStringToUIColor(hex: daySelectionColor)
            }
        }
        else
        {
            let event:Event = todayEventList[indexPath.row]
            cell.labelProgramName.text = event.showTitle
            cell.labelProgramTime.text = event.showTimeStart
            cell.secondaryLabel.text = event.showDescription
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = hexToUiColor().hexStringToUIColor(hex: daySelectionColor)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.todayEventList.count
    }
    
}

//pvt methods
extension StreamViewController
{
    func setupUI()
    {
        
    }
}



