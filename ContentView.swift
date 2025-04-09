//
//  ContentView.swift
//  restaurant tinder
//
//  Created by Jonathan Nguyen on 4/6/25.
//

import SwiftUI
import SwiftData
import AVFoundation

// MARK: - Custom Theme

struct AppTheme {
    // Primary colors
    static let primary = Color(red: 0.91, green: 0.33, blue: 0.13)      // Orange-red
    static let secondary = Color(red: 0.95, green: 0.51, blue: 0.18)    // Orange
    static let accent = Color(red: 0.07, green: 0.47, blue: 0.43)       // Teal
    
    // Background colors
    static let background = Color(red: 0.98, green: 0.97, blue: 0.96)   // Off-white
    static let cardBackground = Color.white
    
    // Text colors
    static let titleText = Color(red: 0.13, green: 0.15, blue: 0.20)    // Dark slate
    static let bodyText = Color(red: 0.27, green: 0.29, blue: 0.33)     // Medium slate
    static let lightText = Color(red: 0.57, green: 0.59, blue: 0.61)    // Light slate
    
    // Gradients
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [primary, secondary]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Button styles
    static func primaryButton(_ content: some View) -> some View {
        content
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(primaryGradient)
            .cornerRadius(15)
            .shadow(color: primary.opacity(0.3), radius: 5, x: 0, y: 3)
    }
    
    static func secondaryButton(_ content: some View) -> some View {
        content
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(primary.opacity(0.1))
            .cornerRadius(15)
    }
    
    static func cardStyle(_ content: some View) -> some View {
        content
            .background(cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
    }
}

// MARK: - Data Models

struct Group: Identifiable {
    let id = UUID()
    let name: String
    var members: [String] // User IDs or names
    var locationRadius: Double // in miles/km
    var dietaryFilters: [String]
    var vibeFilters: [String]
}

struct Restaurant: Identifiable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let cuisineType: [String]
    let priceRange: Int // 1-4 for $-$$$$
    let rating: Double // 0-5
    var dishes: [Dish]
    
    // Calculate distance to user (to be implemented)
    func distanceToUser(userLat: Double, userLong: Double) -> Double {
        // Placeholder for distance calculation
        return 0.0
    }
}

struct Dish: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let imageName: String // For now using system images, later real photos
    let restaurantId: UUID // Reference to the restaurant
    var dietaryTags: [String] // Vegan, GF, etc.
    
    // Dish vote tracking
    var votes: Int = 0
}

// MARK: - Sample Data

// Sample dishes
let sampleDishes = [
    Dish(name: "Pho", description: "Vietnamese beef noodle soup with herbs", price: 14.99, imageName: "bowl.fill", restaurantId: UUID(), dietaryTags: ["Gluten-Free Option"]),
    Dish(name: "Veggie Burger", description: "Plant-based patty with lettuce, tomato, and special sauce", price: 12.99, imageName: "leaf.fill", restaurantId: UUID(), dietaryTags: ["Vegetarian", "Vegan Option"]),
    Dish(name: "Sushi Roll", description: "Fresh salmon, avocado, and cucumber roll", price: 16.99, imageName: "fish.fill", restaurantId: UUID(), dietaryTags: ["Gluten-Free Option"]),
    Dish(name: "Pepperoni Pizza", description: "Classic pepperoni pizza with mozzarella", price: 18.99, imageName: "flame.fill", restaurantId: UUID(), dietaryTags: []),
    Dish(name: "Pad Thai", description: "Thai stir-fried noodles with tofu, egg, and peanuts", price: 13.99, imageName: "house.fill", restaurantId: UUID(), dietaryTags: ["Gluten-Free Option", "Vegetarian Option"])
]

// Sample user groups
let sampleGroup = Group(
    name: "Friday Night Dinner",
    members: ["You", "Alex", "Taylor", "Jordan"],
    locationRadius: 5.0,
    dietaryFilters: ["Vegetarian Option"],
    vibeFilters: ["Casual"]
)

// MARK: - Card View

