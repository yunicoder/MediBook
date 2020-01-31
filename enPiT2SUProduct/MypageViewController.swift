//
//  MypageViewController.swift
//  enPiT2SUProduct
//
//  Created by Jun Ohkubo on 2019/09/04.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import UIKit

class MypageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    // 作成変数
    var mediInfo = [MediData]() // 薬の全データ
    var favoriteMediInfo = [MediData]() // お気に入りに登録されている薬の情報
    var historyMediInfo = [MediData]() // 閲覧履歴にある薬の情報
    var remindMediInfo = [MediData]() //リマインドカラムの薬の情報
    
    
    // Outlet接続
    @IBOutlet weak var AllScrollView: UIScrollView! //全画面縦のスクロール
    @IBOutlet weak var favoriteColumn: UIView! // お気に入りカラム全体のビュー
    @IBOutlet weak var historyColumn: UIView! // 閲覧履歴カラム全体のビュー
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //***************************
        //allDeleteHistoryInfo()  //履歴の削除
        //***************************
        
        // 擬似データの登録
        let tempMediInfo = [
            MediData(itemcode: "drug-pony:10530591", name: "ロキソニンSプレミアム", imgUrl: "https://thumbnail.image.rakuten.co.jp/@0_mall/drug-pony/cabinet/shohin/4987107619006.jpg?_ex=128x128", memo: "僕のお気に入りです", isPossession: false, isFav: true, genre: "頭痛・痛み止め", isRemind: [false, false, false]),
        MediData(itemcode: "drug-pony:10768170", name: "バファリンA", imgUrl: "https://thumbnail.image.rakuten.co.jp/@0_mall/drug-pony/cabinet/shohin3/4903301010982.jpg?_ex=128x128", memo: "よく頭痛の時に飲む", isPossession: true, isFav: true, genre: "頭痛・痛み止め", isRemind: [true, false, true]),
        MediData(itemcode: "drug-pony:10757307", name: "ベンザブロックSプラス", imgUrl: "https://thumbnail.image.rakuten.co.jp/@0_mall/drug-pony/cabinet/shohin/4987123700818.jpg?_ex=128x128", memo: "あまり効かない", isPossession: true, isFav: true, genre: "風邪", isRemind: [true, true, true]),
        MediData(itemcode: "drug-pony:10760123", name: "ガスター10", imgUrl: "https://thumbnail.image.rakuten.co.jp/@0_mall/drug-pony/cabinet/shohin/4987107600035.jpg?_ex=128x128", memo: "まあまいい", isPossession: true, isFav: false, genre: "胃腸薬", isRemind: [false, false, false])]
        mediInfo.append(contentsOf: tempMediInfo)
        saveMediInfoMulti(mediInfo) // 擬似データのセーブ
        
        favoriteCollectionView.delegate = self    // サイズやマージンなどレイアウトに関する処理の委譲
        favoriteCollectionView.dataSource = self  // 要素の数やセル、クラスなどデータの元となる処理の委譲
        layoutInit(collectionView: favoriteCollectionView) // レイアウトの設定
        favoriteMediInfo =  mediInfo.filter({ $0.isFav == true}) // お気に入りに登録してある薬のみのデータを取り出す

        historyCollectionView.delegate = self    // サイズやマージンなどレイアウトに関する処理の委譲
        historyCollectionView.dataSource = self  // 要素の数やセル、クラスなどデータの元となる処理の委譲
        layoutInit(collectionView: historyCollectionView) // レイアウトの設定
        historyMediInfo = loadHistoryInfo() // 閲覧履歴にある薬の情報をロード
        
        
        let num = conformReminds()
        remindCollectionView.delegate = self    // サイズやマージンなどレイアウトに関する処理の委譲
        remindCollectionView.dataSource = self  // 要素の数やセル、クラスなどデータの元となる処理の委譲
        layoutInit(collectionView: remindCollectionView) // レイアウトの設定
        setremindicon(num: num)

        remindColumnView.layer.borderColor = UIColor.systemOrange.cgColor // 枠線の色
        remindColumnView.layer.borderWidth = 1.0 // 枠線の太さ
        remindColumnView.layer.shadowOffset = CGSize(width: 0.0, height: 1)
        remindColumnView.layer.shadowRadius = 2.5
        remindColumnView.layer.shadowColor = UIColor.black.cgColor
        remindColumnView.layer.shadowOpacity = 0.5
        
        // カラムごとに上に線を引く
        writeTopBorder(view: favoriteColumn)
        writeTopBorder(view: historyColumn)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // データの再読み込み
        mediInfo = loadMediInfo() // mediInfoを再読み込み
        
        favoriteMediInfo =  mediInfo.filter({ $0.isFav == true}) // お気に入りに登録してある薬のみのデータを取り出す
        favoriteCollectionView.reloadData() // コレクションビューのリロード
        
        let num = conformReminds() //リマインドカラムの反映
        setremindicon(num: num)
        remindCollectionView.reloadData() //リロード
        
        historyMediInfo = loadHistoryInfo() // 閲覧履歴を更新
        historyCollectionView.reloadData() // コレクションビューのリロード
    }
    
    // ビューの上に線を引く関数
    func writeTopBorder(view:UIView){
        let topBorder = CALayer() //上線のCALayerを作成
        topBorder.frame = CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.size.width, height: 1.0) // widthは表示画面いっぱいに
        topBorder.backgroundColor = UIColor.lightGray.cgColor // 色を指定
        view.layer.addSublayer(topBorder)
    }

    
    //CollectionViewのレイアウトの設定
    func layoutInit(collectionView: UICollectionView){
        // レイアウトを調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5) // マージン
        collectionView.collectionViewLayout = layout
        
        layout.scrollDirection = .horizontal // 横スクロール
        
    }
    
    
    /*---お気に入りカラムの設定　開始---*/
    
    @IBOutlet weak var favoriteCollectionView: UICollectionView!

    // お気に入りカラムの作成関数
    func favoriteColumnGenerate(indexPath: IndexPath)-> UICollectionViewCell{
        let cell = favoriteCollectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) // 表示するセルを登録(先にStoryboad内でidentifierを指定しておく)
        cell.isHighlighted = true
        if let collectionImage = cell.contentView.viewWithTag(1) as? UIImageView {
            // cellの中にあるcollectionImageに画像を代入する
            collectionImage.image = getImageByUrl(url: favoriteMediInfo[indexPath.row].imgUrl)
        }
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            // cellの中にあるlabelに名前を代入する
            label.text = favoriteMediInfo[indexPath.row].name
            label.adjustsFontSizeToFitWidth = true // 文字が見切れないようにフォントサイズを設定
        }
        return cell
    }
    /*---お気に入りカラムの設定　終わり---*/
    
    
    
    /*---閲覧履歴カラム設定　開始---*/
    
    @IBOutlet weak var historyCollectionView: UICollectionView!
    
    // 閲覧履歴カラムの作成関数
    func historyColumnGenerate(indexPath: IndexPath)-> UICollectionViewCell{
        
        let cell = historyCollectionView.dequeueReusableCell(withReuseIdentifier: "historyCell", for: indexPath) // 表示するセルを登録(先にStoryboad内でidentifierを指定しておく)
        let cnt = historyMediInfo.count // 使用履歴に登録されている薬の個数
        if let collectionImage = cell.contentView.viewWithTag(1) as? UIImageView {
            // cellの中にあるcollectionImageに画像を代入する
            collectionImage.image = getImageByUrl(url: self.historyMediInfo[cnt - indexPath.row - 1].imgUrl)
        }
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            // cellの中にあるlabelに名前を代入する
            label.text = historyMediInfo[cnt - indexPath.row - 1].name
            label.adjustsFontSizeToFitWidth = true // 文字が見切れないようにフォントサイズを設定
        }
        return cell
    }
    
    // 閲覧履歴のクリアが押された時
    @IBAction func initHistoryTapped(_ sender: Any) {
        let alert = UIAlertController(title: "注意",message: "閲覧履歴を完全クリアしますか？",
                                      preferredStyle: .alert) // 完全クリアするのか確認アラートを表示
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in // OKの時
            allDeleteHistoryInfo() //閲覧履歴を全クリア
            self.historyMediInfo = loadHistoryInfo() // 閲覧履歴を更新
            self.historyCollectionView.reloadData() // コレクションビューのリロード
        }
         
        //アラートに設定を反映させる
        alert.addAction(UIAlertAction(title: "キャンセル", style: .default)) // キャンセルボタンの追加(何も起こらない)
        alert.addAction(okAction) // OKボタンの追加
        present(alert, animated: true)
    }
    
    /*---閲覧履歴カラム設定 終わり---*/
    
    /*----リマインドカラム設定　開始--*/
    @IBOutlet weak var remindCollectionView: UICollectionView!
    @IBOutlet weak var nextTimeLabel: UILabel! // 次の設定した時間を表示させるラベル
    @IBOutlet weak var nextIconImageView: UIImageView! // 次の時間のアイコンを表示させるイメージビュー
    @IBOutlet weak var remindColumnView: UIView! // リマインダーに登録されている薬のプレビューのビュー
    
    
    // リマインドカラムの作成関数
    func remindColumnGenerate(indexPath: IndexPath,Medidata: [MediData])-> UICollectionViewCell{
        let cell = remindCollectionView.dequeueReusableCell(withReuseIdentifier: "remindCell", for: indexPath) // 表示するセルを登録(先にStoryboad内でidentifierを指定しておく)
        if let nameLabel = cell.contentView.viewWithTag(2) as? UILabel {
            nameLabel.text = Medidata[indexPath.row].name
            nameLabel.adjustsFontSizeToFitWidth = true // 文字が見切れないようにフォントサイズを設定
        }
        if let collectionImage = cell.contentView.viewWithTag(3) as? UIImageView {
            // cellの中にあるcollectionImageに画像を代入する
            collectionImage.image = getImageByUrl(url: Medidata[indexPath.row].imgUrl)
        }

        return cell
    }
    
    //リマインドカラムに薬の設定を反映させる関数
    func conformReminds() -> Int{
        let center = UNUserNotificationCenter.current()
        let DrugAlarmIds = ["DrugAlarmforMorning","DrugAlarmforNoon","DrugAlarmforEvening"]
        var AlarmFlags = [false,false,false]
        var nextnum = 1
        let semaphore = DispatchSemaphore(value: 0)
        let formatter = DateFormatter()
        
        formatter.dateFormat = "HH:mm"
        var AlarmDates:[Date]? = [formatter.date(from: "07:00")!,formatter.date(from: "12:00")!,formatter.date(from: "19:00")!]
        
        center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
            for request in requests {
                let trigger = request.trigger as! UNCalendarNotificationTrigger
                for (index,element) in DrugAlarmIds.enumerated(){
                    if request.identifier == element {
                        AlarmDates?[index] =  trigger.nextTriggerDate()!
                        AlarmFlags[index] = true
                }
            }
        }
        semaphore.signal()
    }
        semaphore.wait()
        
        if AlarmFlags[0] && AlarmFlags[1] { //朝と昼の設定の確認
            if AlarmDates![1] > AlarmDates![0]{ //朝と昼が設定されていた場合、両者を比較
                if AlarmFlags[2] { //夜が設定されていた場合、それと比較
                    if AlarmDates![0] > AlarmDates![2] {
                        nextnum = 2
                    } else {
                        nextnum = 0
                    }
                } else {
                    nextnum = 0
                }
            }
            else {
                if AlarmFlags[2] { //昼の方が先の場合
                    if AlarmDates![2] > AlarmDates![1] { //昼の方が先
                        nextnum = 1
                    }
                    else {
                        //夜の方が先
                        nextnum = 2
                    }
                }
                else { //夜が未設定
                    nextnum = 1
                }
            }
        } else { //朝か昼が未設定
            if AlarmFlags[1] { //昼が設定されていれば
                if AlarmFlags[2] {
                    if AlarmDates![2] > AlarmDates![1] {
                        nextnum = 1
                    }
                    else {
                        nextnum  = 2
                    }
                } else {
                    nextnum = 1
                }
            }
            else { //昼が未設定
                if AlarmFlags[2] {
                    if AlarmDates![2] > AlarmDates![0] {
                        nextnum = 0
                    }
                    else {
                        nextnum = 2
                    }
                } else {
                    nextnum = 0
                }
            }
        }
        if !AlarmFlags[1] && !AlarmFlags[0] {
            nextnum = 2
        }

        // リマインドのnext表示
        self.remindMediInfo = self.mediInfo.filter({$0.isRemind[nextnum]})
        self.nextTimeLabel.text = formatter.string(from: AlarmDates![nextnum])
        self.remindCollectionView.reloadData()
        return nextnum
    }

    func setremindicon(num: Int) {
        if #available(iOS 13.0, *) { // ios13以降じゃないとデフォルトのアイコン使えないらしい
            switch num {
            case 0:
                nextIconImageView.image = UIImage(systemName: "sunrise")
            case 1:
                nextIconImageView.image = UIImage(systemName: "cloud.sun")
            case 2:
                nextIconImageView.image = UIImage(systemName: "moon.zzz")
            default:
                break
            }
        } else { // 前のバージョンの時は
            // Fallback on earlier versions
        }
    }
    /*---リマインドカラム設定 終わり---*/
    
    /*---collectionViewの委譲設定 開始---*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count:Int = 0
        if collectionView.tag == 1 {
            count = favoriteMediInfo.count
        }
        else if collectionView.tag == 2 {
            count = historyMediInfo.count
        }
        else if collectionView.tag == 3 {
            count = remindMediInfo.count
        }
        return count // 表示するセルの数
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if collectionView.tag == 1 {
            cell = favoriteColumnGenerate(indexPath: indexPath)
        }
        else if collectionView.tag == 2 {
            cell = historyColumnGenerate(indexPath: indexPath)
        }
        else if collectionView.tag == 3 {
            cell = remindColumnGenerate(indexPath: indexPath, Medidata: remindMediInfo)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // 全体レイアウトの設定
        var cgsize = CGSize(width: 100, height: 100) // デフォルトは100×100
        if collectionView.tag == 3 { // リマインドのコレクションビュー
            cgsize = CGSize(width: 80, height: 90)
        }
        return cgsize
    }
    /*---collectionViewの設定の委譲など 終わり---*/
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // セグエによる画面遷移が行われる前に呼ばれるメソッド
        if (segue.identifier == "toAllFromFav") { // お気に入りカラムにて「全て見る」が押された時
            let showAllVC: ShowAllViewController = (segue.destination as? ShowAllViewController)!
            showAllVC.titleText = "お気に入り"
            showAllVC.showAllMediInfo = favoriteMediInfo
            showAllVC.titleIconName = "heart.fill"
        }
        if (segue.identifier == "toAllFromHis") { // 閲覧履歴カラムにて「全て見る」が押された時
            let showAllVC: ShowAllViewController = (segue.destination as? ShowAllViewController)!
            showAllVC.titleText = "閲覧履歴(20件まで)"
            showAllVC.showAllMediInfo = historyMediInfo.reversed()
            showAllVC.titleIconName = "book"
        }
        if (segue.identifier == "toEditFromFav") { // お気に入りカラムにて「写真」が押された時
            let editVC: EditViewController = (segue.destination as? EditViewController)!
            let selectedRow = favoriteCollectionView.indexPathsForSelectedItems! // 選ばれた
            editVC.sendedData = favoriteMediInfo[selectedRow[0].row]
        }
        if (segue.identifier == "toEditFromHis") { // 閲覧履歴カラムにて「写真」が押された時
            let editVC: EditViewController = (segue.destination as? EditViewController)!
            let selectedRow = historyCollectionView.indexPathsForSelectedItems! // 選ばれた
            let cnt = historyMediInfo.count
            editVC.sendedData = historyMediInfo[cnt - selectedRow[0].row - 1]
        }
        if (segue.identifier == "toEditFromRemind") { // 閲覧履歴カラムにて「写真」が押された時
            let editVC: EditViewController = (segue.destination as? EditViewController)!
            let selectedRow = remindCollectionView.indexPathsForSelectedItems! // 選ばれた
            editVC.sendedData = remindMediInfo[selectedRow[0].row]
        }
    }
    
    
    @IBAction func unwindMy(segue: UIStoryboardSegue) {
    }
}


