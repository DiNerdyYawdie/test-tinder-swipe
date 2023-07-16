//
//  ContentView.swift
//  test tinder swipe
//
//  Created by Chad on 6/30/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cardStackViewModel = CardStackViewModel()

    var body: some View {
        CardStackView()
            .environmentObject(cardStackViewModel)
            .onAppear {
                // Populate your cards here
                cardStackViewModel.cards = (1...20).map { index in
                                   CardViewModel(eventDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                               }
            }
    }
}

struct CardStackView: View {
    @EnvironmentObject var cardStackViewModel: CardStackViewModel

    var body: some View {
        ZStack {
            ForEach(cardStackViewModel.cards.indices, id: \.self) { index in
                CardView(cardViewModel: cardStackViewModel.cards[index], index: index, total: cardStackViewModel.cards.count)
            }
        }
    }
}


class CardViewModel: ObservableObject, Identifiable {
    @Published var id: UUID = UUID()
    @Published var eventDescription: String
    var onRemove: (() -> Void)?

    init(eventDescription: String) {
        self.eventDescription = eventDescription
    }
}

class CardStackViewModel: ObservableObject {
    @Published var cards: [CardViewModel] = []
    
    init() {
        let descriptions = [
            "The Big Apple, NYC, is a bustling hub of culture and activity. From Times Square to Central Park, there's always something to see.",
            "The Sunshine State, Florida, is known for its beautiful beaches and exciting theme parks. Don't forget to visit Miami!",
            "The Lone Star State, Texas, is famous for its barbecue and music festivals. Remember the Alamo in San Antonio!",
            // Add more state descriptions here...
        ]
        
        cards = descriptions.map { CardViewModel(eventDescription: $0) }
    }

    func swipe(card: CardViewModel, direction: SwipeDirection) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards.remove(at: index)
            // Call your API here...
        }
    }
}

enum SwipeDirection {
    case left, right
}

// Drag state tracking
enum DragState {
    case inactive
    case pressing
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
        case .inactive, .pressing:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }

    var isDragging: Bool {
        switch self {
        case .inactive, .pressing:
            return false
        case .dragging:
            return true
        }
    }
}

struct CardView: View {
    @ObservedObject var cardViewModel: CardViewModel
    @GestureState private var dragState = DragState.inactive
    @EnvironmentObject var cardStackViewModel: CardStackViewModel

    private let rotationAngle: Angle = .degrees(10)
    var index: Int
    var total: Int

    @State private var expanded: Bool = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                Image(systemName: "\(index).circle")
                    .resizable()
                    .frame(width: 150, height: 150)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("NYC Event")
                        .font(.title)
                        .bold()
                        .padding(.leading)
                    Spacer()
                }
                
                Text("Population: 8.39 million")
                    .padding(.horizontal)
                Text("Popular Street: Broadway")
                    .padding(.horizontal)

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("NYC Event")
                        .font(.title)
                        .bold()
                        .padding(.leading)
                    Spacer()
                }
                
                Text("Population: 8.39 million")
                    .padding(.horizontal)
                Text("Popular Street: Broadway")
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("NYC Event")
                        .font(.title)
                        .bold()
                        .padding(.leading)
                    Spacer()
                }
                
                
                Text(cardViewModel.eventDescription + cardViewModel.eventDescription + cardViewModel.eventDescription) // Three times the text to make it longer
                    .lineLimit(expanded ? nil : 3)
                    .padding(.horizontal)

                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray, radius: (index == total - 1 && !dragState.isDragging) ? 1 : 1.5)
        .rotationEffect(rotationAngle * Double(dragState.translation.width / UIScreen.main.bounds.width))
        .scaleEffect(dragState.isDragging ? 1.0 : 1.0) // Change the scale to keep the same size when dragging
        .animation(.easeOut(duration: 0.2))
        .offset(x: self.dragState.translation.width, y: self.dragState.translation.height)
        .gesture(
            DragGesture()
                .updating(self.$dragState) { value, state, transaction in
                    state = .dragging(translation: value.translation)
                }
                .onEnded { value in
                    if value.translation.width < -UIScreen.main.bounds.width / 2 {
                        cardStackViewModel.swipe(card: cardViewModel, direction: .left)
                    } else if value.translation.width > UIScreen.main.bounds.width / 2 {
                        cardStackViewModel.swipe(card: cardViewModel, direction: .right)
                    }
                }
        )
        .padding(20) // Extra padding around the card
    }
}
