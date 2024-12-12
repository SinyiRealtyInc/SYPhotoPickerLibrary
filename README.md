# SYPhotoPickerLibrary

It's the photo picker library for Sinyi Realty Inc use.

## Requirements and Details

- iOS 13.0+
- Xcode 15.0+
- Build with Swift 5.0+

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Alamofire does support its use on supported platforms.

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/SinyiRealtyInc/SYPhotoPickerLibrary", .upToNextMajor(from: "2.0.1"))
]
```

## Usage

### 1. Open ur Info.plist and add the following permissions

![Photo Permission](https://github.com/SinyiRealtyInc/SYPhotoPickerLibrary/blob/main/Resource/lib-img-0.png)

```xml
<key>NSCameraUsageDescription</key>
<string>Please allow access to your camera then take picture.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Please allow access to your album then pick up photo.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Please allow access to your album then save photo.</string>

On iOS 14 later
<key>PHPhotoLibraryPreventAutomaticLimitedAccessAlert</key>
<true/>
```

### 2. Use SYPhotoPickerLibrary. You can building what you want

```swift
import Photos
import SYPhotoPickerLibrary

/**
  * @param statusBarStyle         : (choose) (default: .lightContent)
  * @param barTintColor           : (choose) (default: .systemOrange)     
  * @param barTitleIconColor      : (choose) (default: .white) 
  * @param leftBarTitle           : (choose) (default: nil)
  * @param rightBarTitle          : (choose) (default: "確認")
  * @param leftBarImage           : (choose) (default: SYImage.close.image)
  * @param rightBarImage          : (choose) (default: nil)
  * @param limitCount             : (choose) (default: 10)
  * @param numberForRow           : (choose) (default: 4)
  * @param photoSelectStyle       : (choose) (default: SYPhotoSelectSytle.number)
  * @param photoSelectBorderWidth : (choose) (default: 2)
  * @param photoSelectColor       : (choose) (default: .systemOrange)
  * @param selectedPhotos         : (choose) (default: [])
  */

// Easy way
let picker = SYPhotoPicker(type: .default)
picker.delegate = self
picker.show(currentVC: self)

// Custom setting
let picker = SYPhotoPicker(type: .default)
picker.settings.barTintColor = .systemPink
picker.delegate = self
picker.show(currentVC: self)
```

### 3. SYPhotPicker Attributes

![SYPhotPicker Attributes](https://github.com/SinyiRealtyInc/SYPhotoPickerLibrary/blob/main/Resource/lib-img-1.png)

### 4. Extension SYPhotoPickerDelegate

```swift
extension ViewController: SYPhotoPickerDelegate {
    
    /// 照片讀取權限被拒
    func photoPickerAuthorizedDenied() {}
    
    /// 照片已選取
    func photoPickerDidSelect(asset: PHAsset) {}
    
    /// 照片取消選取
    func photoPickerDidDeselect(asset: PHAsset) {}
    
    /// 照片挑選已達上限
    func photoPickerDidLimit() {}
    
    /// 確認所挑選照片
    func photoPickerConfirm(assets: [PHAsset]) {
        for asset in assets {
            let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            SYPhotoPickerHelper.shared.fetchImage(form: asset, size: size) { image in
                // do something...
            }
        }
    }
    
    /// 離開照片挑選器
    func photoPickerDismiss() {}
}
```

## License

SYPhotoPickerLibrary is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

    MIT License

    Copyright (c) [2024] [Sinyi Realty Inc]

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
