import SwiftUI
struct ContentView: View {
    @State private var points: [CGPoint] = []
    @State private var completedPolygons: [Polygon] = []
    @State private var currentPolygonColor: Color = .blue
    @State private var statistics: String = ""
    @State private var lastTapLocation: CGPoint = .zero
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BodyDiagram")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let location = value.location
                                self.addPoint(location)
                            }
                    )
                // Completed polygons
                ForEach(completedPolygons) { polygon in
                    PolygonShape(points: polygon.points)
                        .fill(polygon.color.opacity(0.5))
                        .overlay(
                            PolygonShape(points: polygon.points)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                // Current polygon being drawn
                PolygonShape(points: points)
                    .stroke(Color.blue, lineWidth: 2)
                // Red points indicating vertices of the polygon
                ForEach(points.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                        .position(points[index])
                }
                // Display statistics (percentage of body parts covered)
                VStack {
                    Text(statistics)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.top, 20)
                    Spacer()
                }
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
                // Display last tap location
                VStack {
                    Spacer()
                    Text("Last Tap: (\(Int(lastTapLocation.x)), \(Int(lastTapLocation.y)))")
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                }
            }
        }
    }
    private func addPoint(_ location: CGPoint) {
        points.append(location)
        lastTapLocation = location
    }
    private func completePolygon() {
        if points.count > 2 {
            completedPolygons.append(Polygon(points: points, color: currentPolygonColor))
            calculateStatistics()
            points = []
        }
    }
    private func calculateStatistics() {
        let imageWidth: CGFloat = 502
        let imageHeight: CGFloat = 952
        // Define body parts using bounding boxes (approximations)
               let headBounds = CGRect(x: 359, y: 2, width: 115, height: 150)
               let chestBounds = CGRect(x: 328, y: 180, width: 160, height: 150)
               let abdomenBounds = CGRect(x: 328, y: 330, width: 160, height: 250)
               let leftArmBounds = CGRect(x: 0, y: 0, width: 0, height: 0)
               let rightArmBounds = CGRect(x: 0, y: 0, width: 0, height: 0)
               let leftLegBounds = CGRect(x: 270, y: 580 , width: 145, height: 650)
               let rightLegBounds = CGRect(x: 415, y: 580, width: 145, height: 650)
        let bodyParts = [
            ("Head", headBounds),
            ("Chest", chestBounds),
            ("Abdomen", abdomenBounds),
            ("Left Arm", leftArmBounds),
            ("Right Arm", rightArmBounds),
            ("Left Leg", leftLegBounds),
            ("Right Leg", rightLegBounds)
        ]
        var stats: [String: CGFloat] = [
            "Head": 0, "Chest": 0, "Abdomen": 0,
            "Left Arm": 0, "Right Arm": 0,
            "Left Leg": 0, "Right Leg": 0
        ]
        // Check the number of points inside each body part
        for (part, bounds) in bodyParts {
            let pointsInside = points.filter { bounds.contains($0) }
            let coverage = CGFloat(pointsInside.count) / CGFloat(points.count) * 100
            stats[part] = coverage
        }
        // Prepare the statistics string
        statistics = stats.map { "\($0.value)% \($0.key)" }.joined(separator: ", ")
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

