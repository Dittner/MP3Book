//
//  SliderView.swift
//  MP3Book
//
//  Created by Alexander Dittner on 17.02.2021.
//

import Combine
import SwiftUI

struct SliderView: View {
    @Binding var progress: Double
    @State var isDragging = false
    @State var dragProgress: Double = 0.0
    let minValue: Double
    let maxValue: Double
    let distance: Double

    let sliderHeight: CGFloat = Constants.size.playerSliderHeight
    let thumbRadius: CGFloat = Constants.size.playerSliderHeight / 2
    let trackHeight: CGFloat
    let trackColor: Color

    let dragComplete: ((Double) -> Void)?

    init(progress: Binding<Double>, minValue: Double = 0, maxValue: Double = 100, trackHeight: CGFloat = 2, trackColor: Color = .gray, dragComplete: ((Double) -> Void)? = nil) {
        _progress = progress
        self.minValue = minValue
        self.maxValue = maxValue
        distance = maxValue - minValue
        self.trackHeight = trackHeight
        self.trackColor = trackColor
        self.dragComplete = dragComplete
    }

    func countProgress(_ percentage: CGFloat) -> Double {
        return min(max(0.0, Double(percentage)), 1.0) * (maxValue - minValue) + minValue
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .frame(height: trackHeight)
                    .padding(.horizontal, -thumbRadius)
                    .offset(x: 0, y: (sliderHeight - trackHeight) / 2)
                    .foregroundColor(trackColor)

                if distance > 0 {
                    if let curProgress = isDragging ? dragProgress : progress {
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat((curProgress - minValue) / distance) + 2 * thumbRadius, height: trackHeight)
                            .padding(.horizontal, -thumbRadius)
                            .offset(x: 0, y: (sliderHeight - trackHeight) / 2)
                            .foregroundColor(.accentColor)

                        Circle()
                            .foregroundColor(.accentColor)
                            .frame(width: 2 * thumbRadius, height: 2 * thumbRadius)
                            .offset(x: geometry.size.width * CGFloat((curProgress - minValue) / distance) - thumbRadius, y: sliderHeight / 2 - thumbRadius)
                            .gesture(DragGesture(minimumDistance: 0)
                                .onEnded({ value in
                                    self.progress = countProgress(value.location.x / geometry.size.width)
                                    self.dragProgress = countProgress(value.location.x / geometry.size.width)
                                    self.dragComplete?(self.progress)
                                    Async.after(milliseconds: 200) {
                                        self.isDragging = false
                                    }
                                })
                                .onChanged({ value in
                                    self.dragProgress = countProgress(value.location.x / geometry.size.width)
                                    self.isDragging = true
                                }))
                    }
                }
            }

        }.frame(height: sliderHeight)
            .padding(.horizontal, thumbRadius)
    }
}