struct DishCardView: View {
    let dish: Dish
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: dish.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding(.top)
                .foregroundColor(AppTheme.accent)
                .clipped()

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dish.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.titleText)
                    
                    if showDetails {
                        Text(dish.description)
                            .font(.body)
                            .foregroundColor(AppTheme.bodyText)
                            .padding(.top, 2)
                        
                        Text("$\(String(format: "%.2f", dish.price))")
                            .font(.headline)
                            .foregroundColor(AppTheme.primary)
                            .padding(.top, 2)
                        
                        HStack {
                            ForEach(dish.dietaryTags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.accent.opacity(0.2))
                                    .foregroundColor(AppTheme.accent)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                Spacer()
                
                if !showDetails {
                    Image(systemName: "info.circle")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.accent)
                }
            }
            .padding()
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(20)
        .shadow(radius: 8)
        .padding(.horizontal)
        .onTapGesture {
            withAnimation {
                showDetails.toggle()
            }
        }
    }
}

// MARK: - Main Content View

struct ContentView: View {
    // App state
    enum AppScreen {
        case welcome
        case joinGroup
        case filters
        case swipeDishes
        case results
    }
    
    @State private var currentScreen: AppScreen = .welcome
    @State private var currentGroup = sampleGroup
    @State private var dishes = sampleDishes
    @State private var selectedDishes: [Dish] = []
    
    // Swiping state
    @State private var offset = CGSize.zero
    @State private var cardRemovalTransition: AnyTransition = .trailingBottom
    
    @State private var isShowingScanner = false
    @State private var scannedCode = ""
    @State private var showingQRResult = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Custom navigation header
                HStack {
                    if currentScreen != .welcome {
                        Button(action: goBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22))
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(.leading)
                    }
                    
                    Spacer()
                    
                    Text(headerTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.titleText)
                    
