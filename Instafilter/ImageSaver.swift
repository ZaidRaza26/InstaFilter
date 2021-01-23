//
//  ImageSaver.swift
//  Instafilter
//
//  Created by Zaid Raza on 23/01/2021.
//  Copyright © 2021 Zaid Raza. All rights reserved.
//

import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageSaver: NSObject {
    
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError),nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
