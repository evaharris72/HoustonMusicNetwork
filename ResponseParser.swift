

import Foundation
import UIKit
import SwiftyJSON
import CoreLocation

class ResponseParser: NSObject {
    private func parseProgramSchedule(json:JSON, completionHandler handler:WebServiceCompletionHandler)
    {
        let scheduleArraylist =  json.dictionaryValue["schedule"]?.arrayValue.map { (scheduleObj) -> Schedule in
        let schedule = Schedule()
        schedule.day = (scheduleObj.dictionaryValue["day"]?.stringValue)!
        schedule.events = (scheduleObj.dictionaryValue["events"]?.arrayValue.map { ( EventModelObject)-> Event  in
        let eventModelTemp = Event()
        eventModelTemp.showTimeStart = EventModelObject["show_time_start"].stringValue
        eventModelTemp.showTimeEnd = EventModelObject["show_time_end"].stringValue
        eventModelTemp.showTitle = EventModelObject["show_title"].stringValue
        eventModelTemp.duration = EventModelObject["duration"].stringValue
        eventModelTemp.showDescription = EventModelObject["show_description"].stringValue
        return eventModelTemp
        })!
         return schedule
        }
        handler(true, nil, scheduleArraylist as AnyObject?, nil)
    }
    
    
        private func parseRadio(json:JSON, completionHandler handler:WebServiceCompletionHandler)
        {
            print("PARSING api URL")
            let  StremModelItemObject = StremModel()
            print(json[0])
            StremModelItemObject.URL = (json.dictionaryValue["channel_url"]?.stringValue)!
            handler(true, nil, StremModelItemObject as AnyObject?, nil)
      }
    
    //MARK:- Basic parser method to parse the Skelton of the response
    func parseWithResponse(json:JSON, serviceMethodType methodType:ServiceMethodType, completionHandler handler:WebServiceCompletionHandler,statusCode:Int)
    {
        if statusCode == 200
        {
            switch methodType
            {
                case .programSchedule:
                    self.parseProgramSchedule(json: json, completionHandler: handler)
                case .streamFromApi:
                    self.parseRadio(json: json, completionHandler:handler)
                default: break
            }
        }
        else
        {
            if let message = json[WS_Param_Key_Message].string
            {
                handler(false, message , nil, nil)
            }
            else
            {
                let customError = NSError(domain:WS_Error_DataFormat, code: WS_ErrorCode_DataFormat, userInfo: nil)
            }
        }
    }
}
