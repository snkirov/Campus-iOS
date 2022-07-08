//
//  CafeteriaWidgetView.swift
//  Campus-iOS
//
//  Created by Robyn Kölle on 24.06.22.
//

import SwiftUI
import MapKit

struct CafeteriaWidgetView: View {
    
    @StateObject var viewModel: CafeteriaWidgetViewModel = CafeteriaWidgetViewModel(cafeteriaService: CafeteriasService())
    
    let size: WidgetSize
    
    var content: some View {
        Group {
            switch(viewModel.status) {
            case .error:
                TextWidgetView(text: "No nearby cafeteria.")
            case .loading:
                WidgetLoadingView(text: "Searching nearby cafeteria")
            default:
                if let cafeteria = viewModel.cafeteria,
                   let title = cafeteria.title,
                   let coordinate = cafeteria.coordinate {
                    CafeteriaWidgetContent(
                        size: size,
                        cafeteria: title,
                        dishes: viewModel.menuViewModel?.getDishes() ?? [],
                        coordinate: coordinate
                    )
                } else {
                    TextWidgetView(text: "There was an error getting the menu from the nearest cafeteria.")
                }
            }
        }
        .task {
            await viewModel.fetch()
        }
    }
    
    var body: some View {
        WidgetFrameView(size: size,content: content)
    }
}

struct CafeteriaWidgetContent: View {
    
    let size: WidgetSize
    let cafeteria: String
    let dishes: [Dish]
    let coordinate: CLLocationCoordinate2D
    
    var content: some View {
        VStack(alignment: .leading) {
            Label(cafeteria, systemImage: "fork.knife")
                .font(.system(size: size == .square ? 16 : 20).bold())
                .lineLimit(1)
                .padding(.bottom, 4)
            
            Label("Menu", systemImage: "menucard")
                .font(.body.bold())
            CompactMenuView(size: size, dishes: dishes)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    var body: some View {
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude - 0.03
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        Map(coordinateRegion: Binding.constant(region),
            annotationItems: [MapLocation(coordinate: coordinate)]) { item in
                MapMarker(coordinate: item.coordinate)
            }
            .blur(radius: 2)
            .allowsHitTesting(false) // Disallow map interaction.
            .overlay {
                Rectangle()
                    .foregroundColor(.widget.opacity(0.9))
                    .overlay {
                        content
                    }
            }
    }
}

struct CompactMenuView: View {
    
    let size: WidgetSize
    let dishes: [Dish]
    
    private var displayedDishes: Int
    
    init(size: WidgetSize, dishes: [Dish]) {
        
        self.size = size
        self.dishes = dishes
        
        switch (size) {
        case .square, .rectangle:
            displayedDishes = 1
        case .bigSquare:
            displayedDishes = 4
        }
    }
    
    var body: some View {
        
        if !dishes.isEmpty {
            VStack(alignment: .leading) {
                ForEach(dishes.prefix(displayedDishes), id: \.self) { dish in
                    CompactDishView(dish: dish)
                        .padding(.bottom, 2)
                }
                
                Spacer()
                
                let remainingDishes = dishes.count - displayedDishes
                if (remainingDishes > 1) {
                    Text("+ \(remainingDishes) more dishes")
                        .foregroundColor(.green)
                        .bold()
                } else if (remainingDishes == 1) {
                    Text("+ 1 more dish")
                        .foregroundColor(.green)
                        .bold()
                }
            }
        } else {
            Text("No dishes.")
        }
    }
}

struct CompactDishView: View {
    
    var dish: Dish
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dish.name)
                .lineLimit(1)
            Text(DishView.formatPrice(dish: dish, pricingGroup: "students"))
                .font(.caption)
                .bold()
        }
        .frame(alignment: .leading)
    }
}

struct CafeteriaWidgetView_Previews: PreviewProvider {
    
    static var dish = Dish(
        name: "Pasta all'arrabiata",
        prices: ["students" : Price(basePrice: 0.0, unitPrice: 0.66, unit: "100g")],
        labels: ["VEGETARIAN"],
        dishType: "Pasta"
    )
    
    struct cafeteriaWidgetContent: View {
        
        let size: WidgetSize
        
        var body: some View {
            CafeteriaWidgetContent(
                size: size,
                cafeteria: "Mensa Straubing",
                dishes: [Dish](repeating: dish, count: 12),
                coordinate: CLLocationCoordinate2D(latitude: 42, longitude: 42)
            )
        }
    }
    
    static var content: some View {
        VStack {
            HStack {
                WidgetFrameView(
                    size: .square,
                    content: cafeteriaWidgetContent(size: .square)
                )
                
                WidgetFrameView(
                    size: .square,
                    content: cafeteriaWidgetContent(size: .square)
                )
            }
            
            WidgetFrameView(
                size: .rectangle,
                content: cafeteriaWidgetContent(size: .rectangle)
            )
            
            WidgetFrameView(
                size: .bigSquare,
                content: cafeteriaWidgetContent(size: .bigSquare)
            )
        }
    }
    
    static var previews: some View {
        content
        content.preferredColorScheme(.dark)
    }
}
