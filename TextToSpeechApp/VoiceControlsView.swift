import SwiftUI

struct VoiceControlsView: View {
    @Binding var controls: VoiceControls
    @ObservedObject var audioPlayer: AudioPlayer
    let provider: TTSProvider
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Voice Controls")
                    .font(.headline)
                
                speedControlSection
                pitchControlSection
                volumeControlSection
                playbackSpeedSection
                emotionControlSection
                resetButtonSection
                
                Spacer(minLength: 16)
            }
            .padding(16)
        }
        .frame(minWidth: 400, maxWidth: 500, minHeight: 300, maxHeight: 600)
        .background(themeManager.currentTheme == .dark ? Color(.darkGray).opacity(0.2) : Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var speedControlSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Speed")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "%.2fx", controls.speed))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            Slider(
                value: $controls.speed,
                in: speedRange,
                step: 0.05
            ) {
                Text("Speed")
            } minimumValueLabel: {
                Text(String(format: "%.1fx", speedRange.lowerBound))
                    .font(.caption2)
            } maximumValueLabel: {
                Text(String(format: "%.1fx", speedRange.upperBound))
                    .font(.caption2)
            }
        }
    }
    
    private var pitchControlSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Pitch")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "%.2fx", controls.pitch))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            Slider(
                value: $controls.pitch,
                in: 0.5...2.0,
                step: 0.05
            ) {
                Text("Pitch")
            } minimumValueLabel: {
                Text("0.5x")
                    .font(.caption2)
            } maximumValueLabel: {
                Text("2.0x")
                    .font(.caption2)
            }
        }
    }
    
    private var volumeControlSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Volume")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(controls.volume * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            Slider(
                value: Binding(
                    get: { controls.volume },
                    set: { newValue in
                        controls.volume = newValue
                        audioPlayer.volume = newValue
                    }
                ),
                in: 0.0...1.0,
                step: 0.01
            ) {
                Text("Volume")
            } minimumValueLabel: {
                Image(systemName: "speaker.fill")
                    .font(.caption2)
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption2)
            }
        }
    }
    
    private var playbackSpeedSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Playback Speed")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "%.2fx", audioPlayer.playbackSpeed))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            Slider(
                value: $audioPlayer.playbackSpeed,
                in: 0.5...2.0,
                step: 0.05
            ) {
                Text("Playback Speed")
            } minimumValueLabel: {
                Text("0.5x")
                    .font(.caption2)
            } maximumValueLabel: {
                Text("2.0x")
                    .font(.caption2)
            }
        }
    }
    
    private var emotionControlSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Voice Emotion")
                .font(.subheadline)
                .fontWeight(.medium)
            
            emotionButtonGrid
            
            emotionDescriptionText
        }
    }
    
    private var emotionButtonGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(VoiceEmotion.allCases, id: \.self) { emotion in
                emotionButton(for: emotion)
            }
        }
    }
    
    private func emotionButton(for emotion: VoiceEmotion) -> AnyView {
        let isSelected = controls.emotion == emotion
        
        if isSelected {
            return AnyView(
                Button(emotion.displayName) {
                    controls.emotion = emotion
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .controlSize(.small)
            )
        } else {
            return AnyView(
                Button(emotion.displayName) {
                    controls.emotion = emotion
                }
                .buttonStyle(BorderedButtonStyle())
                .controlSize(.small)
            )
        }
    }
    
    private var emotionDescriptionText: some View {
        Group {
            if provider == .elevenLabs {
                Text("Emotion affects voice characteristics for ElevenLabs")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("Emotion settings will be simulated for \(provider.displayName)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var resetButtonSection: some View {
        HStack {
            Spacer()
            Button("Reset to Defaults") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    controls = VoiceControls()
                    audioPlayer.volume = 1.0
                    audioPlayer.playbackSpeed = 1.0
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
    
    private var speedRange: ClosedRange<Double> {
        switch provider {
        case .openAI:
            return 0.25...4.0
        case .elevenLabs:
            return 0.5...2.0
        case .google:
            return 0.25...4.0  // Google supports similar speed range as OpenAI
        }
    }
}

#Preview {
    VoiceControlsView(
        controls: .constant(VoiceControls()),
        audioPlayer: AudioPlayer(),
        provider: .openAI
    )
    .environmentObject(ThemeManager())
    .frame(width: 400)
}