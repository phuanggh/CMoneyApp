//
//  SecondVC.swift
//  CMoneyApp
//
//  Created by Penny Huang on 2020/5/18.
//  Copyright © 2020 Penny Huang. All rights reserved.
//

import UIKit

class SecondVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    @IBOutlet weak var indicatorOutlet: UIActivityIndicatorView!
    
    fileprivate struct PropertyKeys {
        static let dataCell = "dataCell"
        
        static let toThirdVC = "secondToThirdSegue"
    }
    
    var apiData = [APIData]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apiData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PropertyKeys.dataCell, for: indexPath) as! DataCell

        cell.idLabel.text = String(apiData[indexPath.row].id)
        cell.titleLabel.text = String(apiData[indexPath.row].title)
        cell.thumbnaiImageView.image = nil
        
//        DispatchQueue.main.async {
//            cell.thumbnaiImageView.image = self.getImage(urlStr: self.apiData[indexPath.row].thumbnailUrl)
//        }
        
       APIController.shared.fetchImage(apiData[indexPath.row].thumbnailUrl) { (result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    cell.thumbnaiImageView.image = image
                    cell.idLabel.textColor = image.averageColor?.isDarkColor ?? false ? UIColor.white : UIColor.black
                    cell.titleLabel.textColor = image.averageColor?.isDarkColor ?? false ? UIColor.white : UIColor.black
                    self.indicatorOutlet.stopAnimating()
                }
            case .failure(let networkError):
                switch networkError {
                case .invalidUrl:
                    print(networkError)
                case .invalidResponse:
                    print(networkError)
                case .requestFailed(let error):
                    print(networkError, error)
                case .invalidData:
                    print(networkError)
                default:
                    print("Unidentified Error")
                }

            }

        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: PropertyKeys.toThirdVC, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ThirdVC

        let selectedIndexPath = collectionViewOutlet.indexPathsForSelectedItems

        destinationVC.idStr = String(apiData[(selectedIndexPath?[0].row) ?? 0].id)
        destinationVC.titleStr = String(apiData[(selectedIndexPath?[0].row) ?? 0].title)
        APIController.shared.fetchImage(apiData[selectedIndexPath?[0].row ?? 0].thumbnailUrl) { (result) in
            switch result {
            case .success(let image):
                destinationVC.image = image
            case .failure(let networkError):
                switch networkError {
                case .invalidUrl:
                    print(networkError)
                case .invalidResponse:
                    print(networkError)
                case .requestFailed(let error):
                    print(networkError, error)
                case .invalidData:
                    print(networkError)
                default:
                    print("Unidentified Error")
                }
            
            }
        }
    }
    
//    func getImage(urlStr: String) -> () {
//        var uiImage: UIImage?
//        APIController.shared.fetchImage(urlStr) { (result) in
//            switch result {
//            case .success(let image):
//                uiImage = image
//            case .failure(let networkError):
//                switch networkError {
//                case .invalidUrl:
//                    print(networkError)
//                case .invalidResponse:
//                    print(networkError)
//                case .requestFailed(let error):
//                    print(networkError, error)
//                case .invalidData:
//                    print(networkError)
//                default:
//                    print("Unidentified Error")
//                }
//
//            }
//        }
//    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionViewLayout()
        getAPIData()
        
//        APIController.shared.fetchAPIData { (apiData) in
//            self.apiData = apiData!
//        }
        
        let colour1 = #colorLiteral(red: 0.3803921569, green: 0.2901960784, blue: 0.8274509804, alpha: 1).cgColor
        let colour2 = #colorLiteral(red: 0.924761951, green: 0.2762447596, blue: 0.4667485952, alpha: 1).cgColor
        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        gradient.colors = [colour1,colour2]
        gradient.locations = [0, 1]

        view.layer.insertSublayer(gradient, at: 0)

    }
    
    private func setCollectionViewLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        
        let cellPerRow: CGFloat = 4
        let cellSpacing: CGFloat = 10
        let lineSpacing: CGFloat = 10
        let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
        let widthPerItem = floor((collectionViewOutlet.frame.width - (sectionInsets.left + sectionInsets.right) - cellSpacing * (cellPerRow - 1)) / 4)
        flowLayout.itemSize = CGSize(width: widthPerItem, height: widthPerItem)
        
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = cellSpacing
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.sectionInset = sectionInsets
        
        collectionViewOutlet.collectionViewLayout = flowLayout
    }
    
    private func getAPIData() {
        APIController.shared.fetchAPIData { (result) in
            switch result {
            case .success(let apiData):
                self.apiData = apiData
                DispatchQueue.main.async {
                    self.collectionViewOutlet.reloadData()
                }
            case.failure(let networkError):
                switch networkError {
                case .decodingError:
                    print(networkError)
                case .invalidData:
                    print(networkError)
                case .invalidResponse:
                    print(networkError)
                case .invalidUrl:
                    print(networkError)
                case .requestFailed(let error):
                    print(networkError, error)
                    
                }
            }
        }
    }
    
}


extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

extension UIColor
{
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50
    }
}
