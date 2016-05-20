//
//  MediaPreviewViewController.swift
//  WisdriIS
//
//  Created by Allen on 4/11/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import AVFoundation
import Ruler

let mediaPreviewWindow = UIWindow(frame: UIScreen.mainScreen().bounds)

class MediaPreviewViewController: UIViewController {

    var previewImages: [WISFileInfo] = []
    var startIndex: Int = 0
    var currentIndex: Int = 0

    private struct ImagePool {
        var imagesDic = [String: UIImage]()

        mutating func addImage(image: UIImage, forKey key: String) {
            guard !key.isEmpty else {
                return
            }

            if imagesDic[key] == nil {
                imagesDic[key] = image
            }
        }

        func imageWithKey(key: String) -> UIImage? {
            return imagesDic[key]
        }
    }
    private var imagePool = ImagePool()

//    var currentPlayer: AVPlayer?

    @IBOutlet weak var mediasCollectionView: UICollectionView!
    @IBOutlet weak var mediaControlView: MediaControlView!

    lazy var topPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill // 缩放必要
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clearColor()
        return imageView
    }()
    lazy var bottomPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill // 缩放必要
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clearColor()
        return imageView
    }()
    // 图片初始 Frame
    var previewImageViewInitalFrame: CGRect?
    var topPreviewImage: UIImage?
    var bottomPreviewImage: UIImage?

    weak var transitionView: UIView?

    var afterDismissAction: (() -> Void)?

    var showFinished = false

    let mediaViewCellID = "MediaViewCell"

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("deinit MediaPreview")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mediasCollectionView.backgroundColor = UIColor.clearColor()
        mediasCollectionView.registerNib(UINib(nibName: mediaViewCellID, bundle: nil), forCellWithReuseIdentifier: mediaViewCellID)

        // 保证已经获取了图片初始 Frame
        guard let previewImageViewInitalFrame = previewImageViewInitalFrame else {
            return
        }

        topPreviewImageView.frame = previewImageViewInitalFrame
        bottomPreviewImageView.frame = previewImageViewInitalFrame
        view.addSubview(bottomPreviewImageView)
//        view.addSubview(topPreviewImageView)

        guard let bottomPreviewImage = bottomPreviewImage else {
            return
        }

        bottomPreviewImageView.image = bottomPreviewImage

