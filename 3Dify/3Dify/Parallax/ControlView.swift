//
//  ControlView.swift
//  3Dify
//
//  Created by It's free real estate on 29.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI


struct ControlViewDivider: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
        .frame(height: 1)
        .padding(.vertical, 12)
        .foregroundColor(Color.gray.opacity(0.1))
    }
}


struct ControlView<Content: View>: View {
    @Binding var isShowingControls: Bool
    @Binding var selectedAnimationInterval: TimeInterval
    @Binding var selectedAnimationIntensity: Float
    @Binding var selectedBokehIntensity: Float
    @Binding var selectedAnimationTypeRawValue: Int
    @Binding var selectedFocalPoint: Float
    
    @State var hourglassAngle: Double = 0.0
    @State var isShowingSettings = false
    
    var onShowPicker: () -> Void
    var onShowCamera: () -> Void
    var onSaveVideo: () -> Void
    
    var springAnimation: Animation {
        .interpolatingSpring(stiffness: 300.0, damping: 20.0, initialVelocity: 10.0)
    }
    
    var content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            if self.isShowingControls {
                HStack {
                    Button(action: self.onShowPicker) {
                        Image(systemName: "cube.box.fill")
                    }
                    Spacer()
                    Button(action: self.onShowCamera) {
                        Image(systemName: "camera.fill")
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.isShowingSettings.toggle()
                        }
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(self.isShowingSettings ? Color.yellow : Color.white)
                    }
                }
                .padding(24)
                .padding(.top, 48)
                .background(Color.black)
                .foregroundColor(Color.white)
                .transition(.opacity)
            }
            
            if isShowingSettings {
                ScrollView {
                    ControlViewDivider()
                    
                    ZStack(alignment: .bottom) {
                        Slider(value: self.$selectedAnimationInterval, in: 0.5...30)
                        .padding(.bottom, 24)
                        HStack {
                            Text("0.5s").font(.footnote)
                            Spacer()
                            Text("5s").font(.footnote)
                        }
                        Text("Interval").font(.footnote)
                    }
                    .padding(.horizontal, 24)
                    
                    ControlViewDivider()
                    
                    ZStack(alignment: .bottom) {
                        Slider(value: self.$selectedAnimationIntensity, in: 0...0.1)
                        .padding(.bottom, 24)
                        HStack {
                            Text("Weak").font(.footnote)
                            Spacer()
                            Text("Strong").font(.footnote)
                        }
                        Text("Intensity").font(.footnote)
                    }
                    .padding(.horizontal, 24)
                    
                    ControlViewDivider()
                    
                    ZStack(alignment: .bottom) {
                        Slider(value: self.$selectedFocalPoint, in: 0...1)
                        .padding(.bottom, 24)
                        HStack {
                            Text("Far").font(.footnote)
                            Spacer()
                            Text("Near").font(.footnote)
                        }
                        Text("Focal Point").font(.footnote)
                    }
                    .padding(.horizontal, 24)
                    
                    ControlViewDivider()
                    
                    ZStack(alignment: .bottom) {
                        Slider(value: self.$selectedBokehIntensity, in: 0...50)
                        .padding(.bottom, 24)
                        HStack {
                            Text("Far").font(.footnote)
                            Spacer()
                            Text("Near").font(.footnote)
                        }
                        Text("Focal Point").font(.footnote)
                    }
                    .padding(.horizontal, 24)
                    
                    ControlViewDivider()
                    
                    Picker(selection: self.$selectedAnimationTypeRawValue, label: Text("Animation")) {
                        ForEach(ImageParallaxAnimationType.all, id: \.rawValue) {animationType in
                            Text(animationType.description)
                            .tag(animationType.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(2)
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 12)
                .background(Color(hex: "#111"))
                .foregroundColor(Color.white)
                .accentColor(Color.yellow)
                .transition(.opacity)
            }

            self.content()
            
            if self.isShowingControls && !self.isShowingSettings {
                HStack {
                    Spacer()
                    Button(action: self.onSaveVideo) {
                        Image(systemName: "film")
                            .foregroundColor(Color.black)
                    }
                    .buttonStyle(CameraButtonStyle())
                    Spacer()
                }
                .padding(.bottom, 64)
                .padding(.top, 32)
                .padding(12)
                .background(Color.black)
                .accentColor(Color.yellow)
                .foregroundColor(Color.white)
                .transition(.opacity)
            }
        }
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView(isShowingControls: .constant(true),
                    selectedAnimationInterval: .constant(2),
                    selectedAnimationIntensity: .constant(0.05),
                    selectedBokehIntensity: .constant(5),
                    selectedAnimationTypeRawValue: .constant(0),
                    selectedFocalPoint: .constant(0),
                    isShowingSettings: true,
                    onShowPicker: {},
                    onShowCamera: {},
                    onSaveVideo: {}) {
            VStack {
                HStack {
                    Spacer()
                }
                Spacer()
            }.background(Color.yellow)
        }.edgesIgnoringSafeArea(.vertical)
    }
}
