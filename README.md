# SYPhotoPickerLibrary

It's the photo picker library for SinyiRealtyInc use.

## Requirements
`iOS 10`

## How to Use
```swift
let picker = SYPhotoPicker(type: type)
picker.delegate = self
picker.settings.selectedPhotos = selectedPhotos
picker.show(currentVC: self)
```

## Setting
Setting must follow the protocol `PhotoPickerSetting`.

```swift
public protocol PhotoPickerSetting {

    var statusBarStyle: UIStatusBarStyle { get set }
    var barTintColor: UIColor { get set }
    var barTextColor: UIColor { get set }
    var leftBarTitle: String { get set }
    var rightBarTitle: String { get set }
    var leftBarImage: UIImage? { get set }
    var rightBarImage: UIImage? { get set }
    var limitCount: Int { get set }
    var numberForRow: Int { get set }
    var photoSelectStyle: SYPhotoSelectSytle { get set }
    var photoSelectBorderWidth: CGFloat { get set }
    var photoSelectColor: UIColor { get set }
    var selectedPhotos: [PHAsset]? { get set }
}
```

If you want to customize your style.
You set the value like this:

```swift
let picker = SYPhotoPicker(type: .custom)
picker.settings.selectedPhotos = selectedPhotos
picker.settings.limitCount = 10
picker.settings.numberForRow = 4
picker.settings.photoSelectStyle = .symbol
picker.settings.photoSelectBorderWidth = 0
```
