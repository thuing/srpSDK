//
//  ViewController.swift
//  srpSDKTestDemo
//
//  Created by 小福 on 2019/3/19.
//  Copyright © 2019 小福. All rights reserved.
//

import UIKit
import srpSDKFramework

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cid = "8aac99bfdff6870b28f74fcfb191a2e9"
        let salt = "eab7276e67ff445f96d3a995578c0c00"
        let phone = "13818120453"
        
        
        // 调用srp 完成三部整体过程
        let srp = srpLink()
        srp.srpRegister(cid: cid, salt: salt, phone: phone)

    }
    
}
