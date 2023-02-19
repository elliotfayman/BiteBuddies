//
//  CameraView.swift
//  BiteBuddies
//
//  Created by Marielle Baumgartner on 2/18/23.
//

import Foundation

import Foundation
import UIKit
import SwiftUI
import Vision

import SwiftUI

import SwiftUI
import UIKit

public struct CameraView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    struct AlertView: View {
        @Binding var recipeData: String? // Bind the recipe data
        
        var body: some View {
            NavigationView {
                VStack {
                    HStack {
                        Text("Congratulations! You've been matched with...")
                        if let rec = recipeData {
                            Text(rec)
                        }
                    }
                    .padding()
                    Spacer()
                    
                    Spacer()
                }
                .navigationTitle("BiteBuddies")
            }
        }
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    
    
    @Binding var recipeData: String? // Add a binding to the recipe data
    @State private var isPhotoSelected = false
    public typealias UIViewControllerType = UIImagePickerController
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
            let viewController = UIImagePickerController()
            viewController.delegate = context.coordinator
            viewController.sourceType = .camera
            let usePhotoButton = UIBarButtonItem(title: "Use Photo", style: .done, target: context.coordinator, action: #selector(Coordinator.usePhotoButtonTapped))
            viewController.navigationItem.rightBarButtonItem = usePhotoButton // add this line
            return viewController
        }
    
    public func makeCoordinator() -> CameraView.Coordinator {
        return Coordinator(self)
    }
    
    // Pass the recipe data obtained from imageToText to the ContentView
    public func showRecipeData(_ recipeData: String?) {
        self.recipeData = recipeData
    }
    
    public func makeAlert() -> Alert {
        Alert(title: Text("Recipe Data"), message: Text(recipeData ?? ""), dismissButton: .default(Text("OK")))
    }
    
    public class Coordinator : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView
            
            init(_ parent: CameraView) {
                self.parent = parent
                
        }
        
        @objc func usePhotoButtonTapped(_ sender: UIBarButtonItem) {
            sender.isEnabled = false
            self.parent.isPhotoSelected = true // set isPhotoSelected to true when the "Use Photo" button is tapped
            self.parent.presentationMode.wrappedValue.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.presentationMode.wrappedValue.dismiss()
            print("Cancel pressed")
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // Call imageToText with a closure to handle the result.
                imageToText(image) { res in
                    if let res = res {
                        // Use the result here or pass it to another function.
                        print("****")
                        print("Result: \(res)")
                        //self.parent.showRecipeData(res)
                        DispatchQueue.main.async { [self] in
                            
                            self.parent.showRecipeData(String(res.dropFirst(13).dropLast(3).replacingOccurrences(of: "\",\"", with: "\n"))) // Pass the recipe data to the ContentView
                            self.parent.isPhotoSelected = true // Set isPhotoSelected to true
                            self.parent.presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        print("Error: unable to recognize text")
                    }
                }
                // Remove the line that was previously here (NavigationLink)
                //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
}



func getRec(str: String, completion: @escaping (String?) -> Void) {
    let modifiedStr = str.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
    if let url = URL(string: "https://elliotfayman.pythonanywhere.com/get_recipes?foods=\(modifiedStr)") {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: invalid HTTP response")
                completion(nil)
                return
            }

            guard let data = data else {
                print("Error: no response data")
                completion(nil)
                return
            }

            if let result = String(data: data, encoding: .utf8) {
                completion(result)
            } else {
                print("Error: unable to convert response data to string")
                completion(nil)
            }
        }

        task.resume()
    } else {
        print("Error: invalid URL")
        completion(nil)
    }
}




// Get the CGImage on which to perform requests.
func imageToText(_ image: UIImage, completion: @escaping (String?) -> Void) {
    guard let cgImage = image.cgImage else {
        completion(nil)
        return
    }
    
    // Create a new image-request handler.
    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
    
    // Create a new request to recognize text.
    let request = VNRecognizeTextRequest(completionHandler: { request, error in
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            completion(nil)
            return
        }
        
        var recognizedText = ""
        
        // Concatenate the top recognized texts for each observation.
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            recognizedText += "\(topCandidate.string)\n"
        }
        
        // Remove any whitespace from the recognized text.
        let str = recognizedText.replacingOccurrences(of: " ", with: "")
        
        // Call getRec to get recipe data for the recognized text.
        getRec(str: str) { result in
            completion(result)
        }
    })
    
    do {
        // Perform the text-recognition request.
        try requestHandler.perform([request])
    } catch {
        completion(nil)
    }
}

func recognizeTextHandler(request: VNRequest, error: Error?) {
    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
    
    var recognizedText = ""
    
    // Concatenate the top recognized texts for each observation.
    for observation in observations {
        guard let topCandidate = observation.topCandidates(1).first else { continue }
        
        recognizedText += "\(topCandidate.string)\n"
    }
    
    // Print the recognized text.
    print("And the final text is....")
    let str = ((recognizedText.components(separatedBy: "\n")).joined(separator: ",")).replacingOccurrences(of: " ", with: "")
    print(str)
    print("***")
    print(getRec(str: str){ result in
        if let result = result {
            print("Result: \(result)")
        } else {
            print("Error: unable to get recipe data")
        }
    })
    
}
