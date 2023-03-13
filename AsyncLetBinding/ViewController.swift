//
//  ViewController.swift
//  AsyncLetBinding
//
//  Created by yudonlee on 2023/03/09.
//

import UIKit

fileprivate enum ImageURL {
    private static let imageIds: [String] = [
        "europe-4k-1379801",
        "cool-lion-167408",
        "iron-man-323408"
    ]
    
    static subscript(index: Int) -> URL {
        let id = imageIds[index]
        return URL(string: "https://wallpaperaccess.com/download/"+id)!
    }
}

class ViewController: UIViewController, URLSessionTaskDelegate {
    
    @IBOutlet private var imageViews: [UIImageView]!
    @IBOutlet private var progressViews: [UIProgressView]!
    @IBOutlet weak var serialImageDownloadButton: UIButton!
    @IBOutlet weak var concurrentImageDownloadButton: UIButton!
    private var observations: [NSKeyValueObservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serialImageDownloadButton.setTitle("Serial Load All Images", for: .normal)
        serialImageDownloadButton.setTitle("Loading", for: .disabled)
        
        concurrentImageDownloadButton.setTitle("Loading", for: .disabled)
        concurrentImageDownloadButton.setTitle("Concurrent Load Images", for: .normal)
    }
    
    @IBAction func serialImageDownloadButtonTapped(_ sender: UIButton) {
        imageViews.forEach { $0.image = UIImage(systemName: "photo")}
        progressViews.forEach { $0.progress = Float(0) }
        sender.configuration?.showsActivityIndicator = true
        sender.isEnabled = false
        
        Task {
            let image1 = try await downloadImage(id: 0)
            let image2 = try await downloadImage(id: 1)
            let image3 = try await downloadImage(id: 2)
            let images = [image1, image2, image3]
            
            images.enumerated().forEach { imageViews[$0].image = $1 }
            sender.configuration?.showsActivityIndicator = false
            sender.isEnabled = true

        }

    }
    
    @IBAction func concurrentImageDownloadButton(_ sender: UIButton) {
        imageViews.forEach { $0.image = UIImage(systemName: "photo")}
        progressViews.forEach { $0.progress = Float(0) }
        sender.isEnabled = false
        sender.configuration?.showsActivityIndicator = true
        
        Task {
            async let image1 = downloadImage(id: 0)
            async let image2 = downloadImage(id: 1)
            async let image3 = downloadImage(id: 2)
            let images = try await [image1, image2, image3]
            
            images.enumerated().forEach { imageViews[$0].image = $1 }
            sender.configuration?.showsActivityIndicator = false
            sender.isEnabled = true

        }
    }
    
    func downloadImage(id: Int) async throws -> UIImage {
        let url = ImageURL[id]
          let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url), delegate: self)
        guard let httpStatusCode = response as? HTTPURLResponse else { throw ErrorLiteral.HttpError.invalidHttpResponse}
        
        guard httpStatusCode.statusCode == 200 else { throw ErrorLiteral.HttpError.invalidStatusCode(code: httpStatusCode.statusCode)}
        
        guard let image = UIImage(data: data) else { throw ErrorLiteral.HttpError.failedToConvertDataToImage }
        return image
    }
    
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        var progressIdx = 0
        for i in 0...2 {
            if ImageURL[i] == task.currentRequest?.url {
                progressIdx = i
                break
            }
        }
        
        let observation: NSKeyValueObservation = task.progress.observe(\.fractionCompleted) { progress, value in
            DispatchQueue.main.async {
                print(progress)
                self.progressViews[progressIdx].progress = Float(progress.fractionCompleted)
            }
        }
        observations.append(observation)
    }
}

enum ErrorLiteral {
    enum HttpError: Error {
        case invalidURL
        case invalidHttpResponse
        case invalidStatusCode(code: Int)
        case failedToConvertDataToImage
    }
}

