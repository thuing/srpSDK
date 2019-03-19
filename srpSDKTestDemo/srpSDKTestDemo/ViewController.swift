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
        
        setupUI()
    }
    
    // MARK: 配置页面
    func setupUI() {
        view.addSubview(homeV)
    }
    
    // MARK: 懒加载
    lazy var homeV: YLXHomeView  = {
        let view = YLXHomeView.init(frame: CGRect.init(x: 20, y: 20, width: 200, height: 50))
        return view
    }()
}
