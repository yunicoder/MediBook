//
//  RemindViewController.swift
//  enPiT2SUProduct
//
//  Created by Takuma Yabe on 2019/11/23.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//
import Foundation
import UIKit

class RemindViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
            
    
    var Mediinfo = [MediData]()
    var MorningMedis = [MediData]()
    var NoonMedis = [MediData]()
    var EveningMedis = [MediData]()
    let formatter = DateFormatter()
    let DrugAlarmManager = LocalAlarm()
    var settime: Date?
    let DrugAlarmIds = ["DrugAlarmforMorning","DrugAlarmforNoon","DrugAlarmforEvening"]
    let center = UNUserNotificationCenter.current()
    
    @IBOutlet weak var morningView: UIView!
    @IBOutlet weak var noonView: UIView!
    @IBOutlet weak var eveningView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //aaa
        // Do any additional setup after loading the view.
        setdateformat()
        comformSwitch()
        
        Mediinfo = loadMediInfo()
        MorningMedis = Mediinfo.filter({$0.isRemind[0]})
        NoonMedis = Mediinfo.filter({$0.isRemind[1]})
        EveningMedis = Mediinfo.filter({$0.isRemind[2]})
        
        MorningCollectionView.delegate = self
        MorningCollectionView.dataSource = self
        NoonCollectionView.delegate = self
        NoonCollectionView.dataSource = self
        EveningCollectionView.delegate = self
        EveningCollectionView.dataSource = self
        
        layoutInit(collectionView: MorningCollectionView)
        layoutInit(collectionView: NoonCollectionView)
        layoutInit(collectionView: EveningCollectionView)
        
        noonView.layer.borderWidth = 1.0
        noonView.layer.borderColor = UIColor.lightGray.cgColor
        

    }
    
    // ビューの上に線を引く関数
    func writeTopBorder(view:UIView){
        let topBorder = CALayer() //上線のCALayerを作成
        topBorder.frame = CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.size.width, height: 1.0) // widthは表示画面いっぱいに
        topBorder.backgroundColor = UIColor.lightGray.cgColor // 色を指定
        view.layer.addSublayer(topBorder)
    }

    func setdateformat(){
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
    }

    //各種outlet
    @IBOutlet weak var morningField: DatePickerKeyboard!
    @IBOutlet weak var noonField: DatePickerKeyboard!
    @IBOutlet weak var eveningField: DatePickerKeyboard!
    

    @IBOutlet weak var morningSwitch: UISwitch!
    @IBOutlet weak var noonSwitch: UISwitch!
    @IBOutlet weak var eveningSwitch: UISwitch!

    
    @IBAction func morningSwich(_ sender: UISwitch) {
        switchaction(flag: morningSwitch.isOn, DateField: morningField, num: 0)
    }
    
    @IBAction func noonSwich(_ sender: UISwitch) {
        switchaction(flag: noonSwitch.isOn, DateField: noonField, num: 1)
    }
    
    @IBAction func eveningSwich(_ sender: UISwitch) {
        switchaction(flag: eveningSwitch.isOn, DateField: eveningField, num: 2)
    }
    
    //switchがonとoffの時に呼ばれる処理
    func switchaction(flag: Bool,DateField: DatePickerKeyboard,num: Int){
        if flag{
            settime = DateField.getDate()
            if settime != nil{
                DrugAlarmManager.setlocalnotice(setDate: settime!, identifier: DrugAlarmIds[num])
            }
        }
        else{
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [DrugAlarmIds[num]])
        }
    }

    
    //switchの状態を反映する
    func comformSwitch(){
        center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
            for request in requests {
                for (index,element) in self.DrugAlarmIds.enumerated() {
                    if request.identifier == element{
                        let trigger = request.trigger as! UNCalendarNotificationTrigger
                        let components = DateComponents(calendar: Calendar.current,hour: trigger.dateComponents.hour, minute: trigger.dateComponents.minute)
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                switch index {
                                case 0:
                                    self.morningSwitch.isOn = true
                                    self.morningField.text = self.formatter.string(from: components.date!)
                                case 1:
                                    self.noonSwitch.isOn = true
                                    self.noonField.text = self.formatter.string(from: components.date!)
                                case 2:
                                    self.eveningSwitch.isOn = true
                                    self.eveningField.text = self.formatter.string(from: components.date!)

                                default: break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //collectionview設定用関数群
    //まずはoutlet
    @IBOutlet weak var MorningCollectionView: UICollectionView!
    @IBOutlet weak var NoonCollectionView: UICollectionView!
    @IBOutlet weak var EveningCollectionView: UICollectionView!
    //CollectionViewのレイアウトの設定
    func layoutInit(collectionView: UICollectionView){
        // レイアウトを調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5) // マージン
        collectionView.collectionViewLayout = layout
        
        layout.scrollDirection = .horizontal // 横スクロール
        
    }
    
    func ColumnGenerate(indexPath: IndexPath,CollectionView: UICollectionView,Cellname :String,Medidata: [MediData])-> UICollectionViewCell{
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: Cellname, for: indexPath) // 表示するセルを登録(先にStoryboad内でidentifierを指定しておく)
        if let nameLabel = cell.contentView.viewWithTag(1) as? UILabel {
            nameLabel.text = Medidata[indexPath.row].name
            nameLabel.adjustsFontSizeToFitWidth = true // 文字が見切れないようにフォントサイズを設定
        }
        if let collectionImage = cell.contentView.viewWithTag(2) as? UIImageView {
            // cellの中にあるcollectionImageに画像を代入する
            collectionImage.image = getImageByUrl(url: Medidata[indexPath.row].imgUrl)
        }

        return cell
    }
    
    /*---collectionViewの委譲設定 開始---*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count:Int = 0
        if collectionView.tag == 1 {
            count = MorningMedis.count
        }
        else if collectionView.tag == 2 {
            count = NoonMedis.count
        }
        else if collectionView.tag == 3 {
            count = EveningMedis.count
        }
        return count // 表示するセルの数
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if collectionView.tag == 1 {
            cell = ColumnGenerate(indexPath: indexPath, CollectionView: MorningCollectionView, Cellname: "morningCell",Medidata: MorningMedis)
        }
        else if collectionView.tag == 2 {
            cell = ColumnGenerate(indexPath: indexPath, CollectionView: NoonCollectionView, Cellname: "noonCell",Medidata: NoonMedis)
        }
        else if collectionView.tag == 3 {
            cell = ColumnGenerate(indexPath: indexPath, CollectionView: EveningCollectionView, Cellname: "eveningCell", Medidata: EveningMedis)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // 全体レイアウトの設定
        return CGSize(width: 100, height: 100)
    }
    /*---collectionViewの設定の委譲など 終わり---*/
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // セグエによる画面遷移が行われる前に呼ばれるメソッド
        if (segue.identifier == "toEditFromMorning") { // 朝カラムにて「写真」が押された時
            let editVC: EditViewController = (segue.destination as? EditViewController)!
            let selectedRow = MorningCollectionView.indexPathsForSelectedItems! // 選ばれた
            editVC.sendedData = MorningMedis[selectedRow[0].row]
        }
        if (segue.identifier == "toEditFromNoon") { // 昼カラムにて「写真」が押された時
            let editVC: EditViewController = (segue.destination as? EditViewController)!
            let selectedRow = NoonCollectionView.indexPathsForSelectedItems! // 選ばれた
            editVC.sendedData = NoonMedis[selectedRow[0].row]
        }
        if (segue.identifier == "toEditFromEvening") { // 夜カラムにて「写真」が押された時
            let editVC: EditViewController = (segue.destination as? EditViewController)!
            let selectedRow = EveningCollectionView.indexPathsForSelectedItems! // 選ばれた
            editVC.sendedData = EveningMedis[selectedRow[0].row]
        }
    }
    
}
