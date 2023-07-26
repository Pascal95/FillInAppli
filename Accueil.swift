//
//  Accueil.swift
//  FillIn
//
//  Created by Pierre-Richard Pascal on 21/04/2023.
//

import SwiftUI

struct Accueil: View {
    @State public var items: [Item] = []
    var body: some View {
        List(items, id: \.id_secteur) { item in
            NavigationLink(destination:Metier(item: item)){
                RowSecteur(item: item)
            }
           
        }.onAppear {
            loadData()
        }

            .navigationBarBackButtonHidden(true)
    }
    func loadData() {
        guard let url = URL(string: "http://localhost:3000/secteurs") else {
            print("URL invalide")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Erreur de chargement des données : \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Aucune donnée reçue")
                return
            }
            
            do {
                let items = try JSONDecoder().decode([Item].self, from: data)
                DispatchQueue.main.async {
                    self.items = items
                }
            } catch {
                print("Erreur de décodage des données : \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct Accueil_Previews: PreviewProvider {
    static var previews: some View {
        Accueil()
    }
}

struct Item: Codable {
    let id_secteur: Int
    let nom: String
    let description: String
    let secteurpano: String
}

struct RowSecteur: View {
    let item: Item
    var body: some View {
        VStack {
            Text(item.nom)
                .font(.headline)
            Text(item.description)
                .font(.subheadline)
            
            if let imageURL = URL(string: item.secteurpano) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure(let error):
                        Text("Failed to load image: \(error.localizedDescription)")
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Text("Image not available")
            }
        }
    }
}
