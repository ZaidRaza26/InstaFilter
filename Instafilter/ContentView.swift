//
//  ContentView.swift
//  Instafilter
//
//  Created by Zaid Raza on 28/11/2020.
//  Copyright © 2020 Zaid Raza. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    
    @State private var showingImagePicker = false
    @State private var showingFilterSheet = false
    @State private var noImageError = false
    @State private var radiusDisabled = true
    @State private var intensityDisabled = false
    
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var image: Image?
    
    @State private var filterIntensity = 0.5
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    
    @State private var filterName = "Change Filter"
    
    let context = CIContext()
    
    
    var body: some View {
        
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
        },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
        }
        )
        
        return NavigationView{
            VStack{
                ZStack{
                    Rectangle()
                        .fill(Color.secondary)
                    
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    }
                    else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true
                }
                
                HStack{
                    Text("Intensity")
                    Slider(value: intensity)
                        .disabled(intensityDisabled)
                    
                    Text("Radius")
                    Slider(value: intensity)
                        .disabled(radiusDisabled)
                }.padding(.vertical)
                
                HStack{
                    
                    Button(filterName){
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save"){
                        guard let processedImage = self.processedImage else {
                            self.noImageError = true
                            return
                        }
                        
                        let imageSaver = ImageSaver()
                        imageSaver.successHandler = {
                            print("Success!")
                        }
                        
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                        
                    }
                }
            }
            .padding([.horizontal,.bottom])
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage){
                ImagePicker(image: self.$inputImage)
            }
                
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystallize")) { self.setFilter(CIFilter.crystallize()); self.filterName = "Crystallize" },
                    .default(Text("Edges")) { self.setFilter(CIFilter.edges()); self.filterName = "Edges" },
                    .default(Text("Gaussian Blur")) { self.setFilter(CIFilter.gaussianBlur()); self.filterName = "Gaussian Blur" },
                    .default(Text("Pixellate")) { self.setFilter(CIFilter.pixellate()); self.filterName = "Pixellate" },
                    .default(Text("Sepia Tone")) { self.setFilter(CIFilter.sepiaTone()); self.filterName = "Sepia Tone" },
                    .default(Text("Unsharp Mask")) { self.setFilter(CIFilter.unsharpMask()); self.filterName = "Unsharp Mask" },
                    .default(Text("Vignette")) { self.setFilter(CIFilter.vignette()); self.filterName = "Vignette" },
                    .cancel()
                ])
            }
                
            .alert(isPresented: $noImageError){
                Alert(title: Text("No Image"), message: Text("Please select an Image to save"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func setFilter(_ filter: CIFilter){
        currentFilter = filter
        loadImage()
    }
    
    func applyProcessing() {
        
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
            self.radiusDisabled = true
            self.intensityDisabled = false
        }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
            self.radiusDisabled = false
            self.intensityDisabled = true
        }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            
            processedImage = uiImage
        }
    }
    
    func loadImage(){
        guard let inputImage = inputImage else { return }
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
