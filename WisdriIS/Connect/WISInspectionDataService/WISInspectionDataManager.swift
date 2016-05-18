//
//  WISInspectionDataManager.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/23/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation
import UIKit

private let defaultLocalArchivingStorageDirectoryKey = "defaultLocalArchivingStorageDirectory"

class WISInsepctionDataManager {
    
    // MARK: Shared Instances
    static func sharedInstance() -> WISInsepctionDataManager { return WISInsepctionDataManager.sharedInspectionDataManagerInstance }
    private static let sharedInspectionDataManagerInstance = WISInsepctionDataManager(archivingStorageFolderName: "ArchivingCache")
    
    private var localArchivingStorageDirectories = [String : String]()
    
    private init(archivingStorageFolderName folderName: String) {
        print("WISInsepctionDataManager initializing!")
        
        setDefaultLocalArchivingStorageDirectory(folderName)
        
        let archivingFilesFullPath = filesFullPathIn(Directory: defaultLocalArchivingStorageDirectory)
        
        if archivingFilesFullPath.count > 0 {
            for fileFullPath in archivingFilesFullPath {
                inspectionTasksUploadingQueue.append(NSKeyedUnarchiver.unarchiveObjectWithFile(fileFullPath) as! InspectionTaskForUploading)
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WISInsepctionDataManager.networkingStatusChanges(_:)), name: WISNetworkStatusChangedNotification, object: nil)
        
        startInspectionTaskUploading()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: WISNetworkStatusChangedNotification, object: nil)
    }
    
    var currentUploadingInspectionTask: InspectionTaskForUploading?
    var currentURLSessionTask: NSURLSessionTask?
    
    var onTheGoInspectionTasks = [WISInspectionTask]()
    var historicalInspectionTasks = [WISInspectionTask]()
    var overDueInspectionTasks = [WISInspectionTask]()
    
    var deviceTypes = [String : WISDeviceType]()
    
    var inspectionTasksUploadingQueue = [InspectionTaskForUploading]()
    private var uploadingStateBeforeSuspended = InspectionUploadingState.Unknown
    
    func startInspectionTaskUploading() {
        attemptInspectionTaskUploading()
    }
    
    func uploadingQueueContainsInspectionTaskByDeviceID(deviceID: String) -> Bool {
        guard self.inspectionTasksUploadingQueue.count > 0 else {
            return false
        }
        
        for task in self.inspectionTasksUploadingQueue {
            if task.inspectionTask.device.deviceID == deviceID {
                return true
            }
        }
        return false
    }
    
    func indexOfInspectionTaskInListByDeviceID(deviceID: String, inspectionTaskType: InspectionTaskType) -> Int {
        let inspectionTasks: [WISInspectionTask]
        
        switch inspectionTaskType {
        case .OnTheGo: inspectionTasks = self.onTheGoInspectionTasks
        case .Historical: inspectionTasks = self.historicalInspectionTasks
        case .OverDue: inspectionTasks = self.overDueInspectionTasks
        }
        
        guard inspectionTasks.count > 0 else {
            return -1
        }
        
        for index in 0...inspectionTasks.count - 1 {
            if inspectionTasks[index].device.deviceID == deviceID {
                return index
            }
        }
        return -1
    }
    
    
    @objc private func networkingStatusChanges(networkNotification: NSNotification) -> Void {
        attemptInspectionTaskUploading()
    }
    
    // MARK: - uploading flow control
    
    func addInspectionTaskToUploadingQueue(inspectionTask: WISInspectionTask, images: [String : UIImage]) -> Void {
        // 如果是重复的点检项目, 就不再添加
        guard !uploadingQueueContainsInspectionTaskByDeviceID(inspectionTask.device.deviceID) else {
            return
        }
        
        var imagesName = [String]()
        
        if images.count > 0 {
            for (name, image) in images {
                imagesName.append(name)
                WISFileStoreManager.defaultManager().uploadImageStore.setImage(image, forImageName: name)
            }
        }
        
        let inspectionTaskForUploading = InspectionTaskForUploading(inspectionTask: inspectionTask, imagesName: imagesName, isImagesUploadingCompleted: (images.count <= 0))
        
        inspectionTaskForUploading.uploadingState = InspectionUploadingState.UploadingPending
        
        self.inspectionTasksUploadingQueue.append(inspectionTaskForUploading)
        
        let fileName = inspectionTaskForUploading.inspectionTask.device.deviceID + ".inspectionArchive"
        let fileFullPath = defaultLocalArchivingStorageDirectory.stringByAppendingPathComponent(fileName)
        NSKeyedArchiver.archiveRootObject(inspectionTaskForUploading, toFile: fileFullPath)
        
        print("add inspection task (deviceID): \(inspectionTaskForUploading.inspectionTask.device.deviceID) to the uploading queue.")
        
        popItemFromUploadingQueueToCurrentUploadingInspectionTaskByIndex(0)
        attemptInspectionTaskUploading()
    }
    
    private func removeInspectionTaskFromUploadingQueueByIndex(index: Int = 0) -> Bool {
        if inspectionTasksUploadingQueue.count > 0 && index < inspectionTasksUploadingQueue.count {
            let fileName = self.inspectionTasksUploadingQueue[index].inspectionTask.device.deviceID + ".inspectionArchive"
            let fileFullPath = defaultLocalArchivingStorageDirectory.stringByAppendingPathComponent(fileName)
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(fileFullPath)
            } catch {
                // do nothing
            }
            inspectionTasksUploadingQueue.removeAtIndex(index)
            print("remove inspection task index: \(index) from the uploading queue.")
            
            return true
            
        } else {
            return false
        }
    }
    
    private func popItemFromUploadingQueueToCurrentUploadingInspectionTaskByIndex(index: Int = 0) -> Bool {
        if currentUploadingInspectionTask == nil
            && inspectionTasksUploadingQueue.count > 0
            && (index < inspectionTasksUploadingQueue.count) {
            self.currentUploadingInspectionTask = inspectionTasksUploadingQueue[index]
            return true
        } else {
            return false
        }
    }
    
    private func attemptInspectionTaskUploading() {
        guard currentURLSessionTask == nil else {
            if (WISDataManager.sharedInstance().networkReachabilityStatus != .NotReachable && WISDataManager.sharedInstance().networkReachabilityStatus != .Unknown) {
                currentURLSessionTask?.resume()
                currentUploadingInspectionTask?.uploadingState = self.uploadingStateBeforeSuspended
                
            } else {
                currentURLSessionTask?.suspend()
                self.uploadingStateBeforeSuspended = (currentUploadingInspectionTask?.uploadingState)!
            }
            return
        }
        
        if (WISDataManager.sharedInstance().networkReachabilityStatus != .NotReachable && WISDataManager.sharedInstance().networkReachabilityStatus != .Unknown) {
            if (currentUploadingInspectionTask != nil) {
                if !(currentUploadingInspectionTask?.isImagesUploadingCompleted)! {
                    uploadImagesOfInspectionTask()
                } else {
                    uploadDataOfInspectionTask()
                }
                
            } else {
                if popItemFromUploadingQueueToCurrentUploadingInspectionTaskByIndex(0) {
                    uploadImagesOfInspectionTask()
                }
            }
        }
    }
    
    private func uploadImagesOfInspectionTask() {
        guard currentURLSessionTask == nil else {
            self.currentURLSessionTask?.resume()
            return
        }
        
        if currentUploadingInspectionTask == nil {
            guard popItemFromUploadingQueueToCurrentUploadingInspectionTaskByIndex(0) else {
                print("No more inspection task for upload")
                return
            }
        }
        
        guard currentUploadingInspectionTask?.isImagesUploadingCompleted == false else {
            self.attemptInspectionTaskUploading()
            return
        }
        
        guard let names = currentUploadingInspectionTask?.imagesName where currentUploadingInspectionTask?.imagesName.count > 0 else {
            currentUploadingInspectionTask?.isImagesUploadingCompleted = true
            self.attemptInspectionTaskUploading()
            return
        }
        
        self.currentUploadingInspectionTask?.uploadingState = InspectionUploadingState.UploadingImages
        uploadingStateBeforeSuspended = InspectionUploadingState.UploadingImages
        
        let uploadingImages = WISFileStoreManager.defaultManager().uploadImageStore.imagesForImagesName(names)
        
        self.currentURLSessionTask = WISDataManager.sharedInstance().uploadImageWithImages(uploadingImages,
            progressIndicator: { (transmissionProgress) in
                weak var weakSelf = self
                weakSelf?.currentUploadingInspectionTask?.imageUploadingProgress = transmissionProgress
                print("\(transmissionProgress.completedUnitCount) / \(transmissionProgress.totalUnitCount)")
                
            }, completionHandler: { (completeWithNoError, error, classNameOfReceivedDataAsString, receivedData) in
                if completeWithNoError {
                    weak var weakSelf = self
                    print("\n")
                    print("upload inspection task images: \(weakSelf?.currentUploadingInspectionTask?.inspectionTask.device.deviceID) completed!")
                    weakSelf!.currentURLSessionTask = nil
                    weakSelf!.currentUploadingInspectionTask?.isImagesUploadingCompleted = true
                    
                    print(classNameOfReceivedDataAsString)
                    
                    // let infos = receivedData as! NSArray
                    ((weakSelf!.currentUploadingInspectionTask?.inspectionTask)! as WISInspectionTask).appendImagesInfo(receivedData)
                    
                    //weakSelf!.uploadInfosOfInspectionTask(weakSelf!.currentUploadingInspectionTask!)
                    weakSelf!.attemptInspectionTaskUploading()
                    
                } else {
                    weak var weakSelf = self
                    weakSelf!.currentURLSessionTask = nil
                    weakSelf!.currentUploadingInspectionTask?.isImagesUploadingCompleted = false
                    weakSelf!.currentUploadingInspectionTask?.uploadingState = .UploadingPending
                    weakSelf!.attemptInspectionTaskUploading()
                }
        })
        self.currentURLSessionTask?.resume()
    }
    
    private func uploadDataOfInspectionTask() {
        guard currentURLSessionTask == nil else {
            self.currentURLSessionTask?.resume()
            return
        }
        
        if currentUploadingInspectionTask == nil {
            guard popItemFromUploadingQueueToCurrentUploadingInspectionTaskByIndex(0) else {
                print("No more inspection task for upload")
                return
            }
        }
        
        guard currentUploadingInspectionTask?.isImagesUploadingCompleted == true else {
            self.attemptInspectionTaskUploading()
            return
        }
        
        self.currentUploadingInspectionTask?.uploadingState = InspectionUploadingState.UploadingData
        self.uploadingStateBeforeSuspended = InspectionUploadingState.UploadingData
        
        var tasks = [WISInspectionTask]()
        tasks.append((self.currentUploadingInspectionTask!.inspectionTask)!)
        
        self.currentURLSessionTask = WISDataManager.sharedInstance().submitInspectionResult(tasks, completionHandler: {[weak self] (completedWithNoError, error) in
            if completedWithNoError {
                weak var weakSelf = self
                print("\n")
                print("submit inspection task: \(weakSelf?.currentUploadingInspectionTask?.inspectionTask.device.deviceID) completed")
                
                weakSelf!.removeInspectionTaskFromUploadingQueueByIndex(0)
                weakSelf!.currentUploadingInspectionTask?.uploadingState = InspectionUploadingState.UploadingCompleted
                weakSelf!.uploadingStateBeforeSuspended = InspectionUploadingState.Unknown
                
                weakSelf!.currentURLSessionTask = nil
                weakSelf!.currentUploadingInspectionTask = nil
                
                if weakSelf!.inspectionTasksUploadingQueue.isEmpty {
                    // do nothing
                } else {
                    weakSelf!.popItemFromUploadingQueueToCurrentUploadingInspectionTaskByIndex(0)
                    weakSelf!.attemptInspectionTaskUploading()
                }
                
            } else {
                weak var weakSelf = self
                weakSelf!.currentURLSessionTask = nil
                weakSelf!.currentUploadingInspectionTask?.isImagesUploadingCompleted = true
                weakSelf!.currentUploadingInspectionTask?.uploadingState = .UploadingPending
                // weakSelf!.attemptInspectionTaskUploading()
            }
        })
        currentURLSessionTask?.resume()
    }
    
    
    // MARK: - storage support method
    private func setDefaultLocalArchivingStorageDirectory(folderName: String) -> Void {
        let documentDirectories = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let documentDirectory = documentDirectories.first
        let archivingStorageDirectory = documentDirectory?.stringByAppendingPathComponent(folderName)
        
        if (!(NSFileManager.defaultManager().fileExistsAtPath(archivingStorageDirectory!))) {
            do {
            try  NSFileManager.defaultManager().createDirectoryAtPath(archivingStorageDirectory!, withIntermediateDirectories: false, attributes: nil)
            } catch {
                // do nothing
            }
        }
        self.localArchivingStorageDirectories[defaultLocalArchivingStorageDirectoryKey] = archivingStorageDirectory
    }
    
    var defaultLocalArchivingStorageDirectory: String {
        return self.localArchivingStorageDirectories[defaultLocalArchivingStorageDirectoryKey]!
    }
    
    func defaultLocalArchivingStoragePathWithArchivingFileName(fileName: String) -> String {
        return self.defaultLocalArchivingStorageDirectory.stringByAppendingPathComponent(fileName)
    }
    
    func filesFullPathIn(Directory directory: String) -> [String] {
        var filesName = [String]()
        var filesFullPath = [String]()
        do {
           try filesName = NSFileManager.defaultManager().contentsOfDirectoryAtPath(directory)
        } catch {
            // do nothing
        }
        
        if filesName.count > 0 {
            for fileName in filesName {
                let fileFullPath = directory.stringByAppendingPathComponent(fileName)
                if NSFileManager.defaultManager().fileExistsAtPath(fileFullPath) {
                    filesFullPath.append(fileFullPath)
                }
            }
        }
        return filesFullPath
    }
}

