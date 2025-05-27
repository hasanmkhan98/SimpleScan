//
//  PDFGenerator.swift
//  PDF App
//
//  Created by Hasan Khan on 5/23/25.
//

import UIKit
import PDFKit

func createTextOnlyPDF(from recognizedText: String) -> PDFDocument {
    // Create mutable data buffer
    let pdfData = NSMutableData()
    
    let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)

    // Begin PDF context
    UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
    UIGraphicsBeginPDFPageWithInfo(pageRect, nil)

    // Define text layout
    let textRect = CGRect(x: 40, y: 40, width: pageRect.width - 80, height: pageRect.height - 80)
    let textStyle = NSMutableParagraphStyle()
    textStyle.lineBreakMode = .byWordWrapping

    let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14),
        .paragraphStyle: textStyle
    ]

    // Draw text onto PDF page
    recognizedText.draw(in: textRect, withAttributes: attributes)

    // Close context
    UIGraphicsEndPDFContext()

    // Create PDFDocument from data
    return PDFDocument(data: pdfData as Data) ?? PDFDocument()
}


