import SwiftUI

struct AboutSheetView: View {
    @State private var animateContent = false
    @State private var selectedValueIndex: Int? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section with Brand Identity
                    heroSection
                    
                    // Mission & Vision
                    missionSection
                    
                    // Core Values Grid
                    valuesSection
                    
                    // Sustainability Metrics
                    sustainabilitySection
                    
                    // Brand Story Timeline
                    storySection
                    
                    // Call to Action
                    ctaSection
                }
                .animation(.easeInOut(duration: 0.8), value: animateContent)
            }
            .navigationTitle("About Kaayko")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(20)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 24) {
            // Animated Brand Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateContent ? 1.0 : 0.8)
                    .opacity(animateContent ? 1.0 : 0.0)
                
                Text("K")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(animateContent ? 1.0 : 0.5)
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateContent)
            
            VStack(spacing: 12) {
                Text("KAAYKO")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : 20)
                
                Text("Timeless Quality • Modern Design")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : 20)
            }
            .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateContent)
        }
        .padding(.vertical, 32)
    }
    
    // MARK: - Mission Section
    private var missionSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Our Mission")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .opacity(animateContent ? 1.0 : 0.0)
            .offset(x: animateContent ? 0 : -30)
            .animation(.easeInOut(duration: 0.6).delay(0.3), value: animateContent)
            
            Text("""
                At Kaayko, we strive to bring timeless quality and modern design into every product we create. Our mission is to empower individuality through sustainable craftsmanship and innovative style.
                
                We believe that true self-expression comes from wearing products that not only look great but are built to last, creating a positive impact on both people and planet.
                """)
                .font(.system(size: 16, weight: .regular))
                .lineSpacing(4)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeInOut(duration: 0.6).delay(0.4), value: animateContent)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
    
    // MARK: - Values Section
    private var valuesSection: some View {
        VStack(spacing: 24) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Our Values")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .opacity(animateContent ? 1.0 : 0.0)
            .offset(x: animateContent ? 0 : -30)
            .animation(.easeInOut(duration: 0.6).delay(0.5), value: animateContent)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 1), spacing: 16) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    ValueCard(
                        value: value,
                        isSelected: selectedValueIndex == index,
                        animationDelay: Double(index) * 0.1 + 0.6
                    ) {
                        withAnimation(.spring()) {
                            selectedValueIndex = selectedValueIndex == index ? nil : index
                        }
                        
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : 30)
                    .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.1 + 0.6), value: animateContent)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Sustainability Section
    private var sustainabilitySection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Sustainability Impact")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .opacity(animateContent ? 1.0 : 0.0)
            .offset(x: animateContent ? 0 : -30)
            .animation(.easeInOut(duration: 0.6).delay(0.9), value: animateContent)
            
            VStack(spacing: 16) {
                SustainabilityMetric(
                    title: "Organic Materials",
                    value: "85%",
                    icon: "leaf.fill",
                    color: .green,
                    animationDelay: 1.0
                )
                
                SustainabilityMetric(
                    title: "Carbon Neutral",
                    value: "100%",
                    icon: "globe.americas.fill",
                    color: .blue,
                    animationDelay: 1.1
                )
                
                SustainabilityMetric(
                    title: "Recycled Packaging",
                    value: "95%",
                    icon: "arrow.3.trianglepath",
                    color: .orange,
                    animationDelay: 1.2
                )
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.5))
                .padding(.horizontal, 16)
        )
    }
    
    // MARK: - Story Section
    private var storySection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Our Journey")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .opacity(animateContent ? 1.0 : 0.0)
            .offset(x: animateContent ? 0 : -30)
            .animation(.easeInOut(duration: 0.6).delay(1.3), value: animateContent)
            
            VStack(spacing: 16) {
                TimelineItem(
                    year: "2019",
                    title: "Founded",
                    description: "Started with a vision for sustainable fashion",
                    animationDelay: 1.4
                )
                
                TimelineItem(
                    year: "2021",
                    title: "Global Expansion",
                    description: "Reached customers in 25+ countries",
                    animationDelay: 1.5
                )
                
                TimelineItem(
                    year: "2023",
                    title: "Carbon Neutral",
                    description: "Achieved 100% carbon neutral operations",
                    animationDelay: 1.6
                )
                
                TimelineItem(
                    year: "2024",
                    title: "Innovation Hub",
                    description: "Launched sustainable materials research center",
                    animationDelay: 1.7
                )
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - CTA Section
    private var ctaSection: some View {
        VStack(spacing: 16) {
            Text("Join Our Journey")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Be part of the sustainable fashion revolution")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                // Handle newsletter signup or social follow
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Stay Updated")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
            .scaleEffect(animateContent ? 1.0 : 0.8)
            .opacity(animateContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.8), value: animateContent)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }
    
    // MARK: - Data
    private let values = [
        Value(
            icon: "leaf.fill",
            title: "Sustainability",
            description: "Committed to eco-friendly materials and ethical manufacturing processes that protect our planet.",
            color: .green,
            details: "We use 85% organic materials and maintain carbon-neutral operations across our entire supply chain."
        ),
        Value(
            icon: "award.fill",
            title: "Quality",
            description: "Every piece is crafted with attention to detail and built to withstand time.",
            color: .orange,
            details: "Our products undergo rigorous quality testing and come with a lifetime craftsmanship guarantee."
        ),
        Value(
            icon: "heart.fill",
            title: "Community",
            description: "Supporting local artisans and building meaningful connections with our customers.",
            color: .red,
            details: "We partner with over 50 local artisans and donate 2% of profits to community development programs."
        )
    ]
}

// MARK: - Supporting Views
struct Value {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let details: String
}

struct ValueCard: View {
    let value: Value
    let isSelected: Bool
    let animationDelay: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: value.icon)
                        .font(.title2)
                        .foregroundColor(value.color)
                        .frame(width: 32, height: 32)
                    
                    Text(value.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isSelected ? 180 : 0))
                }
                
                Text(value.description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                if isSelected {
                    Text(value.details)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct SustainabilityMetric: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let animationDelay: Double
    
    @State private var animateProgress = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .scaleEffect(animateProgress ? 1.0 : 0.9)
        .opacity(animateProgress ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(animationDelay)) {
                animateProgress = true
            }
        }
    }
}

struct TimelineItem: View {
    let year: String
    let title: String
    let description: String
    let animationDelay: Double
    
    @State private var animateItem = false
    
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 2, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(year)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.orange)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .opacity(animateItem ? 1.0 : 0.0)
        .offset(x: animateItem ? 0 : -30)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(animationDelay)) {
                animateItem = true
            }
        }
    }
}

#Preview {
    AboutSheetView()
}