                    Spacer()
                }
                .padding(.vertical)
                
                // Main content based on current screen
                switch currentScreen {
                case .welcome:
                    welcomeScreen
                case .joinGroup:
                    joinGroupScreen
                case .filters:
                    filtersScreen
                case .swipeDishes:
                    swipeDishesScreen
                case .results:
                    resultsScreen
                }
                
                QRScannerButton(isShowingScanner: $isShowingScanner, scannedCode: $scannedCode)
                    .padding()
            }
        }
        .background(AppTheme.background)
        .onChange(of: scannedCode) { newValue in
            if !newValue.isEmpty {
                processQRCode(newValue)
            }
        }
        .alert("Scanned Code", isPresented: $showingQRResult) {
            Button("OK") {
                scannedCode = ""
            }
        } message: {
            Text(scannedCode)
        }
    }
    
    // MARK: - Screen Views
    
    var welcomeScreen: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryGradient)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "fork.knife")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                
                Text("Dish Decider")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(AppTheme.titleText)
                
                Text("Never argue about where to eat again!")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.lightText)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: { currentScreen = .joinGroup }) {
                    Text("Start Group Session")
                        .fontWeight(.bold)
                }
                .buttonStyle(.plain)
                .apply(AppTheme.primaryButton)
                
                Button(action: {
                    // Solo mode would skip to filters
                    currentGroup.members = ["You"]
                    currentScreen = .filters
                }) {
                    Text("Solo Mode")
                        .fontWeight(.medium)
                }
                .buttonStyle(.plain)
                .apply(AppTheme.secondaryButton)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
    
    var joinGroupScreen: some View {
        VStack {
            Spacer()
            
            Text("Your Group")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.titleText)
                .padding(.bottom)
            
            // Group members list
            VStack(alignment: .leading, spacing: 15) {
                ForEach(currentGroup.members, id: \.self) { member in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(AppTheme.accent)
                        
                        Text(member)
                            .font(.headline)
                            .foregroundColor(AppTheme.bodyText)
                        
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Invite options
            HStack(spacing: 40) {
                Button(action: {
                    // Share link functionality would go here
                }) {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(AppTheme.secondary.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "link.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(AppTheme.secondary)
                        }
                        
                        Text("Share Link")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                            .padding(.top, 8)
                    }
                }
                
                Button(action: {
                    // QR code functionality would go here
                }) {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accent.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "qrcode")
                                .font(.system(size: 36))
                                .foregroundColor(AppTheme.accent)
                        }
                        
                        Text("QR Code")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                            .padding(.top, 8)
                    }
                }
            }
            .padding(.vertical)
            
            Button(action: { currentScreen = .filters }) {
                Text("Continue")
                    .fontWeight(.bold)
            }
            .buttonStyle(.plain)
            .apply(AppTheme.primaryButton)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
    
    var filtersScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                Text("Where would you like to eat?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.titleText)
                    .padding(.horizontal)
                
                // Location radius
                VStack(alignment: .leading, spacing: 10) {
                    Text("Distance")
                        .font(.headline)
                        .foregroundColor(AppTheme.titleText)
                        .padding(.horizontal)
                    
                    Slider(value: $currentGroup.locationRadius, in: 1...25, step: 1) {
                        Text("Location Radius")
                    }
                    .accentColor(AppTheme.primary)
                    .padding(.horizontal)
                    
                    Text("Within \(Int(currentGroup.locationRadius)) miles")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.lightText)
                        .padding(.horizontal)
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Dietary preferences
                VStack(alignment: .leading, spacing: 10) {
                    Text("Dietary Preferences")
                        .font(.headline)
                        .foregroundColor(AppTheme.titleText)
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    let dietaryOptions = ["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free", "Nut-Free"]
                    
                    ForEach(dietaryOptions, id: \.self) { option in
                        HStack {
                            Image(systemName: currentGroup.dietaryFilters.contains(option) ? "checkmark.square.fill" : "square")
                                .foregroundColor(currentGroup.dietaryFilters.contains(option) ? AppTheme.primary : AppTheme.lightText)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    if currentGroup.dietaryFilters.contains(option) {
                                        currentGroup.dietaryFilters.removeAll { $0 == option }
                                    } else {
                                        currentGroup.dietaryFilters.append(option)
                                    }
                                }
                            
                            Text(option)
                                .foregroundColor(AppTheme.bodyText)
                                .padding(.leading, 5)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
                .padding(.vertical)
                .background(AppTheme.cardBackground)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Vibe/Ambiance
                VStack(alignment: .leading, spacing: 10) {
                    Text("Vibe")
                        .font(.headline)
                        .foregroundColor(AppTheme.titleText)
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    let vibeOptions = ["Casual", "Upscale", "Fast", "Family-Friendly", "Date Night"]
                    
                    ForEach(vibeOptions, id: \.self) { option in
                        HStack {
                            Image(systemName: currentGroup.vibeFilters.contains(option) ? "checkmark.square.fill" : "square")
                                .foregroundColor(currentGroup.vibeFilters.contains(option) ? AppTheme.accent : AppTheme.lightText)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    if currentGroup.vibeFilters.contains(option) {
                                        currentGroup.vibeFilters.removeAll { $0 == option }
                                    } else {
                                        currentGroup.vibeFilters.append(option)
                                    }
                                }
                            
                            Text(option)
                                .foregroundColor(AppTheme.bodyText)
                                .padding(.leading, 5)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
                .padding(.vertical)
                .background(AppTheme.cardBackground)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        
        return Button(action: { currentScreen = .swipeDishes }) {
            Text("Start Swiping")
                .fontWeight(.bold)
        }
        .buttonStyle(.plain)
        .apply(AppTheme.primaryButton)
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
    }
    
    var swipeDishesScreen: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack {
                ZStack {
                    // Show placeholder if no dishes left
                    if dishes.isEmpty {
                        VStack(spacing: 25) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 70))
                                .foregroundColor(AppTheme.accent)
                            
                            Text("You've swiped through all dishes!")
                                .font(.headline)
                                .foregroundColor(AppTheme.titleText)
                                .padding()
                            
                            Button(action: { currentScreen = .results }) {
                                Text("See Results")
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.plain)
                            .apply(AppTheme.primaryButton)
                            .padding(.horizontal, 30)
                        }
                    }
                    
                    ForEach(dishes) { dish in
                        // Only show the card if it's the top one
                        if isTopCard(dish: dish) {
                            DishCardView(dish: dish)
                                .zIndex(isTopCard(dish: dish) ? 1 : 0) // Ensure top card is tappable
                                .offset(x: offset.width, y: offset.height * 0.4) // Apply offset
                                .rotationEffect(.degrees(Double(offset.width / 40))) // Apply rotation
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            offset = gesture.translation
                                        }
                                        .onEnded { _ in
                                            let swipeThreshold: CGFloat = 120 // How far to swipe
                                            if abs(offset.width) > swipeThreshold {
                                                // Determine removal transition based on direction
                                                cardRemovalTransition = offset.width > 0 ? .trailingBottom : .leadingBottom
                                                
                                                // Add to selected dishes if swiped right
                                                if offset.width > 0, let topDish = dishes.last {
                                                    selectedDishes.append(topDish)
                                                }
                                                
                                                // Remove card with animation
                                                withAnimation(.easeOut(duration: 0.3)) {
                                                    removeTopCard()
                                                }
                                            } else {
                                                // Return card to center if swipe wasn't enough
                                                withAnimation(.spring()) {
                                                    offset = .zero
                                                }
                                            }
                                        }
                                )
                                .transition(cardRemovalTransition) // Apply removal animation
                        }
                    }
                }
                
                // Action buttons
                HStack(spacing: 70) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            cardRemovalTransition = .leadingBottom
                            removeTopCard()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.1))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: {
                        if let topDish = dishes.last {
                            selectedDishes.append(topDish)
                        }
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            cardRemovalTransition = .trailingBottom
                            removeTopCard()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primary.opacity(0.1))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 30))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                }
                .padding(.top, 30)
                .padding(.bottom, 50)
            }
        }
    }
    
    var resultsScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if selectedDishes.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 70))
                            .foregroundColor(AppTheme.lightText)
                        
                        Text("No matches found")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Try again with different preferences?")
                            .foregroundColor(AppTheme.lightText)
                        
                        Button(action: {
                            // Reset and go back to filters
                            dishes = sampleDishes
                            selectedDishes = []
                            currentScreen = .filters
                        }) {
                            Text("Try Again")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.plain)
                        .apply(AppTheme.primaryButton)
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Top Matches")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.titleText)
                            
                            Text("Based on your group's preferences")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.lightText)
                        }
                        
                        Spacer()
                        
                        // Cute little chef hat or food icon
                        Image(systemName: "rosette")
                            .font(.system(size: 30))
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.horizontal)
                    
                    // Top dish results (showing max 3 for now)
                    ForEach(selectedDishes.prefix(3)) { dish in
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                ZStack {
                                    Rectangle()
                                        .fill(AppTheme.secondary.opacity(0.1))
                                        .frame(width: 90, height: 90)
                                        .cornerRadius(12)
                                    
                                    Image(systemName: dish.imageName)
                                        .font(.system(size: 40))
                                        .foregroundColor(AppTheme.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(dish.name)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.titleText)
                                    
                                    Text(dish.description)
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.bodyText)
                                        .lineLimit(2)
                                    
                                    Text("$\(String(format: "%.2f", dish.price))")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.primary)
                                    
                                    // Show a placeholder restaurant name with a cute icon
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundColor(AppTheme.accent)
                                        
                                        Text("Example Restaurant (1.2 miles away)")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.accent)
                                    }
                                }
                                .padding(.leading, 5)
                            }
                            
                            Button(action: {
                                // Would navigate to restaurant details or Maps
                            }) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 14))
                                    Text("Get Directions")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .background(AppTheme.accent)
                                .cornerRadius(10)
                            }
                            .padding(.top, 10)
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    }
                    
                    // Start over button
                    Button(action: {
                        // Reset everything and go back to welcome
                        dishes = sampleDishes
                        selectedDishes = []
                        currentScreen = .welcome
                    }) {
                        Text("Start Over")
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.plain)
                    .apply(AppTheme.secondaryButton)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    // Navigation title based on current screen
    var headerTitle: String {
        switch currentScreen {
        case .welcome:
            return ""
        case .joinGroup:
            return "Create Group"
        case .filters:
            return "Preferences"
        case .swipeDishes:
            return "Swipe Dishes"
        case .results:
            return "Results"
        }
    }
    
    // Go back to previous screen
    func goBack() {
        switch currentScreen {
        case .joinGroup:
            currentScreen = .welcome
        case .filters:
            currentScreen = .joinGroup
        case .swipeDishes:
            currentScreen = .filters
        case .results:
            currentScreen = .swipeDishes
        default:
            break
        }
    }
    
    // Check if a dish is the top one in the stack
    private func isTopCard(dish: Dish) -> Bool {
        guard let index = dishes.firstIndex(where: { $0.id == dish.id }) else {
            return false
        }
        return index == dishes.count - 1 // In ForEach, last element is rendered on top
    }
    
    // Remove the top card
    private func removeTopCard() {
        offset = .zero // Reset offset for the next card
        if !dishes.isEmpty {
            // Remove the last element because ForEach renders them bottom-up
            dishes.removeLast()
            
            // Auto-navigate to results if all dishes have been swiped
            if dishes.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    currentScreen = .results
                }
            }
        }
    }
    
    func processQRCode(_ code: String) {
        // Check if the QR code is a URL
        if let url = URL(string: code), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return
        }
        
        // Check if it's a restaurant ID or special format
        if code.hasPrefix("restaurant:") {
            let id = code.replacingOccurrences(of: "restaurant:", with: "")
            // Handle restaurant ID
            return
        }
        
        // Default handling
        showingQRResult = true
    }
}

