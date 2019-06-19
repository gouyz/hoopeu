//
//  HOOPARCControlVC.swift
//  hoopeu
//  空调遥控器
//  Created by gouyz on 2019/2/28.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPARCControlVC: GYZBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "空调遥控器"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_device_setting")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(clickedSettingBtn))
        
        setUpUI()
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(onOffBtn)
        bgView.addSubview(iconView)
        iconView.addSubview(tempLab)
        bgView.addSubview(windBigBtn)
        bgView.addSubview(windLab)
        bgView.addSubview(windSmallBtn)
        bgView.addSubview(modelBtn)
        bgView.addSubview(saoFengBtn)
        bgView.addSubview(tempPlusBtn)
        bgView.addSubview(tempDesLab)
        bgView.addSubview(tempMinusBtn)
        bgView.addSubview(coldModelBtn)
        bgView.addSubview(hotModelBtn)
        bgView.addSubview(coldLab)
        bgView.addSubview(hotLab)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.bottom.equalTo(-20)
        }
        onOffBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(bgView)
            make.top.equalTo(20)
            make.size.equalTo(CGSize.init(width: 60, height: 30))
        }
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(onOffBtn.snp.bottom).offset(20)
            make.centerX.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: 230, height: 150))
        }
        tempLab.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        windBigBtn.snp.makeConstraints { (make) in
            make.left.equalTo(iconView)
            make.width.equalTo(60)
            make.height.equalTo(50)
            make.top.equalTo(iconView.snp.bottom).offset(20)
        }
        windLab.snp.makeConstraints { (make) in
            make.top.equalTo(windBigBtn.snp.bottom)
            make.left.right.height.equalTo(windBigBtn)
        }
        windSmallBtn.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(windBigBtn)
            make.top.equalTo(windLab.snp.bottom)
        }
        modelBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(iconView)
            make.top.width.height.equalTo(windBigBtn)
        }
        saoFengBtn.snp.makeConstraints { (make) in
            make.centerX.width.height.equalTo(modelBtn)
            make.top.equalTo(modelBtn.snp.bottom).offset(30)
        }
        tempPlusBtn.snp.makeConstraints { (make) in
            make.right.equalTo(iconView)
            make.top.width.height.equalTo(windBigBtn)
        }
        tempDesLab.snp.makeConstraints { (make) in
            make.top.equalTo(tempPlusBtn.snp.bottom)
            make.width.height.right.equalTo(tempPlusBtn)
        }
        tempMinusBtn.snp.makeConstraints { (make) in
            make.top.equalTo(tempDesLab.snp.bottom)
            make.width.height.right.equalTo(tempPlusBtn)
        }
        
        coldModelBtn.snp.makeConstraints { (make) in
            make.left.width.height.equalTo(windBigBtn)
            make.top.equalTo(windSmallBtn.snp.bottom).offset(20)
        }
        coldLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(coldModelBtn)
            make.top.equalTo(coldModelBtn.snp.bottom)
            make.height.equalTo(30)
        }
        
        hotModelBtn.snp.makeConstraints { (make) in
            make.right.width.height.equalTo(tempMinusBtn)
            make.top.equalTo(coldModelBtn)
        }
        hotLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(hotModelBtn)
            make.top.height.equalTo(coldLab)
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    
    /// 开关
    lazy var onOffBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kRedFontColor
        btn.setImage(UIImage.init(named: "icon_arc_on_off"), for: .normal)
        btn.tag = 101
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_arc_temp_bg"))
    
    ///温度
    lazy var tempLab : UILabel = {
        let lab = UILabel()
        lab.font = UIFont.boldSystemFont(ofSize: 32)
        lab.textColor = kHeightGaryFontColor
        lab.text = "28℃"
        lab.textAlignment = .center
        
        return lab
    }()
    
    /// 风力大
    lazy var windBigBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setImage(UIImage.init(named: "icon_arc_arrow_up"), for: .normal)
        btn.tag = 102
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///风力
    lazy var windLab : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.textAlignment = .center
        lab.text = "风力"
        
        return lab
    }()
    /// 风力小
    lazy var windSmallBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setImage(UIImage.init(named: "icon_arc_arrow_down"), for: .normal)
        btn.tag = 103
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 模式
    lazy var modelBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("模式", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 104
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 扫风
    lazy var saoFengBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("扫风", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 109
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    /// 温度+
    lazy var tempPlusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k18Font
        btn.tag = 105
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///温度
    lazy var tempDesLab : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.textAlignment = .center
        lab.text = "温度"
        
        return lab
    }()
    /// 温度-
    lazy var tempMinusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("-", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k18Font
        btn.tag = 106
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    /// 制冷
    lazy var coldModelBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setImage(UIImage.init(named: "icon_arc_cold"), for: .normal)
        btn.tag = 107
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///制冷
    lazy var coldLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "制冷"
        
        return lab
    }()
    /// 制热
    lazy var hotModelBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setImage(UIImage.init(named: "icon_arc_hot"), for: .normal)
        btn.tag = 108
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///制热
    lazy var hotLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "制热"
        
        return lab
    }()
    /// 操作
    @objc func clickedOperatorBtn(btn: UIButton){
        
    }
    /// 设置
    @objc func clickedSettingBtn(){
        GYZAlertViewTools.alertViewTools.showSheet(title: nil, message: nil, cancleTitle: "取消", titleArray: ["自定义","删除"], viewController: self) { [weak self](index) in
            
            if index == 0{//自定义
            }else if index == 1{//删除
                self?.showDeleteAlert()
            }
        }
    }
    
    /// 删除
    func showDeleteAlert(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除此遥控器吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
            }
        }
    }
}
