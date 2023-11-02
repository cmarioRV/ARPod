//
//  File.swift
//  
//
//  Created by Mario Rúa on 1/11/23.
//

import Foundation
import SwiftUI

struct ColorItem: Identifiable {
  var id = UUID()
  let name: String
  let color: UIColor
}

let colorItems: [ColorItem] = [
  ColorItem(name: "blackColor", color: UIColor(hex: "#000000")),
  ColorItem(name: "brownColor", color: UIColor(hex: "#964B00")),
  ColorItem(name: "darkGrayColor", color: UIColor(hex: "#A9A9A9")),
  ColorItem(name: "navyBlueColor", color: UIColor(hex: "#000080")),
  ColorItem(name: "greenColor", color: UIColor(hex: "#008000")),
  ColorItem(name: "purpleColor", color: UIColor(hex: "#800080"))
]

enum FaceFeature: String, CaseIterable, Identifiable {
  case eyeShadow
  case eyeLiner
  case lips

  var id: Self { self }
}


@available(iOS 13.0, *)
struct ShowCaseSettingsView: View {
    var onSelect: (UIColor, FaceFeature) -> Void
    @State private var selectedFlavor: FaceFeature = .lips
    
    var body: some View {
        List {
            Section {
                Picker("Face Feature", selection: $selectedFlavor) {
                    ForEach(FaceFeature.allCases) { flavor in
                        Text(flavor.rawValue.capitalized)
                    }
                }
            }
            Section {
                ForEach(colorItems) { colorItem in
                    HStack {
                        Text(colorItem.name)
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 8.0)
                            .fill(Color(colorItem.color))
                            .frame(width: 30, height: 30)
                    }
                    .onTapGesture {
                        onSelect(colorItem.color, selectedFlavor)
                    }
                }
            }
        }
    }
}

