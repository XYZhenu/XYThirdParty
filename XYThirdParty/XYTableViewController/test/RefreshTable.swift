//
//  RefreshTable.swift
//  XYThirdParty
//
//  Created by Xie Yan, (Yan.Xie@partner.bmw.com) on 2017/7/24.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

import Foundation
class OneLabelCell: UITableViewCell {
    @IBOutlet weak var label_1: UILabel!
    override func xyModelSet(_ model: XYRowModel) {
        label_1.text = model.message["1"] as? String
    }
}
class TwoLabelCell: UITableViewCell {
    @IBOutlet weak var label_1: UILabel!
    @IBOutlet weak var label_2: UILabel!
    override func xyModelSet(_ model: XYRowModel) {
        label_1.text = model.message["1"] as? String
        label_2.text = model.message["2"] as? String
    }
}
class RefreshTableVC: XYTableViewController {
    @IBOutlet weak var tableviewIB: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTableView(tableviewIB)
        
        let mo1 = XYRowModel(cls: OneLabelCell.classForCoder(), msg: ["1":"qwertyuioplkjhgfdsazxcvbnmqwertyuioplkjhgfdsazxcvbnm"])
        modelRect.add(mo1)
        
        
        let mo2 = XYRowModel(cls: TwoLabelCell.classForCoder(), msg: ["1":"qwertyuioplkjhgfdsazxcvbnmqwerty\nuioplkjhgfdsazxcvbnm","2":"我的意思\n是说你要\n的吗啊你不在家吃饭吗的逼里是没有任何副作用大呢石头辅助吗在的时候都没有人接听无明显的变化的时候是这样说就好哦我不想你的人"])
        modelRect.add(mo2)
        
        tableviewIB.reloadData()
    }
}
