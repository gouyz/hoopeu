//
//  HOOPWarnEditTimeVC.swift
//  hoopeu
//  报警设置 编辑时间
//  Created by gouyz on 2019/2/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPWarnEditTimeVC: GYZBaseVC {
    
    /// 选择结果回调
    var resultBlock:((_ dayTime: String,_ weekTime: String,_ customWeek: [String],_ day: String) -> Void)?
    let titleArray = ["单次", "每天", "周末", "工作日", "自定义"]
    let weekDayArray = ["周日","周一", "周二", "周三", "周四", "周五", "周六"]
    
    /// 多选周索引
    var selectedWeekIndexs = [Int]()
    /// 每周循环时间 ,ONCE:仅此一次,EVERYDAY :每天,WEEKDAY:工作日,WEEKEND:每周末,USER_DEFINE:自定义
    var week_time: String = "ONCE"
    /// 用户自定义时间选择，可多选。EVERY_MONDAY:每周一,EVERY_TUESDAY:每周二,EVERY_WEDNESDAY:每周三,EVERY_THURSDAY:每周四,EVERY_FRIDAY:每周五,EVERY_SATURDAY:每周六,EVERY_SUNDAY:每周日
    var user_define_times: [String] = [String]()
    /// 用户想要播报的语句的时间
    var day_time: String = ""
    /// 用户想要播报的语句的日期
    var day: String = ""
    /// 单次是否显示日期
    var isShowDate:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "编辑时间"
        self.view.backgroundColor = kWhiteColor
        
        setupUI()
        if week_time == "ONCE" && isShowDate {
            datePicker.datePickerMode = .dateAndTime
        }
        
        setDayTime()
    }
    
    /// 创建UI
    func setupUI(){
        view.addSubview(datePicker)
        view.addSubview(bgView)
        bgView.addSubview(warnTimeLab)
        bgView.addSubview(desLab)
        bgView.addSubview(rightIconView)
        view.addSubview(lineView)
        view.addSubview(saveBtn)
        
        datePicker.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight + kTitleHeight)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(220)
        }
        bgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(datePicker.snp.bottom)
            make.height.equalTo(60)
        }
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(rightIconView.snp.left).offset(-kMargin)
            make.top.equalTo(bgView)
            make.height.equalTo(20)
        }
        warnTimeLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.bottom.equalTo(bgView)
            make.top.equalTo(desLab.snp.bottom)
        }
        rightIconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(bgView)
            make.right.equalTo(-kMargin)
            make.size.equalTo(rightArrowSize)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(bgView)
            make.top.equalTo(bgView.snp.bottom)
            make.height.equalTo(klineWidth)
        }
        saveBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
    }
    
    /// 选择时间
    lazy var datePicker : UIDatePicker = {
        let picker = UIDatePicker()
        picker.backgroundColor = kWhiteColor
        picker.locale = Locale(identifier: "zh_CN")
        picker.datePickerMode = .time
        //响应事件
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        return picker
    }()
    ///
    lazy var bgView : UIView = {
        let line = UIView()
        line.backgroundColor = kWhiteColor
        line.addOnClickListener(target: self, action: #selector(onClickedRepeate))
        return line
    }()
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        lab.text = "重复"
        
        return lab
    }()
    lazy var warnTimeLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlueFontColor
        lab.font = k13Font
        lab.text = "单次"
        
        return lab
    }()
    /// 右侧箭头图标
    lazy var rightIconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_right_arrow"))
    /// 分割线
    lazy var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
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
    /// 保存
    @objc func clickedSaveBtn(){
        if day_time.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请选择布防时间")
            return
        }
        if week_time.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请选择布防执行周期")
            return
        }
        
        if resultBlock != nil {
            resultBlock!(day_time,week_time,user_define_times,day)
        }
        clickedBackBtn()
    }
    
    /// 重复
    @objc func onClickedRepeate(){
        
        GYZAlertViewTools.alertViewTools.showSheet(title: nil, message: nil, cancleTitle: "取消", titleArray: titleArray, viewController: self) { [weak self](index) in
            
            if index != cancelIndex{
                if index == (self?.titleArray.count)! - 1{//自定义
                    self?.showCustomView()
                }else{
                    self?.warnTimeLab.text = self?.titleArray[index]
                    for item in GUARDBUFANGTIME{
                        if item.value == self?.titleArray[index]{
                            self?.week_time = item.key
                            break
                        }
                    }
                    if self?.week_time == "ONCE" && self?.isShowDate ?? false {
                        self?.datePicker.datePickerMode = .dateAndTime
                    }else{
                        self?.datePicker.datePickerMode = .time
                    }
                    
                }
            }
            
        }
    }
    
    /// 编辑时间
    @objc func dateChanged() {
        
        setDayTime()
        
    }
    func setDayTime(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        day_time = dateFormatter.string(from: datePicker.date)
        if week_time == "ONCE" && isShowDate {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            day = dateFormatter.string(from: datePicker.date)
        }
    }
    /// 自定义
    func showCustomView(){
        let actionSheet = GYZActionSheet.init(title: "每周", style: .Table, itemTitles: weekDayArray,isMult:true)
        
        if selectedWeekIndexs.count > 0 {
            actionSheet.setMultSelectIndexs(indexs: selectedWeekIndexs)
        }
        weak var weakSelf = self
        
        actionSheet.didMultSelectIndex = { (indexs: [Int],titles: [String]) in
            
            var dayIndexs = indexs
            dayIndexs.sort()
            
            weakSelf?.week_time = "USER_DEFINE"
            var str: String = ""
            for i in dayIndexs {
                str += (weakSelf?.weekDayArray[i])! + ","
                for item in GUARDBUFANGTIMEBYWEEKDAY{
                    if weakSelf?.weekDayArray[i] == item.value{
                        weakSelf?.user_define_times.append(item.key)
                        break
                    }
                }
            }
            if !str.isEmpty {
                str = str.subString(start: 0, length: str.count - 1)
            }
            
            weakSelf?.warnTimeLab.text = str
            weakSelf?.selectedWeekIndexs = indexs
        }
    }
}
