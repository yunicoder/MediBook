//
//  MyUINavigationViewController.swift
//  enPiT2SUProduct
//
//  Created by takuro yoshida on 2019/12/26.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import UIKit

class MyUINavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //　ナビゲーションバーの背景色
        //deepskyblue
        //navigationBar.barTintColor = UIColor.init(red: 0/255, green: 191/255, blue: 255/255, alpha: 90/100)
        //lightSteelBlue
        //navigationBar.barTintColor = UIColor.init(red: 176/255, green: 196/255, blue: 222/255, alpha: 90/100)
        //aliceBlue
        //navigationBar.barTintColor = UIColor.init(red: 240/255, green: 248/255, blue: 255/255, alpha: 90/100)
        //turquois
        //navigationBar.barTintColor = UIColor.init(red: 23/255, green: 250/255, blue: 247/255, alpha: 100/100)
        
        //------------ナビゲーションバーの背景色-----------------
        //パターン1 水色薄グレー
        //navigationBar.barTintColor = UIColor.init(red: 90/255, green: 200/255, blue: 250/255, alpha: 1)
        
        //パターン2 オレンジ薄グレーあ
        //navigationBar.barTintColor = UIColor.init(red:255/255, green:192/255, blue: 167/255, alpha: 100/100)
        
        //パターン3 医療着の色薄グレー
        //navigationBar.barTintColor = UIColor.init(red:184/255, green:241/255, blue: 255/255, alpha: 100/100)
        
        //パターン4 メディブックロゴ
        //navigationBar.barTintColor = UIColor.init(red: 3/255, green:32/255, blue: 41/255, alpha: 35/100)
        
        //パターン５　ターコイズターコイズ
        //navigationBar.barTintColor = UIColor.init(red:20/255, green:217/255, blue: 217/255, alpha: 85/100)
        
        //パターン6 濃い緑
            // navigationBar.barTintColor = UIColor.init(red:0/255, green:102/255, blue: 102/255, alpha: 100/100)
        
         navigationBar.barTintColor = UIColor.init(red:0/255, green:139/255, blue: 139/255, alpha: 100/100)
        //薄い灰色
        //navigationBar.barTintColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        //ツルハ
        //navigationBar.barTintColor = UIColor.red
        
        
        // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
        navigationBar.tintColor = .black
        // ナビゲーションバーのテキストを変更する
        navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.black
            //.foregroundColor: UIColor.white
            //.foregroundColor: UIColor.init(red:20/255, green:217/255, blue: 217/255, alpha: 85/100)
    
        ]
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
