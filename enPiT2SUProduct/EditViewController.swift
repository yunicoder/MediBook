//
//  EditViewController.swift
//  enPiT2SUProduct
//
//  Created by Takuma Yabe on 2019/11/23.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import UIKit
import SwiftyJSON

class EditViewController: UIViewController,UITextViewDelegate{
    var mediInfo = [MediData]() // 保存されている薬の全データ
    var sendedData: MediData? // 送られてくる薬のデータ
    var isFavFlag:Bool? // お気に入りボタン用のフラグ
    var interactions = Dictionary<String, String>()//併用情報
    
    var isMorningRemind = false
    var isDayRemind = false
    var isNightRemind = false
    
    // Outlet接続
    @IBOutlet weak var mediName: UILabel! // 薬の名前
    @IBOutlet weak var mediImage: UIImageView! // 薬の画像
    @IBOutlet weak var isPossessionSwitch: UISwitch! // 保持中スイッチ
    @IBOutlet weak var isPossessionLabel: UILabel! // 保持中かどうかのラベル
    @IBOutlet weak var isFavButton: UIButton! // お気に入りかどうかのボタン
    @IBOutlet weak var mediCaption: UILabel! //薬の説明
    @IBOutlet weak var mediGenre: UILabel!
    @IBOutlet weak var memo: UITextView!
    
    //リマインダーボタン
    @IBOutlet weak var morning: UIButton!
    @IBOutlet weak var day: UIButton!
    @IBOutlet weak var night: UIButton!
    
    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var View3: UIView!
    @IBOutlet weak var View5: UIView!
    @IBOutlet weak var View6: UIView!
    
    @IBOutlet weak var CollapseView: UIView! // ReadMoreのためのスタックビュー用のビュー
    @IBOutlet weak var expandButton: UIButton! // ReadMoreのためのボタン
    
    
    var genreID:String = ""
    
    
    @IBOutlet weak var interactionImage: UIImageView!
    @IBOutlet weak var interactionLabel: UILabel!
    @IBOutlet weak var interactionButton: UIButton!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediInfo = loadMediInfo() // 全データのロード
        
        addHistoryInfo(sendedData!) // 閲覧履歴を更新
        
