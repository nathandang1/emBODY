import SwiftUI

struct ContentView: View {
    @State private var points: [CGPoint] = []
    @State private var completedPolygons: [Polygon] = []
    @State private var currentPolygonColor: Color = .blue

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("BodyDiagram")
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let location = value.location
                                self.handleTap(location, in: geometry.frame(in: .local))
                            }
                    )
                
                ForEach(completedPolygons) { polygon in
                    PolygonShape(points: polygon.points)
                        .fill(polygon.color.opacity(0.5))
                        .overlay(
                            PolygonShape(points: polygon.points)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                
                PolygonShape(points: points)
                    .stroke(Color.blue, lineWidth: 2)
                
                ForEach(points.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                        .position(points[index])
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ColorPicker("Polygon Color", selection: $currentPolygonColor)
                            .padding()
                        Button("Finish Drawing") {
                            self.completePolygon()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            )
        }
    }
    
    private func handleTap(_ location: CGPoint, in bounds: CGRect) {
        let relativeLocation = CGPoint(x: location.x / bounds.width * UIScreen.main.bounds.width, y: location.y / bounds.height * UIScreen.main.bounds.height)
        
        addPoint(relativeLocation)
    }
    
    private func addPoint(_ location: CGPoint) {
        points.append(location)
    }
    
    private func completePolygon() {
        if points.count > 2 {
            completedPolygons.append(Polygon(points: points, color: currentPolygonColor))
            points = []
        }
    }
    
    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }
}

struct Polygon: Identifiable, Hashable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    
    static func == (lhs: Polygon, rhs: Polygon) -> Bool {
        return lhs.id == rhs.id && lhs.points == rhs.points && lhs.color == rhs.color
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(points.map { $0.x })
        hasher.combine(points.map { $0.y })
        hasher.combine(color)
    }
}

struct PolygonShape: Shape {
    var points: [CGPoint]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard points.count > 1 else {
            return path
        }
        
        path.move(to: points.first!)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        
        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
