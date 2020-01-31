//
//  ModalViewContorller.swift
//  barcodetest
//
//  Created by 片岡秀斗 on 2019/11/27.
//  Copyright © 2019 Shuto Kataoka. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ModalViewController: UIViewController {
    
    var receiveText: String?
    var mediData: MediData?

    @IBOutlet weak var drugimage: UIImageView!
    
    
    @IBOutlet weak var DrugName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setlabel()
        URLget()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    }
    
    func setlabel() {
        DrugName.lineBreakMode = .byWordWrapping
        DrugName.numberOfLines = 3
    }

    func URLget(){
        //receiveText = String(receiveText!.prefix(receiveText!.count - 2))
        let url = URL(string: "https://app.rakuten.co.jp/services/api/IchibaItem/Search/20170706?format=json&keyword="+receiveText!+"&applicationId=1090319832973970265")
        
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {return}
            do {
                let json = try? JSON(data: data)
                for (key: _, subJson: JSON) in json!["Items"] {
                    if let medi = createMadiDataFromJson(json: JSON){
                        self.mediData = medi
                    }
                }
                
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        if self.mediData != nil{
                            self.DrugName.text = self.mediData!.name
                            self.drugimage.image = self.getImageByUrl(url: self.mediData!.imgUrl)
                        }
                        else{
                            self.DrugName.text = "エラー"
                        }
                    }
                }
            }
            }.resume()
    }

    func getImageByUrl(url: String) -> UIImage{
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditsegue" {
            let svc = segue.destination as! EditViewController
                svc.sendedData = mediData
        }
    }
}
