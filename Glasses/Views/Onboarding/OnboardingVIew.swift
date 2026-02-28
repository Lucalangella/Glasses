import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "Onboarding1",
            title: "Hi, I'm Luca",
            body: "I've been wearing glasses since I was nine years old. For over a decade, those little frames on my face were just something I needed to see the board at school."
        ),
        OnboardingPage(
            imageName: "Onboarding2",
            title: "A Card Full of Mysteries",
            body: "Every eye exam ended the same way: a prescription card full of numbers I didn't understand. I'd just hand it over and hope to the glasses shop and hope to get the right ones."
        ),
        OnboardingPage(
            imageName: "Onboarding3",
            title: "Then It All Made Sense",
            body: "One day, an optician finally explained it all, what sphere and cylinder mean, why axis matters, and how to choose the right frames and lenses for my eyes."
        ),
        OnboardingPage(
            imageName: "Onboarding4",
            title: "So I Built Clarity",
            body: "Prescriptions shouldn't be a secret code. I built Clarity to translate your numbers, visualize your lenses, and help you find the perfect frames."
        )
    ]
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                OnboardingPageView(
                    page: page,
                    isLastPage: index == pages.count - 1,
                    pageCount: pages.count,
                    currentPage: $currentPage,
                    hasCompletedOnboarding: $hasCompletedOnboarding
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }
}

// MARK: - Single Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let pageCount: Int
    @Binding var currentPage: Int
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Full-bleed background image
                Image(page.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                
                // Dark gradient overlay — heavier at bottom for text legibility
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.35),
                        .init(color: .black.opacity(0.3), location: 0.55),
                        .init(color: .black.opacity(0.85), location: 0.75),
                        .init(color: .black.opacity(0.95), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Bottom content card
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(page.title)
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Body text
                    Text(page.body)
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Controls row: page dots + button
                    HStack{
                        Spacer()
                        VStack {
                            // Page indicators
                            HStack(spacing: 8) {
                                ForEach(0..<pageCount, id: \.self) { index in
                                    Circle()
                                        .fill(currentPage == index ? Color.white : Color.white.opacity(0.35))
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3), value: currentPage)
                                }
                            }
                            .padding()
                            
                            
                            // Next / Get Started button
                            Button(action: {
                                if isLastPage {
                                    withAnimation {
                                        hasCompletedOnboarding = true
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.35)) {
                                        currentPage += 1
                                    }
                                }
                            }) {
                                Text(isLastPage ? "Get Started" : "Next")
                                    .frame(maxWidth: .infinity)
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 12)
                                    .background(.blue)
                                    .cornerRadius(24)
                            }
                                                .padding(.vertical, 16)
                        }
                        .padding(.top, 32)
                        Spacer()
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .cornerRadius(24)
                .padding(.horizontal, 24)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Model

struct OnboardingPage {
    let imageName: String
    let title: String
    let body: String
}

// MARK: - Preview

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
