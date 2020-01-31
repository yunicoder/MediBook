//
//  CustomTabBarController.swift
//  enPiT2SUProduct
//
//  Created by takuro yoshida on 2019/12/26.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //タブバーの色
        //self.tabBar.barTintColor = UIColor.init(red: 23/255, green: 250/255, blue: 247/255, alpha: 100/100)
        
        //薄い灰色
        self.tabBar.barTintColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        //ターコイズ
        //self.tabBar.barTintColor = UIColor.init(red:20/255, green:217/255, blue: 217/255, alpha: 85/100)
        
        //self.tabBar.barTintColor = UIColor.init(red: 97/255, green: 236/255, blue: 250/255, alpha: 90/100)
        // 選択時のカラー（アイコン＋テキスト）
        //self.tabBar.tintColor = UIColor.init(red: 250/255, green: 162/255, blue: 27/255, alpha: 90/100)
        
        //赤
        self.tabBar.tintColor = UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
        
        //オレンジ
        self.tabBar.tintColor = UIColor.init(red: 255/255, green: 115/255, blue: 30/255, alpha: 1)
        
        //パターン4
        //self.tabBar.tintColor = UIColor.init(red:20/255, green:217/255, blue: 217/255, alpha: 85/100)
        
        //navy
        //self.tabBar.tintColor = UIColor.init(red: 20/255, green:217/255, blue: 217/255, alpha: 100/100)
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
