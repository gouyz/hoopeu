//
//  HOOPEditSceneDoVC.swift
//  hoopeu
//  新建场景 叮当宝贝会做
//  Created by gouyz on 2019/2/25.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPEditSceneDoVC: GYZBaseVC {
    
    /// 选择结果回调
    var resultBlock:((_ doDic: [String: Any]) -> Void)?
    ///txtView 提示文字
    let placeHolder = "请输入您想让叮当宝贝做的事"
    //// 最大字数
    let contentMaxCount: Int = 500
    var isEdit: Bool = false
    var doTitle: String = ""
    var doType: String = ""
    var doContent: String = ""
    var doDesContent: String = "你想让叮当宝贝多久后执行下一操作（默认为1秒）"
    /// 选择时间换算为秒
    var selectSecond: Int = 1
    /// 分钟
    var minuteArr: [String] = [String]()
    /// 秒
    var secondArr: [String] = [String]()
    var tuiJianModels:[HOOPSceneTuiJianModel] = [HOOPSceneTuiJianModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = doTitle
        self.view.backgroundColor = kWhiteColor
        
        if isEdit {
            let rightBtn = UIButton(type: .custom)
            rightBtn.setTitle("删除", for: .normal)
            rightBtn.titleLabel?.font = k15Font
            rightBtn.setTitleColor(kRedFontColor, for: .normal)
            rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
            rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        }
        
        setUpUI()
        setData()
        contentTxtView.delegate = self
        
        if doContent.count > 0 {
            contentTxtView.text = doContent
            fontCountLab.text =  "\(doContent.count)/\(contentMaxCount)"
        }else{
            contentTxtView.text = placeHolder
        }
        
        iconTimeView.addOnClickListener(target: self, action: #selector(onClickedSelectTime))
        
        requestTuiJianList()
    }
    
    func setData(){
        for i in 0..<60 {
            if i < 11{
                minuteArr.append("\(i)")
            }
            secondArr.append("\(i)")
        }
        
//        if doType == "control" || doType == "sef_define"  {
//            if !isEdit{
//                selectSecond = 1
//            }
//            doDesContent = "你想让叮当宝贝多久后执行下一操作（默认为1秒）"
//            desContentLab.text = doDesContent
//            timeLab.text = "\(selectSecond / 60)分\(selectSecond % 60)秒"
//        }
    }
    
    func setUpUI(){
        view.addSubview(desLab)
        view.addSubview(bgView)
        bgView.addSubview(contentTxtView)
        bgView.addSubview(fontCountLab)
        view.addSubview(doLab)
        view.addSubview(doLab1)
        view.addSubview(doLab2)
        view.addSubview(doLab3)
        view.addSubview(doLab4)
        view.addSubview(doLab5)
        view.addSubview(desTimeLab)
        view.addSubview(timeLab)
        view.addSubview(iconTimeView)
        view.addSubview(lineView)
        view.addSubview(desContentLab)
        view.addSubview(saveBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.equalTo(kTitleAndStateHeight + kMargin)
            make.size.equalTo(CGSize.init(width: kTitleHeight, height: 20))
        }
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(desLab.snp.bottom).offset(kMargin)
            make.height.equalTo(100)
        }
        contentTxtView.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.bottom.equalTo(fontCountLab.snp.top)
        }
        fontCountLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentTxtView)
            make.bottom.equalTo(-5)
            make.height.equalTo(20)
        }
        doLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(doLab1.snp.left).offset(-20)
            make.top.equalTo(bgView.snp.bottom).offset(20)
            make.height.equalTo(kTitleHeight)
            make.width.equalTo(doLab1)
        }
        doLab1.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.top.height.width.equalTo(doLab)
        }
        doLab2.snp.makeConstraints { (make) in
            make.left.height.equalTo(doLab)
            make.right.equalTo(doLab3.snp.left).offset(-20)
            make.top.equalTo(doLab.snp.bottom).offset(kMargin)
            make.width.equalTo(doLab3)
        }
        doLab3.snp.makeConstraints { (make) in
            make.right.equalTo(doLab1)
            make.top.height.width.equalTo(doLab2)
        }
        doLab4.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(doLab5.snp.left).offset(-20)
            make.top.equalTo(doLab2.snp.bottom).offset(kMargin)
            if doType == "sef_define"{//自定义时显示6个推荐，其他显示4个
                make.height.equalTo(kTitleHeight)
            }else{
                make.height.equalTo(0)
            }
            make.width.equalTo(doLab5)
        }
        doLab5.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.top.height.width.equalTo(doLab4)
        }
        desTimeLab.snp.makeConstraints { (make) in
            make.left.size.equalTo(desLab)
            make.top.equalTo(doLab4.snp.bottom).offset(20)
        }
        timeLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(iconTimeView.snp.left).offset(-kMargin)
            make.top.equalTo(desTimeLab.snp.bottom)
            make.height.equalTo(kTitleHeight)
        }
        iconTimeView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(timeLab)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(klineWidth)
            make.top.equalTo(timeLab.snp.bottom)
        }
        desContentLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(lineView)
            make.top.equalTo(lineView.snp.bottom).offset(5)
        }
        
        saveBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
    }
    
    /// 说明
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "说话"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        
        return lab
    }()
    /// 背景View
    lazy var bgView: UIView = {
        let v = UIView()
        v.borderColor = kGrayLineColor
        v.borderWidth = klineWidth
        
        return v
    }()
    
    /// 要做的事
    lazy var contentTxtView: UITextView = {
        
        let txtView = UITextView()
        txtView.font = k15Font
        txtView.textColor = kGaryFontColor
        
        return txtView
    }()
    /// 限制字数
    lazy var fontCountLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kGaryFontColor
        lab.textAlignment = .right
        lab.text = "0/\(contentMaxCount)"
        
        return lab
    }()
    
    /// 要做的事
    lazy var doLab : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.text = "主人我在呢！"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        lab.tag = 100
        lab.addOnClickListener(target: self, action: #selector(onClickedTuiJian(sender:)))
        
        
        return lab
    }()
    /// 要做的事
    lazy var doLab1 : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.text = "播放小猪佩奇"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        lab.tag = 101
        lab.addOnClickListener(target: self, action: #selector(onClickedTuiJian(sender:)))
        
        return lab
    }()
    /// 要做的事
    lazy var doLab2 : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.text = "主人我在呢！"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        lab.tag = 102
        lab.addOnClickListener(target: self, action: #selector(onClickedTuiJian(sender:)))
        
        return lab
    }()
    /// 要做的事
    lazy var doLab3 : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.text = "主人我在呢！"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        lab.tag = 103
        lab.addOnClickListener(target: self, action: #selector(onClickedTuiJian(sender:)))
        
        return lab
    }()
    /// 要做的事
    lazy var doLab4 : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.text = "主人我在呢！"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        lab.tag = 104
        lab.addOnClickListener(target: self, action: #selector(onClickedTuiJian(sender:)))
        
        return lab
    }()
    /// 要做的事
    lazy var doLab5 : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.text = "主人我在呢！"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        lab.tag = 105
        lab.addOnClickListener(target: self, action: #selector(onClickedTuiJian(sender:)))
        
        return lab
    }()
    /// 时间
    lazy var desTimeLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "时间"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        
        return lab
    }()
    ///
    lazy var timeLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.text = "\(selectSecond / 60)分\(selectSecond % 60)秒"
        
        return lab
    }()
    /// icon
    lazy var iconTimeView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_scene_edit"))
    /// 分割线
    var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    ///
    lazy var desContentLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kBlackFontColor
        lab.numberOfLines = 0
        lab.text = doDesContent
        
        return lab
    }()
    
    /// 保存
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedSaveBtn), for: .touchUpInside)
        
        return btn
    }()
    
    ///获取推荐动作数据
    func requestTuiJianList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("scene/default/voice",parameters: ["type": doType],method :.get,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
                weakSelf?.tuiJianModels.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPSceneTuiJianModel.init(dict: itemInfo)
                    
                    weakSelf?.tuiJianModels.append(model)
                }
                weakSelf?.setTuiJianData()
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    func setTuiJianData(){
        
        if tuiJianModels.count == 0 {
            doLab.isHidden = true
            doLab1.isHidden = true
            doLab2.isHidden = true
            doLab3.isHidden = true
            doLab4.isHidden = true
            doLab5.isHidden = true
        }else if tuiJianModels.count == 1 {
            doLab.text = tuiJianModels[0].say
            doLab1.isHidden = true
            doLab2.isHidden = true
            doLab3.isHidden = true
        }else if tuiJianModels.count == 2 {
            doLab.text = tuiJianModels[0].say
            doLab1.text = tuiJianModels[1].say
            doLab2.isHidden = true
            doLab3.isHidden = true
        }else if tuiJianModels.count == 3 {
            doLab.text = tuiJianModels[0].say
            doLab1.text = tuiJianModels[1].say
            doLab2.text = tuiJianModels[2].say
            doLab3.isHidden = true
        }else if tuiJianModels.count == 4 {
            doLab.text = tuiJianModels[0].say
            doLab1.text = tuiJianModels[1].say
            doLab2.text = tuiJianModels[2].say
            doLab3.text = tuiJianModels[3].say
        }
        
        if doType == "sef_define"{//自定义时显示6个推荐，其他显示4个
            
            if tuiJianModels.count == 5 {
                doLab4.text = tuiJianModels[4].say
                doLab5.isHidden = true
            }else if tuiJianModels.count == 6 {
                doLab4.text = tuiJianModels[4].say
                doLab5.text = tuiJianModels[5].say
            }else{
                doLab4.isHidden = true
                doLab5.isHidden = true
            }
        }
    }
    /// 保存
    @objc func clickedSaveBtn(){
        doContent = contentTxtView.text!
        if doContent.isEmpty || doContent == placeHolder {
            MBProgressHUD.showAutoDismissHUD(message: placeHolder)
            return
        }
        
        if resultBlock != nil {
            let dic:[String: Any] = ["cmd_type":doType,"cmd":doContent,"time_len":"\(selectSecond)"]
            resultBlock!(dic)
        }
        clickedBackBtn()
    }
    
    /// 选择推荐动作
    @objc func onClickedTuiJian(sender: UITapGestureRecognizer){
        
        let tag = (sender.view?.tag)! - 100
        contentTxtView.text = tuiJianModels[tag].say
        fontCountLab.text =  "\(contentTxtView.text.count)/\(contentMaxCount)"
    }
    
    /// 删除
    @objc func onClickRightBtn(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                if weakSelf?.resultBlock != nil {
                    weakSelf?.resultBlock!([:])
                }
                weakSelf?.clickedBackBtn()
            }
        }
    }
    /// 选择时间
    @objc func onClickedSelectTime(){
        weak var weakSelf = self
        UsefulPickerView.showMultipleColsPicker("选择时间", data: [minuteArr,["分"],secondArr,["秒"]], defaultSelectedIndexs: nil) { (selectIndexs, selectTitles) in
            
            weakSelf?.timeLab.text = selectTitles[0] + selectTitles[1] + selectTitles[2] + selectTitles[3]
            weakSelf?.selectSecond = Int.init(selectTitles[0])! * 60 + Int.init(selectTitles[2])!
        }
    }
}


extension HOOPEditSceneDoVC : UITextViewDelegate{
    ///MARK UITextViewDelegate
    ///MARK UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        let text = textView.text
        if text == placeHolder {
            textView.text = ""
            textView.textColor = kBlackFontColor
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            textView.text = placeHolder
            textView.textColor = kGaryFontColor
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count > contentMaxCount - 20 {
            
            //获得已输出字数与正输入字母数
            let selectRange = textView.markedTextRange
            
            //获取高亮部分 － 如果有联想词则解包成功
            if let selectRange =   selectRange {
                let position =  textView.position(from: (selectRange.start), offset: 0)
                if (position != nil) {
                    return
                }
            }
            
            let textContent = textView.text
            let textNum = textContent?.count
            
            //截取500个字
            if textNum! > contentMaxCount {
                let index = textContent?.index((textContent?.startIndex)!, offsetBy: contentMaxCount)
                let str = textContent?.substring(to: index!)
                textView.text = str
            }
        }
        
        self.fontCountLab.text =  "\(textView.text.count)/\(contentMaxCount)"
    }
}
