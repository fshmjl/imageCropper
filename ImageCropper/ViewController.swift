//
//  ViewController.swift
//  ImageCropper
//
//  Created by RPK on 2019/12/9.
//  Copyright © 2019 Teng Mao Technology. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var avaterImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        avaterImageView = UIImageView.init(frame: .init(x: (kScreenWidth - 160)/2, y: 240, width: 160, height: 160))
        avaterImageView.image = UIImage.init(named: "default-image")
        avaterImageView.layer.cornerRadius  = 80
        avaterImageView.layer.masksToBounds = true
        view.addSubview(avaterImageView)
        
        let button = UIButton.init(frame: .init(x: (kScreenWidth - 160)/2, y: avaterImageView.frame.origin.y + avaterImageView.frame.size.height + 40, width: 160, height: 40))
        button.setTitle("上传头像", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(uploadAvaterImg(_:)), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func uploadAvaterImg(_ sender: UIButton) {
        let imagePicker = UIImagePickerController.init()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }

}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false, completion: nil)
        let image = info[.originalImage] as! UIImage
        
        let cropperImage = RImageCropperViewController.init(originalImage: image, cropFrame: CGRect.init(x: (kScreenWidth - 300)/2, y: (kScreenHeight - 300)/2, width: 300, height: 300), limitScaleRatio: 30)
        cropperImage.delegate = self
        navigationController?.pushViewController(cropperImage, animated: true)
    }
    
}

extension ViewController : RImageCropperDelegate {
    func imageCropper(cropperViewController: RImageCropperViewController, didFinished editImg: UIImage) {
        avaterImageView.image = editImg
        cropperViewController.navigationController?.popViewController(animated: false)
    }
    
    func imageCropperDidCancel(cropperViewController: RImageCropperViewController) {
        cropperViewController.navigationController?.popViewController(animated: false)
    }
}

