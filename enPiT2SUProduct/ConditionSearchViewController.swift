//
//  ConditionSearchViewController.swift
//  enPiT2SUProduct
//
//  Created by Takuma Yabe on 2019/11/23.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import UIKit
import SwiftyJSON

class ConditionSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var searchText: String = ""
    var mediList = [MediData]()
    var selected = 0

    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // DataSourceの設定.
        table.dataSource = self
        // Delegateを設定.
        table.delegate = self
        //検索
         getMediData()
    }
    
    //viewWillは、viewが生成される前なので、
    //既にlabel.textが切り替わってるように見える
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
//    //前画面に戻る
//    @IBAction func backButton(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
    
    
    
    //セルの個数を指定するデリゲートメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediList.count
    }
    
    //セルに値を設定するデータソースメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // セルに表示する値を設定する
        cell.imageView!.image = getImageByUrl(url: mediList[indexPath.row].imgUrl)
        cell.textLabel!.text = mediList[indexPath.row].name
        return cell
    }
    
    //セルが押された時に呼び出されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath.row
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        // 別の画面に遷移
        performSegue(withIdentifier: "toEdit",sender: nil)
    }
    
    //performSegue内部で呼ばれるメソッドのオーバーライド（次の画面への値渡し）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            let svc = segue.destination as! EditViewController
            svc.sendedData = mediList[selected]
        }
    }
    
    func getMediData(){
        searchText = urlEncoded(str: searchText)
        let url = URL(string: "https://app.rakuten.co.jp/services/api/IchibaItem/Search/20170706?format=json&keyword="+searchText+"&genreId=201541&shopCode=drug-pony&applicationId=1090319832973970265")
       
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {return}
            do {
                let json = try? JSON(data: data)
                for (key: _, subJson: JSON) in json!["Items"] {
                    if let mediData = createMadiDataFromJson(json: JSON){
                        //データを配列に追加
                        self.mediList.append(mediData)
                        self.mediList = self.mediList.sorted(by: { (a, b) -> Bool in
                            return a.name < b.name
                        })
                        
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                //テーブルビュー更新
                                self.table.reloadData()
                            }
                        }
                    }
                }
            }
            }.resume()
    }
}
