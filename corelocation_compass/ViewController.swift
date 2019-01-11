//
//  ViewController.swift
//  corelocation_compass
//
//  Created by 大江祥太郎 on 2019/01/09.
//  Copyright © 2019年 shotaro. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    //ロケーションマネージャーを作る
    var locationManager = CLLocationManager()
    
    

    @IBOutlet weak var idoLabel: UILabel!
    @IBOutlet weak var keidoLabel: UILabel!
    @IBOutlet weak var hyoukouLabel: UILabel!
    @IBOutlet weak var henkakuLabel: UILabel!
    @IBOutlet weak var houiLabel: UILabel!
    
    //真北を選ぶセグメントコントロール
    @IBOutlet weak var jihokuSeg: UISegmentedControl!
    
    @IBOutlet weak var compass: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ラベルの初期化
        disabledLocationLabel()
        //アプリの利用中位置情報の利用許可を得る
        locationManager.requestWhenInUseAuthorization()
        
        //ロケーションマネージャのdelegateになる
        locationManager.delegate = self
        //ロケーション機能の設定
        setupLocationService()
        //コンパス機能を開始する
        startHeadingService()
        
        
    }
    
    //ロケーション機能の設定
    func setupLocationService(){
        //ロケーションの制度を設定する
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //更新距離
        locationManager.distanceFilter = 1
        
    }
    
    //位置情報利用許可のステータスが変わった
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways,.authorizedWhenInUse:
            //ロケーションの更新を開始する
            locationManager.startUpdatingLocation()
        case .notDetermined:
            //ロケーションの更新を停止する
            locationManager.stopUpdatingLocation()
            disabledLocationLabel()
        default:
            //ロケーションの更新を停止する
            locationManager.stopUpdatingLocation()
            disabledLocationLabel()
        }
    }
    
    func disabledLocationLabel(){
        idoLabel.adjustsFontSizeToFitWidth = true
        keidoLabel.adjustsFontSizeToFitWidth = true
        hyoukouLabel.adjustsFontSizeToFitWidth = true
        let msg = "位置情報の利用が許可されていない。"
        idoLabel.text = msg
        keidoLabel.text = msg
        hyoukouLabel.text = msg
    }
    
    //位置を移動した
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locationsの最後の値を取り出す
        let locationData = locations.last
        
        //緯度
        if var ido = locationData?.coordinate.latitude {
            //下6桁で四捨五入します
            ido = round(ido*1000000)/1000000
            idoLabel.text = String(ido)
        }
        
        //経度
        if var keido = locationData?.coordinate.longitude {
            //下6桁で四捨五入します
            keido = round(keido*1000000)/1000000
            keidoLabel.text = String(keido)
        }
        
        //標高
        if var hyoukou = locationData?.altitude {
            //下2桁で四捨五入
            hyoukou = round(hyoukou*100)/100
            hyoukouLabel.text = String(hyoukou)+"m"
        }
    }
    
    func startHeadingService(){
        //セグメントコントロールで磁北を選択する
        jihokuSeg.selectedSegmentIndex = 0
        //自分が向いている方向をデバイスのポートレートの向きにする
        locationManager.headingOrientation = .portrait
        //ヘディングの更新角度
        locationManager.headingFilter = 1
        //ヘディングの更新を開始する
        locationManager.startUpdatingHeading()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //真北
        let makita = newHeading.trueHeading
        
        //磁北
        let jihoku = newHeading.magneticHeading
        
        //偏角
        var henkaku = jihoku - makita
        if henkaku < 0 {
            henkaku = henkaku + 360
        }
        henkaku = round(henkaku*100)/100
        henkakuLabel.text = String(henkaku)
        
        //北の方向
        var kitamuki:CLLocationDirection!
        
        if jihokuSeg.selectedSegmentIndex == 0 {
            kitamuki = jihoku
        }else{
            kitamuki = makita
        }
        
        //磁針で北を指す
        compass.transform = CGAffineTransform(rotationAngle: CGFloat(-kitamuki*Double.pi/180))
        
        //デバイスが向いている方位角度
        let houikaku = round(kitamuki*100)/100
        houiLabel.text = String(houikaku)
        
    }

}