// Custom transitions for swipe removal
extension AnyTransition {
    static var trailingBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: AnyTransition.move(edge: .trailing).combined(with: .move(edge: .bottom))
        )
    }

    static var leadingBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: AnyTransition.move(edge: .leading).combined(with: .move(edge: .bottom))
        )
    }
}

// Extension to apply custom ViewModifiers easily
extension View {
    func apply<T: View>(_ transform: (Self) -> T) -> T {
        transform(self)
    }
}

#Preview {
    ContentView()
}

struct QRScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        var parent: QRScannerView
        
        init(_ parent: QRScannerView) {
            self.parent = parent
        }
        
        func qrScanningSucceeded(code: String) {
            parent.scannedCode = code
            parent.isScanning = false
        }
        
        func qrScanningFailed() {
            parent.isScanning = false
        }
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func qrScanningSucceeded(code: String)
    func qrScanningFailed()
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: QRScannerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Add scanning area overlay
        let scanningArea = UIView()
        scanningArea.layer.borderColor = UIColor.white.cgColor
        scanningArea.layer.borderWidth = 2
        scanningArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanningArea)
        
        NSLayoutConstraint.activate([
            scanningArea.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanningArea.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanningArea.widthAnchor.constraint(equalToConstant: 250),
            scanningArea.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func failed() {
        delegate?.qrScanningFailed()
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.qrScanningSucceeded(code: stringValue)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct QRScannerButton: View {
    @Binding var isShowingScanner: Bool
    @Binding var scannedCode: String
    
    var body: some View {
        Button(action: {
            isShowingScanner = true
        }) {
            HStack {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 20))
                Text("Scan QR Code")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .sheet(isPresented: $isShowingScanner) {
            QRScannerSheet(scannedCode: $scannedCode, isScanning: $isShowingScanner)
        }
    }
}

struct QRScannerSheet: View {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                QRScannerView(scannedCode: $scannedCode, isScanning: $isScanning)
                
                VStack {
                    Spacer()
                    Text("Position the QR code within the frame")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
