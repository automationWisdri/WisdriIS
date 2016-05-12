//
//  ProfileInfoViewController.swift
//  WisdriIS
//
//  Created by Allen on 5/5/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class ProfileInfoViewController: UIViewController {

    private let profileInfoCellIdentifier = "ProfileInfoCell"
    
    @IBOutlet weak var profileInfoTableView: TPKeyboardAvoidingTableView!
    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var introTextView: UITextView!
    
    var segueIdentifier: String?
    
    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(ProfileInfoViewController.post(_:)))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "修改信息"
        
        view.backgroundColor = UIColor.yepBackgroundColor()
        navigationItem.rightBarButtonItem = postButton
        
        profileInfoTableView.tableHeaderView = introView
        profileInfoTableView.registerNib(UINib(nibName: profileInfoCellIdentifier, bundle: nil), forCellReuseIdentifier: profileInfoCellIdentifier)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func post(sender: UIBarButtonItem) {
        
        //        let cell = profileInfoTableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! ProfileInfoCell
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileInfoViewController: UITableViewDataSource, UITableViewDelegate {
    
    private enum PhoneRow: Int {
        case Tel = 0
        case Mobile
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch segueIdentifier! {
        case "editUserName": return 1;
        case "editPhone": return 2;
        default: return 1
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch segueIdentifier! {
            
        case "editUserName":
        
            let cell = tableView.dequeueReusableCellWithIdentifier(profileInfoCellIdentifier) as! ProfileInfoCell
            cell.infoTextField.placeholder = "请填入用户姓名"
            return cell
        
        case "editPhone":
        
            switch indexPath.row {
                
            case PhoneRow.Tel.rawValue:
                let cell = tableView.dequeueReusableCellWithIdentifier(profileInfoCellIdentifier) as! ProfileInfoCell
                cell.annotationLabel.text = "固定电话"
                cell.infoTextField.placeholder = "请填入固定电话号码"
                return cell
                
            case PhoneRow.Mobile.rawValue:
                let cell = tableView.dequeueReusableCellWithIdentifier(profileInfoCellIdentifier) as! ProfileInfoCell
                cell.annotationLabel.text = "移动电话"
                cell.infoTextField.placeholder = "请填入移动电话号码"
                return cell
                
            default:
                return UITableViewCell()
            
            }
        
        default:
            return UITableViewCell()
            
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 60
    }
    
}