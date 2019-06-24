//
//  QRCode.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-06-23.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

import UIKit

struct QRCode {
  let data: Data

  init(encoding data: Data) {
    self.data = data
  }

  private var image: CIImage? {
    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    qrFilter.setValue(data, forKey: "inputMessage")
    return qrFilter.outputImage
  }

  func uiImage(size: CGSize = CGSize(width: 160, height: 160)) -> UIImage? {
    guard let image = self.image else { return nil }
    let transform = CGAffineTransform(
      scaleX: size.width / image.extent.width,
      y: size.height / image.extent.height
    )
    return UIImage(ciImage: image.transformed(by: transform))
  }
}
