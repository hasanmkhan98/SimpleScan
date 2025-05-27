//
//  ScanWrap.swift
//  PDF App
//
//  Created by Hasan Khan on 5/11/25.
//

import SwiftUI
import VisionKit
import Vision

struct ScanWrap: UIViewControllerRepresentable {
    @Binding var recognizedText: String
    @Binding var scannedImage: UIImage?
    var selectedLanguage: String

    typealias UIViewControllerType = VNDocumentCameraViewController

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ScanWrap

        init(parent: ScanWrap) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true)

            guard scan.pageCount > 0 else { return }
            let image = scan.imageOfPage(at: 0)
            self.parent.scannedImage = image
            recognizeText(from: image)
        }

        func recognizeText(from image: UIImage) {
            guard let cgImage = image.cgImage else {
                print("Failed to get CGImage from UIImage.")
                return
            }

            let request = VNRecognizeTextRequest { (request, error) in
                if let error = error {
                    print("OCR error: \(error.localizedDescription)")
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("No recognized text observations found.")
                    return
                }

                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }

                if recognizedStrings.isEmpty {
                    print("OCR returned empty strings — possible unsupported language.")
                }

                DispatchQueue.main.async {
                    self.parent.recognizedText = recognizedStrings.joined(separator: "\n")
                    print("OCR Results: \(recognizedStrings)")
                }
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = [parent.selectedLanguage]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("OCR handler failed: \(error)")
                }
            }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true)
            print("Scan Failed: \(error.localizedDescription)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        //
    }
}

