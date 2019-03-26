//
//  frameworkTest.swift
//  srpSDKFramework
//
//  Created by 小福 on 2019/3/19.
//  Copyright © 2019 小福. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON
import BigInt
import Cryptor

// MARK: 自定义的一个首页视图
public class YLXHomeView: UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        let cid = "8aac99bfdff6870b28f74fcfb191a2e9"
        let salt = "eab7276e67ff445f96d3a995578c0c00"
        let phone = "13818120453"
        
        let srp = srpLink()
        srp.srpRegister(cid: cid, salt: salt, phone: phone)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 配置页面
    func setupUI() {
        addSubview(iconImgV)
    }
    
    lazy var iconImgV: UIImageView = {
        let view = UIImageView.init()
        view.backgroundColor = UIColor.red
        return view
    }()
    
    
}