//        topPreviewImageView.image = topPreviewImage

        let viewWidth = UIScreen.mainScreen().bounds.width
        let viewHeight = UIScreen.mainScreen().bounds.height

        let previewImageWidth = bottomPreviewImage.size.width
        let previewImageHeight = bottomPreviewImage.size.height

        // 利用 image.size 以及 view.frame 来确保 imageView 在缩放时平滑（配合 ScaleAspectFill）
        let previewImageViewWidth = viewWidth
        let previewImageViewHeight = (previewImageHeight / previewImageWidth) * previewImageViewWidth

        view.backgroundColor = UIColor.clearColor()

        mediasCollectionView.alpha = 0
        mediaControlView.alpha = 0

        topPreviewImageView.alpha = 0
        bottomPreviewImageView.alpha = 1
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { [weak self] in

            self?.view.backgroundColor = UIColor.blackColor()

            if let _ = self?.topPreviewImage {
                self?.topPreviewImageView.alpha = 1
            }

            let frame = CGRect(x: 0, y: (viewHeight - previewImageViewHeight) * 0.5, width: previewImageViewWidth, height: previewImageViewHeight)
            self?.topPreviewImageView.frame = frame
            self?.bottomPreviewImageView.frame = frame

        }, completion: { [weak self] _ in
            
            self?.bottomPreviewImageView.alpha = 0
            self?.mediasCollectionView.alpha = 1

//            let fade: (() -> Void)? = { [weak self] in
//                self?.topPreviewImageView.alpha = 0
//                self?.bottomPreviewImageView.alpha = 0
//            }

            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveLinear, animations: { [weak self] in
                self?.mediaControlView.alpha = 1
//                self?.mediaControlView.alpha = 0
                
            }, completion: { _ in
//                Ruler.iPhoneHorizontal(fade, nil, nil).value?()
            })
            
            UIView.animateWithDuration(0.1, delay: 0.1, options: .CurveLinear, animations: {
//                Ruler.iPhoneHorizontal(nil, fade, fade).value?()

            }, completion: { [weak self] _ in
                self?.showFinished = true
                print("showFinished")
            })
        })

        let tap = UITapGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismiss))
        view.addGestureRecognizer(tap)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismiss))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismiss))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)

        currentIndex = startIndex

        prepareInAdvance()
    }

    var isFirstLayoutSubviews = true

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isFirstLayoutSubviews {

            let item = startIndex

            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            
            mediasCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)

            delay(0.1) { [weak self] in

                guard let cell = self?.mediasCollectionView.cellForItemAtIndexPath(indexPath) as? MediaViewCell else {
                    return
                }

                self?.prepareForShareWithCell(cell)
            }
        }
        
        isFirstLayoutSubviews = false
    }

    // MARK: Private

    private func prepareInAdvance() {
        
        for previewImage in previewImages {
            
            let imagesInfo = [previewImage.fileName : previewImage]
            
            WISDataManager.sharedInstance().obtainImageOfMaintenanceTaskWithTaskID(currentTask!.taskID, imagesInfo: imagesInfo, downloadProgressIndicator: { _ in
                }, completionHandler: { (completedWithNoError, error, classNameOfDataAsString, data) in
                    
                if completedWithNoError {
                    // 图片获取成功
                    let imagesDictionary = data as! Dictionary<String, UIImage>
                    
                    if let image = imagesDictionary[previewImage.fileName] {
                        self.imagePool.addImage(image, forKey: previewImage.fileName)
                    }
                    
                } else {
                    // 待完善
                    WISConfig.errorCode(error)
                }
                
            })
        }
    }

    // MARK: Actions

    func dismiss() {

        guard showFinished else {
            return
        }

//        currentPlayer?.removeObserver(self, forKeyPath: "status")
//        currentPlayer?.pause()

        let finishDismissAction: () -> Void = { [weak self] in

            mediaPreviewWindow.windowLevel = UIWindowLevelNormal

            self?.afterDismissAction?()

            delay(0.05) {
                mediaPreviewWindow.rootViewController = nil
            }
        }
        
        guard currentIndex == startIndex else {
            
            transitionView?.alpha = 1
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { [weak self] in
                self?.view.backgroundColor = UIColor.clearColor()
                self?.mediaControlView.alpha = 0
                self?.mediasCollectionView.alpha = 0
                
                }, completion: { _ in
                    finishDismissAction()
            })
            
            return
        }

        if let _ = topPreviewImage {
            topPreviewImageView.alpha = 1
            bottomPreviewImageView.alpha = 0

        } else {
            bottomPreviewImageView.alpha = 1
        }

        mediasCollectionView.alpha = 0

        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseInOut, animations: { [weak self] in
            self?.mediaControlView.alpha = 0
        }, completion: nil)


        var frame = self.previewImageViewInitalFrame ?? CGRectZero

        let offsetIndex = currentIndex - startIndex
        
        if abs(offsetIndex) > 0 {
            let offsetX = CGFloat(offsetIndex) * frame.width + CGFloat(offsetIndex) * 5
            frame.origin.x += offsetX
        }

        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { [weak self] in

            self?.view.backgroundColor = UIColor.clearColor()

            if let _ = self?.topPreviewImage {
                self?.topPreviewImageView.alpha = 0
                self?.bottomPreviewImageView.alpha = 1
            }

            self?.topPreviewImageView.frame = frame
            self?.bottomPreviewImageView.frame = frame

        }, completion: { _ in
            finishDismissAction()
        })
    }

    /* 视频处理代码
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if let player = object as? AVPlayer {

            let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
            guard let cell = mediasCollectionView.cellForItemAtIndexPath(indexPath) as? MediaViewCell else {
                return
            }

            if player == cell.mediaView.videoPlayerLayer.player {

                if keyPath == "status" {
                    switch player.status {

                    case AVPlayerStatus.Failed:
                        print("Failed")

                    case AVPlayerStatus.ReadyToPlay:
                        print("ReadyToPlay")
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.mediaView.videoPlayerLayer.player?.play()

                            cell.mediaView.videoPlayerLayer.hidden = false
                            cell.mediaView.scrollView.hidden = true
                        }

                    case AVPlayerStatus.Unknown:
                        print("Unknown")
                    }
                }
            }
        }
    }

    func playerItemDidReachEnd(notification: NSNotification) {
        mediaControlView.playState = .Pause
        
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seekToTime(kCMTimeZero)
        }
    }
    */
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MediaPreviewViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previewImages.count
    }
    
    private func configureCell(cell: MediaViewCell, wisFileInfo: WISFileInfo) {
        
        cell.activityIndicator.startAnimating()
        mediaControlView.type = .Image
        
        if let image = imagePool.imageWithKey(wisFileInfo.fileName) {
            cell.mediaView.image = image
            
            cell.activityIndicator.stopAnimating()
            
        } else {
            
            let imagesInfo = [wisFileInfo.fileName : wisFileInfo]
            
            WISDataManager.sharedInstance().obtainImageOfMaintenanceTaskWithTaskID(currentTask!.taskID, imagesInfo: imagesInfo, downloadProgressIndicator: { _ in
                }, completionHandler: { (completedWithNoError, error, classNameOfDataAsString, data) in
                    
                    if completedWithNoError {
                        // 图片获取成功
                        cell.activityIndicator.stopAnimating()
                        
                        let imagesDictionary = data as! Dictionary<String, UIImage>
                        
                        if let image = imagesDictionary[wisFileInfo.fileName] {
                            self.imagePool.addImage(image, forKey: wisFileInfo.fileName)
                            self.mediaControlView.hidden = false
                        } else {
                            // 待完善，若因图片在服务器上被删或网络问题等原因导致图片获取不到，可在 MediaPreview 添加一张图片失效、断裂的提示图片
                            self.mediaControlView.hidden = true
                        }
                    } else {
                        // 待完善
                        WISConfig.errorCode(error)
                    }
                    
            })
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(mediaViewCellID, forIndexPath: indexPath) as! MediaViewCell
        return cell
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        if let cell = cell as? MediaViewCell {
            let previewImage = previewImages[indexPath.item]
            configureCell(cell, wisFileInfo: previewImage)
            
            cell.mediaView.tapToDismissAction = { [weak self] in
                self?.dismiss()
            }
        }
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    }


    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {

        let newCurrentIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)

        if newCurrentIndex != currentIndex {

//            currentPlayer?.removeObserver(self, forKeyPath: "status")
//            currentPlayer?.pause()
//            currentPlayer = nil

            let indexPath = NSIndexPath(forItem: newCurrentIndex, inSection: 0)

            guard let cell = mediasCollectionView.cellForItemAtIndexPath(indexPath) as? MediaViewCell else {
                return
            }

            currentIndex = newCurrentIndex

            print("scroll to new media")

            transitionView?.alpha = (currentIndex == startIndex) ? 0 : 1


            guard let image = cell.mediaView.image else {
                return
            }

            bottomPreviewImageView.image = image

            let viewWidth = UIScreen.mainScreen().bounds.width
            let viewHeight = UIScreen.mainScreen().bounds.height

            let previewImageWidth = image.size.width
            let previewImageHeight = image.size.height

            let previewImageViewWidth = viewWidth
            let previewImageViewHeight = (previewImageHeight / previewImageWidth) * previewImageViewWidth

            let frame = CGRect(x: 0, y: (viewHeight - previewImageViewHeight) * 0.5, width: previewImageViewWidth, height: previewImageViewHeight)

            bottomPreviewImageView.frame = frame

        }
    }
    
    private func prepareForShareWithCell(cell: MediaViewCell) {
    
        guard let image = cell.mediaView.image else {
            return
        }
        
        mediaControlView.type = .Image
        
        mediaControlView.shareAction = { [weak self] in
            
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)

            self?.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
}