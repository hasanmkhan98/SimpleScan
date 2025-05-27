//
//  ContentView.swift
//  PDF App
//
//  Created by Hasan Khan on 5/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showScanner = false
    @State private var scannedText = ""
    @State private var scannedImage: UIImage? = nil
    @State private var selectedLanguageCode = "en-US"

    let supportedLanguages: [(name: String, code: String)] = [
           ("English", "en-US"),
           ("Mandarin Chinese", "zh-Hans"),
           ("Spanish", "es-ES"),
           ("French", "fr-FR"),
           ("Russian", "ru-RU"),
           ("Portuguese", "pt-BR"),
           ("Indonesian", "id-ID"),
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("SimpleScan")
                .font(.title2)
                .bold()
            
            Picker("Select OCR Language", selection: $selectedLanguageCode) {
                ForEach(supportedLanguages, id: \.code) { language in
                    Text(language.name).tag(language.code)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            

            Button("Scan a Document") {
                showScanner = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            TextEditor(text: $scannedText)
                .padding()
                .border(Color.gray)
                .frame(height: 300)

            if !scannedText.isEmpty {
                Button("Export as PDF") {
                    let pdf = createTextOnlyPDF(from: scannedText)
                    if let data = pdf.dataRepresentation() {
                        let url = FileManager.default.temporaryDirectory.appendingPathComponent("scanned_text_only.pdf")
                        try? data.write(to: url)

                        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            rootVC.present(activityVC, animated: true)
                        }
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .sheet(isPresented: $showScanner) {
            ScanWrap(recognizedText: $scannedText, scannedImage: $scannedImage, selectedLanguage: selectedLanguageCode)
        }
    }
}

#Preview {
    ContentView()
}

