import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false

    let colors: [Color] = [
        Color(hex: "#E53935"),   // Red (Must)
        Color(hex: "#FB8C00"),   // Orange (Should)
        Color(hex: "#1E88E5"),   // Blue (Could)
        DS.Colors.sage,
        DS.Colors.lavender,
        DS.Colors.coral,
        DS.Colors.amber,
        DS.Colors.sky
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle, isAnimating: isAnimating)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                withAnimation(.linear(duration: 2.5)) {
                    isAnimating = true
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        particles = (0..<50).map { _ in
            ConfettiParticle(
                color: colors.randomElement() ?? DS.Colors.primary,
                startX: CGFloat.random(in: 0...size.width),
                startY: CGFloat.random(in: -100...(-20)),
                endX: CGFloat.random(in: -50...50),
                endY: size.height + 100,
                rotationStart: Double.random(in: 0...360),
                rotationEnd: Double.random(in: 720...1080),
                scale: CGFloat.random(in: 0.5...1.2),
                delay: Double.random(in: 0...0.5),
                shape: ConfettiShape.allCases.randomElement() ?? .circle
            )
        }
    }
}

// MARK: - Confetti Particle Model

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let rotationStart: Double
    let rotationEnd: Double
    let scale: CGFloat
    let delay: Double
    let shape: ConfettiShape
}

enum ConfettiShape: CaseIterable {
    case circle
    case rectangle
    case triangle
}

// MARK: - Confetti Piece View

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    let isAnimating: Bool

    var body: some View {
        confettiShape
            .rotationEffect(.degrees(isAnimating ? particle.rotationEnd : particle.rotationStart))
            .position(
                x: particle.startX + (isAnimating ? particle.endX : 0),
                y: isAnimating ? particle.endY : particle.startY
            )
            .opacity(isAnimating ? 0 : 1)
            .animation(
                .easeOut(duration: 2.0).delay(particle.delay),
                value: isAnimating
            )
    }

    private var shapeHeight: CGFloat {
        switch particle.shape {
        case .circle: return 8 * particle.scale
        case .rectangle: return 12 * particle.scale
        case .triangle: return 10 * particle.scale
        }
    }

    @ViewBuilder
    private var confettiShape: some View {
        switch particle.shape {
        case .circle:
            Circle()
                .fill(particle.color)
                .frame(width: 8 * particle.scale, height: 8 * particle.scale)
        case .rectangle:
            RoundedRectangle(cornerRadius: 2)
                .fill(particle.color)
                .frame(width: 8 * particle.scale, height: 12 * particle.scale)
        case .triangle:
            Triangle()
                .fill(particle.color)
                .frame(width: 8 * particle.scale, height: 10 * particle.scale)
        }
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Confetti Modifier

struct ConfettiModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var showConfetti = false

    func body(content: Content) -> some View {
        ZStack {
            content

            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .onAppear {
                        HapticManager.shared.notification(.success)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            showConfetti = false
                            isPresented = false
                        }
                    }
            }
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                showConfetti = true
            }
        }
    }
}

extension View {
    func confetti(isPresented: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isPresented: isPresented))
    }
}

#Preview {
    ZStack {
        Color.white
        ConfettiView()
    }
}