        //カメラから情報を受け取る時
        //var displayInfo = mediInfo.filter({ $0.itemcode == sendedData?.itemcode})[0]
        // Tag番号を使ってLabelのインスタンス生成
        //let label = view.viewWithTag(1) as! UILabel
        //label.text = displayInfo[0].name
        
        
        View1.layer.borderColor = UIColor.gray.cgColor
        View1.layer.borderWidth = 0.3
        View2.layer.borderColor = UIColor.gray.cgColor
        View2.layer.borderWidth = 0.3
        View3.layer.borderColor = UIColor.gray.cgColor
        View3.layer.borderWidth = 0.3
//        View4.layer.borderColor = UIColor.black.cgColor
//        View4.layer.borderWidth = 0.5
        View5.layer.borderColor = UIColor.gray.cgColor
        View5.layer.borderWidth = 0.3
        View6.layer.borderColor = UIColor.gray.cgColor
        View6.layer.borderWidth = 0.3
       
        
        // 枠のカラー
        memo.layer.borderColor = UIColor.black.cgColor
        // 枠の幅
        memo.layer.borderWidth = 1.0
        // 枠を角丸にする場合
        memo.layer.cornerRadius = 10.0
        memo.layer.masksToBounds = true
        
        
        //mediの情報を表示
        mediName.text = sendedData!.name // 名前
        mediName.adjustsFontSizeToFitWidth = true // 文字が見切れないようにフォントサイズを設定
        mediImage.image =  getImageByUrl(url: sendedData!.imgUrl) // 画像
        isPossessionSwitch.isOn = sendedData!.isPossession // 保持中かどうかのスイッチ
        isPossessionLabel.text = isPossessionSwitch.isOn ? "保持中":"非保持" // 保持中かのラベル
        isFavFlag = sendedData!.isFav // お気に入りかどうかのボタン
        if #available(iOS 13.0, *) { // ios13以降じゃないとデフォルトのアイコン使えないらしい
            let isfavImage = isFavFlag! ? UIImage(systemName: "star.fill") : UIImage(systemName: "star") 
            isFavButton.setImage(isfavImage, for: .normal) // お気に入りの時はfill、そうでない時はstarを表示
        } else { // 前のバージョンの時はとりあえずテキストを入れとく
            // Fallback on earlier versions
            isFavButton.titleLabel?.text = isFavFlag! ? "お気に入り設定中" : "お気に入り解除中"
        }
        //リマインダー
        sendedData!.isRemind[0] = !sendedData!.isRemind[0]
        sendedData!.isRemind[1] = !sendedData!.isRemind[1]
        sendedData!.isRemind[2] = !sendedData!.isRemind[2]
        morningReminder(morning)
        dayReminder(day)
        nightReminder(night)
        
        
        //楽天APIから情報取得
        getURL()
        //ジャンル表示
        if(sendedData!.genre == "分類なし"){
            getGenre()
        }
        self.mediGenre.text = self.sendedData!.genre
        //メモ表示
        memo.text = sendedData!.memo
        
        //併用情報表示
        let possessionMediInfo = mediInfo.filter({ $0.isPossession == true}) // 所持中の薬のみ
        let otcList = ExpandCSV(filename: "./DataList/otc_list")
        let d1 = otcList.vlookup(key: sendedData!.itemcode, index: 6) ?? ""
        
        for m in possessionMediInfo {
            if m.itemcode != sendedData!.itemcode {
                let d2 = otcList.vlookup(key: m.itemcode, index: 6) ?? ""
                let tmp = searchInteraction(d1, d2)
                interactions[m.itemcode] = tmp
                if tmp == "併用注意" && interactionLabel!.text == "危険情報なし"{
                    if #available(iOS 13.0, *) {
                        interactionImage.image = UIImage(systemName: "triangle")
                        interactionImage.tintColor = UIColor.systemYellow
                    }
                    interactionLabel!.text = "併用注意"
                    interactionLabel!.textColor = UIColor.systemYellow
                }
                if tmp == "併用禁忌"{
                    if #available(iOS 13.0, *) {
                        interactionImage.image = UIImage(systemName: "xmark")
                        interactionImage.tintColor = UIColor.red
                    }
                    interactionLabel!.text = "併用禁忌"
                    interactionLabel!.textColor = UIColor.red
                }
            }
        }
        interactionButton.layer.borderWidth = 0.5                                              // 枠線の幅
        interactionButton.layer.borderColor = UIColor.black.cgColor                            // 枠線の色
        interactionButton.layer.cornerRadius = 5.0
       
    }
    
    
    //MyCombinationへ移動
    @IBAction func InteractionButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toMyCombination",sender: nil)
    }
    //performSegue内部で呼ばれるメソッドのオーバーライド（次の画面への値渡し）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyCombination" {
            let svc = segue.destination as! MyCombinatonSearchViewController
            svc.interactions = interactions
            svc.selectedMediCode = sendedData!.itemcode
        }
    }
    
    @IBAction func isFavButtonPush(_ sender: Any) {
        isFavFlag = isFavFlag! ? false : true
        if #available(iOS 13.0, *) { // ios13以降じゃないとデフォルトのアイコン使えないらしい
            let isfavImage = isFavFlag! ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            isFavButton.setImage(isfavImage, for: .normal) // お気に入りの時はfill、そうでない時はstarを表示
        } else { // 前のバージョンの時はとりあえずテキストを入れとく
            // Fallback on earlier versions
            isFavButton.titleLabel?.text = isFavFlag! ? "お気に入り設定中" : "お気に入り解除中"
        }
        sendedData?.isFav = isFavFlag! // お気に入りかどうか切り替え
        addMediInfo(sendedData!) // 編集している薬のデータを追加する
    }
    // 所持中ボタンが押された時
    @IBAction func isPossessionSwitchTapped(_ sender: UISwitch) {
        if sender.isOn{ // onの時
            sendedData!.isPossession = true
            isPossessionLabel.text = "保持中"
        }else{ // offの時
            sendedData!.isPossession = false
            isPossessionLabel.text = "非保持"
        }
        addMediInfo(sendedData!) // 編集している薬のデータを追加する
    }
    
    //リマインダー
    @IBAction func morningReminder(_ sender: UIButton) {
        sendedData!.isRemind[0] = !sendedData!.isRemind[0] //切り替え
        if #available(iOS 13.0, *) { // ios13以降じゃないとデフォルトのアイコン使えないらしい
            if(sendedData!.isRemind[0]){
                morning.setImage(UIImage(systemName: "sunrise.fill"), for: .normal)
                morning.setTitleColor(UIColor.orange, for: .normal)
                morning.tintColor = UIColor.orange
            }
            else{
                morning.setImage(UIImage(systemName: "sunrise"), for: .normal)
                morning.setTitleColor(UIColor.gray, for: .normal)
                morning.tintColor = UIColor.gray
            }
        }
        addMediInfo(sendedData!) // 編集している薬のデータを追加する
    }
    @IBAction func dayReminder(_ sender: UIButton) {
        sendedData!.isRemind[1] = !sendedData!.isRemind[1] //切り替え
        if #available(iOS 13.0, *) { // ios13以降じゃないとデフォルトのアイコン使えないらしい
            if(sendedData!.isRemind[1]){
                day.setImage(UIImage(systemName: "cloud.sun.fill"), for: .normal)
                day.setTitleColor(UIColor.orange, for: .normal)
                day.tintColor = UIColor.orange
            }
            else{
                day.setImage(UIImage(systemName: "cloud.sun"), for: .normal)
                day.setTitleColor(UIColor.gray, for: .normal)
                day.tintColor = UIColor.gray
            }
        }
        addMediInfo(sendedData!) // 編集している薬のデータを追加する
    }
    @IBAction func nightReminder(_ sender: UIButton) {
        sendedData!.isRemind[2] = !sendedData!.isRemind[2] //切り替え
        if #available(iOS 13.0, *) { // ios13以降じゃないとデフォルトのアイコン使えないらしい
            if(sendedData!.isRemind[2]){
                night.setImage(UIImage(systemName: "moon.zzz.fill"), for: .normal)
                night.setTitleColor(UIColor.orange, for: .normal)
                night.tintColor = UIColor.orange
            }
            else{
                night.setImage(UIImage(systemName: "moon.zzz"), for: .normal)
                night.setTitleColor(UIColor.gray, for: .normal)
                night.tintColor = UIColor.gray
            }
        }
        addMediInfo(sendedData!) // 編集している薬のデータを追加する
    }
    
    // 保存ボタンが押された時
    @IBAction func pushSaveButton(_ sender: Any) {
        sendedData?.memo = memo.text // メモ欄にあるメモを薬のデータに追加
        addMediInfo(sendedData!) // 編集している薬のデータを追加する
        okalert() //保存完了のアラートを表示
    }
    
    // 保存完了のアラートを表示
    func okalert(){
      let okalert = UIAlertController(title: "メモを保存しました。",
                     message: nil, preferredStyle: .alert) // 保存した旨を知らせるアラートを表示
      let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        // okを押した後の処理をここで書くので、多分ここにアンウィンドセグエをコードだけで書くとうまくいくはず
        self.navigationController?.popToRootViewController(animated: true)
      }
       
      //アラートに設定を反映させる
      okalert.addAction(okAction)
      present(okalert, animated: true)
       
    }
    
    //JSO入手
    func getURL(){
        let url = URL(string: "https://app.rakuten.co.jp/services/api/IchibaItem/Search/20170706?format=json&itemCode="+sendedData!.itemcode+"&applicationId=1090319832973970265")
        
        // セマフォを0で初期化
        let semaphore = DispatchSemaphore(value: 0)
        var cap = ""
        var gen = ""
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {return}
            do {
                let json = try? JSON(data: data)
                cap = json!["Items"][0]["Item"]["itemCaption"].rawString()!
                gen = json!["Items"][0]["Item"]["genreId"].rawString()!
                // セマフォをインクリメント（+1）
                semaphore.signal()
            }
            }.resume()
        // セマフォをデクリメント（-1）、ただしセマフォが0の場合はsignal()の実行を待つ
        semaphore.wait()
        self.mediCaption.text = cap
        self.genreID = gen
    }
    
    //ジャンル
    func getGenre() {
        let url = URL(string:"https://app.rakuten.co.jp/services/api/IchibaGenre/Search/20140222?format=json&genreId="+genreID+"&applicationId=1090319832973970265")
        
         URLSession.shared.dataTask(with: url!) { (data, response, error) in
             guard let data = data else {return}
             do {
                 let json = try? JSON(data: data)
                 DispatchQueue.global().sync {
                     DispatchQueue.main.sync {
                        self.sendedData?.genre = json!["parents"][3]["parent"]["genreName"].rawString()!
                        self.mediGenre.text = self.sendedData!.genre
                     }
                 }
             }
             }.resume()
    }
    
    // キャプションのreadMoreボタンが押された時
    @IBAction func readMorePushed(_ sender: UIButton) {
        CollapseView.isHidden.toggle() // CollapseViewを消すことで制約を無くす

        UIView.performWithoutAnimation {
            self.expandButton.setTitle(CollapseView.isHidden ? "閉じる" : "もっと見る", for: .normal) // isHiddenがtrueかそどうかでボタンの文字を変える
            self.expandButton.layoutIfNeeded()
        }

//        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveLinear], animations: {
//            self.mediCaption.superview?.layoutIfNeeded()
//        })
    }
    
    override func viewWillAppear(_ animated: Bool) {

       super.viewWillAppear(animated)
       self.configureObserver()

   }

   override func viewWillDisappear(_ animated: Bool) {

       super.viewWillDisappear(animated)
       self.removeObserver() // Notificationを画面が消えるときに削除
   }

   // Notificationを設定
   func configureObserver() {

       let notification = NotificationCenter.default
    notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
   }

   // Notificationを削除
   func removeObserver() {

       let notification = NotificationCenter.default
       notification.removeObserver(self)
   }

   // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillShow(notification: Notification?) {

    let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
       UIView.animate(withDuration: duration!, animations: { () in
           let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
           self.view.transform = transform

       })
   }

   // キーボードが消えたときに、画面を戻す
    
    @objc func keyboardWillHide(notification: Notification?) {

    let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
       UIView.animate(withDuration: duration!, animations: { () in

           self.view.transform = CGAffineTransform.identity
       })
   }

}

