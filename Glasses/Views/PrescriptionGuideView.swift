import SwiftUI

struct PrescriptionGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Understanding Your Prescription")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Everything you need to know about those mysterious numbers")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 24)
                
                // OD and OS Explanation
                InfoSection(
                    title: "OD and OS - Which Eye?",
                    icon: "eye.fill",
                    color: .blue
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(
                            term: "OD (Oculus Dexter)",
                            definition: "Your RIGHT eye",
                            example: "Always listed first on prescriptions"
                        )
                        
                        Divider()
                        
                        InfoRow(
                            term: "OS (Oculus Sinister)",
                            definition: "Your LEFT eye",
                            example: "Listed second on prescriptions"
                        )
                        
                        Divider()
                        
                        InfoRow(
                            term: "OU (Oculus Uterque)",
                            definition: "Both eyes",
                            example: "Sometimes used when both eyes have the same prescription"
                        )
                    }
                }
                
                // Sphere Explanation
                InfoSection(
                    title: "Sphere (SPH) - Nearsighted or Farsighted?",
                    icon: "circle.circle",
                    color: .green
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This measures the main correction needed for your vision.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        InfoRow(
                            term: "Minus (-) values",
                            definition: "Nearsighted (Myopia)",
                            example: "You can see close objects clearly, but distant objects are blurry. Example: -3.00"
                        )
                        
                        Divider()
                        
                        InfoRow(
                            term: "Plus (+) values",
                            definition: "Farsighted (Hyperopia)",
                            example: "You can see distant objects clearly, but close objects are blurry. Example: +2.50"
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Strength Guide:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            StrengthIndicator(range: "0.00 to ±2.00", strength: "Mild", color: .green)
                            StrengthIndicator(range: "±2.25 to ±4.00", strength: "Moderate", color: .yellow)
                            StrengthIndicator(range: "±4.25 to ±6.00", strength: "Strong", color: .orange)
                            StrengthIndicator(range: "±6.25+", strength: "Very Strong", color: .red)
                        }
                        .padding()
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                }
                
                // Cylinder Explanation
                InfoSection(
                    title: "Cylinder (CYL) - Do You Have Astigmatism?",
                    icon: "oval",
                    color: .purple
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This measures astigmatism - when your cornea is shaped more like a football than a basketball.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        InfoRow(
                            term: "No value or 0.00",
                            definition: "No astigmatism",
                            example: "Your cornea is nicely round"
                        )
                        
                        Divider()
                        
                        InfoRow(
                            term: "Any other value",
                            definition: "You have astigmatism",
                            example: "Usually negative (-), sometimes positive (+). Example: -1.50"
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💡 Did you know?")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Text("Most people have at least a small amount of astigmatism. It's completely normal!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                // Axis Explanation
                InfoSection(
                    title: "Axis - Which Direction?",
                    icon: "rotate.3d",
                    color: .orange
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("If you have astigmatism (CYL value), the axis tells us the angle of correction needed.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        InfoRow(
                            term: "Range: 1° to 180°",
                            definition: "The orientation of your astigmatism",
                            example: "90° is vertical, 180° is horizontal"
                        )
                        
                        HStack(spacing: 16) {
                            VStack {
                                Image(systemName: "arrow.up")
                                    .font(.title)
                                    .foregroundColor(.orange)
                                Text("90°")
                                    .font(.caption)
                                Text("Vertical")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.tertiarySystemGroupedBackground))
                            .cornerRadius(12)
                            
                            VStack {
                                Image(systemName: "arrow.right")
                                    .font(.title)
                                    .foregroundColor(.orange)
                                Text("180°")
                                    .font(.caption)
                                Text("Horizontal")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.tertiarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Important:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Text("The axis only matters if you have a cylinder value. No cylinder? No axis needed!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                // PD Explanation
                InfoSection(
                    title: "PD (Pupillary Distance)",
                    icon: "faceid",
                    color: .cyan
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("The distance between the centers of your pupils in millimeters.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        InfoRow(
                            term: "Why it matters",
                            definition: "Optical center alignment",
                            example: "The lens centers must align with your pupils for clear, comfortable vision"
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Average PD Ranges:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            HStack {
                                Label("Adults", systemImage: "person.fill")
                                    .font(.caption)
                                Spacer()
                                Text("54-74mm")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Label("Children", systemImage: "figure.and.child.holdinghands")
                                    .font(.caption)
                                Spacer()
                                Text("43-58mm")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💡 Pro Tip:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Text("Use our AR face scanner to measure your PD accurately at home!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.cyan.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                // Example Prescription
                ExamplePrescriptionCard()
                
                // Tips Section
                TipsCard()
                
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Prescription Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Info Section

struct InfoSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
            }
            
            content
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let term: String
    let definition: String
    let example: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(term)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(definition)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Text(example)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Strength Indicator

struct StrengthIndicator: View {
    let range: String
    let strength: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(range)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(strength)
                .font(.caption2)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Example Prescription Card

struct ExamplePrescriptionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title3)
                    .foregroundColor(.indigo)
                
                Text("Example Prescription")
                    .font(.headline)
            }
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 0) {
                    Text("")
                        .frame(width: 60, alignment: .leading)
                    Text("SPH")
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("CYL")
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("AXIS")
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 8)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                
                Divider()
                
                // OD Row
                HStack(spacing: 0) {
                    Text("OD")
                        .fontWeight(.semibold)
                        .frame(width: 60, alignment: .leading)
                    Text("-3.25")
                        .frame(maxWidth: .infinity)
                        .font(.system(.body, design: .monospaced))
                    Text("-1.50")
                        .frame(maxWidth: .infinity)
                        .font(.system(.body, design: .monospaced))
                    Text("90°")
                        .frame(maxWidth: .infinity)
                        .font(.system(.body, design: .monospaced))
                }
                .padding(.vertical, 12)
                
                Divider()
                
                // OS Row
                HStack(spacing: 0) {
                    Text("OS")
                        .fontWeight(.semibold)
                        .frame(width: 60, alignment: .leading)
                    Text("-3.00")
                        .frame(maxWidth: .infinity)
                        .font(.system(.body, design: .monospaced))
                    Text("-1.25")
                        .frame(maxWidth: .infinity)
                        .font(.system(.body, design: .monospaced))
                    Text("85°")
                        .frame(maxWidth: .infinity)
                        .font(.system(.body, design: .monospaced))
                }
                .padding(.vertical, 12)
            }
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .cornerRadius(12)
            
            Text("This person is moderately nearsighted with mild astigmatism in both eyes. PD: 63mm")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Tips Card

struct TipsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                
                Text("Helpful Tips")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                TipRow(
                    icon: "calendar",
                    text: "Get your eyes checked every 1-2 years, even if your vision seems fine"
                )
                
                TipRow(
                    icon: "doc.text",
                    text: "Always keep a copy of your prescription - it's yours by law!"
                )
                
                TipRow(
                    icon: "questionmark.circle",
                    text: "Don't hesitate to ask your optometrist to explain your prescription"
                )
                
                TipRow(
                    icon: "exclamationmark.triangle",
                    text: "If your vision changes suddenly, see an eye care professional immediately"
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PrescriptionGuideView()
    }
}
