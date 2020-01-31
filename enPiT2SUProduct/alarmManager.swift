//
//  alarmsec.swift
//  alarmtest
//
//  Created by 片岡秀斗 on 2020/01/04.
//  Copyright © 2020 Shuto Kataoka. All rights reserved.
//

import Foundation
import UserNotifications
import AVFoundation

class LocalAlarm {
    
    func setlocalnotice(setDate :Date,identifier: String) {
        // ローカル通知の内容
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "MediBook通知"
        content.subtitle = "服用時間通知"
        content.body = "お薬の時間です！"
        
        // ローカル通知実行日時をセット dateComponentsは名前通りの構造体
        let component = Calendar.current.dateComponents([.hour, .minute], from: setDate)
        
        // ローカル通知リクエストを作成
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: true)
        // ユニークなIDを作る
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // ローカル通知リクエストを登録
        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func removenotice(identifier :String){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    print("Deleted!")
    }

    
}
