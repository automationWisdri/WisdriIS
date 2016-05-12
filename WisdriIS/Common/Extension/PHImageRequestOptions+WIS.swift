//
//  PHImageRequestOptions+WIS.swift
//  WisdriIS
//
//  Created by Allen on 3/2/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Photos

extension PHImageRequestOptions {

    static var wis_sharedOptions: PHImageRequestOptions {

        let options = PHImageRequestOptions()
        // 当 synchronous 设为 true 时，deliveryMode 属性就会被忽略，并被当作 .HighQualityFormat 来处理
        options.synchronous = true
        // .Current 会传递包含所有调整和修改的图像
        // .Unadjusted 会递送未被施加任何修改的图像
        // .Original 会递送原始的、最高质量的格式的图像 (例如 RAW 格式的数据。而当将属性设置为 .Unadjusted 时，会递送一个 JPEG)
        options.version = .Current
        options.deliveryMode = .HighQualityFormat
        /*
         * .Exact (返回图像必须和目标大小相匹配)，.Fast (比 .Exact 效率更高，但返回图像可能和目标大小不一样) 或者 .None
         * normalizedCroppingMode 属性让我们确定图像管理器应该如何裁剪图像。注意：如果设置了normalizedcroppingMode 的值，那么 resizeMode 需要设置为 .Exact
         */
        options.resizeMode = .Exact
        // 用户可能开启了 iCloud 照片库，所以获取用户照片时可能需要用到网络连接
        options.networkAccessAllowed = true

        return options
    }
}

