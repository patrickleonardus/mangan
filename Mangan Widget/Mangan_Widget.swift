//
//  Mangan_Widget.swift
//  Mangan Widget
//
//  Created by bcamaster on 01/02/21.
//

import WidgetKit
import SwiftUI
import Intents

class NetworkManager {
    func getRecipes(completion: @escaping (SimpleEntry.Recipes.Results?) -> Void){
        guard let url = URL(string: "\(Url.baseUrl)\(Url.randomRecipes)")  else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            var recipes: SimpleEntry.Recipes?
            var recipe: SimpleEntry.Recipes.Results?
            if let data = data {
                do{
                    recipes = try JSONDecoder().decode(SimpleEntry.Recipes.self, from: data)
                    recipe = recipes?.results?[Int.random(in: 0...(recipes?.results?.count ?? 0) - 1)]
                } catch let err {
                    print(err.localizedDescription)
                }
            }
            
            completion(recipe)
        }.resume()
    }
}

struct Provider: IntentTimelineProvider {
    
    let networkManager = NetworkManager()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), recipe: .previewData)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        networkManager.getRecipes { (recipe) in
            let entry = SimpleEntry(date: Date(), recipe: recipe ?? .previewData)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        networkManager.getRecipes { (recipes) in
            let entries = [SimpleEntry(date: Date(), recipe: recipes ?? .previewData)]
            
            let timeline = Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .second, value: 1, to: Date()) ?? Date()))
            
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let recipe: Recipes.Results
    
    struct Recipes: Decodable {
        let method: String?
        let status: Bool?
        let results: [Results]?
        
        struct Results: Decodable {
            let title: String?
            let thumb: String?
            let key: String?
            let times: String?
            let portion: String?
            let dificulty: String?
            
            static let previewData = Recipes.Results(title: "No Data", thumb: "No Data", key: "No Data", times: "No Data", portion: "No Data", dificulty: "No Data")
        }
    }
}

struct Mangan_WidgetEntryView : View {
    
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    var entry: Provider.Entry
    
    var body: some View {
        
        switch family {
        case .systemLarge:
            ZStack {
                Color.init(colorScheme == .dark ? UIColor.systemGray6 : UIColor.white).ignoresSafeArea()
                VStack(alignment: .center, spacing: 12){
                    NetworkImage(url: URL(string: entry.recipe.thumb ?? ""))
                        .frame(width: 210, height: 170, alignment: .center)
                    HStack(spacing: 15){
                        HStack{
                            Image("ic_difficulty")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20, alignment: .center)
                            Text("\(entry.recipe.dificulty ?? "No Data")")
                                .font(.system(size: 10, weight: .regular, design: .default))
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                        HStack{
                            Image("ic_time")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20, alignment: .center)
                            Text("\(entry.recipe.times ?? "No Data")")
                                .font(.system(size: 10, weight: .regular, design: .default))
                                .multilineTextAlignment(.leading)
                        }
                        HStack{
                            Image("ic_portion")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20, alignment: .center)
                            Text("\(entry.recipe.portion ?? "No Data")")
                                .font(.system(size: 10, weight: .regular, design: .default))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Text("\(entry.recipe.title ?? "No Data")")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .lineLimit(4)
                }.padding(20)
            }.widgetURL(URL(string: "(-)\(entry.recipe.key ?? "")(-)\(entry.recipe.thumb ?? "")"))
        case .systemMedium:
            ZStack{
                Color.init(colorScheme == .dark ? UIColor.systemGray6 : UIColor.white).ignoresSafeArea()
                VStack(spacing: 8){
                    NetworkImage(url: URL(string: entry.recipe.thumb ?? ""))
                        .frame(width: 70, height: 70, alignment: .center)
                    HStack(spacing: 15){
                        HStack{
                            Image("ic_difficulty")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20, alignment: .center)
                            Text("\(entry.recipe.dificulty ?? "No Data")")
                                .font(.system(size: 10, weight: .regular, design: .default))
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                        HStack{
                            Image("ic_time")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20, alignment: .center)
                            Text("\(entry.recipe.times ?? "No Data")")
                                .font(.system(size: 10, weight: .regular, design: .default))
                                .multilineTextAlignment(.leading)
                        }
                        HStack{
                            Image("ic_portion")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20, alignment: .center)
                            Text("\(entry.recipe.portion ?? "No Data")")
                                .font(.system(size: 10, weight: .regular, design: .default))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Text("\(entry.recipe.title ?? "No Data")")
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .lineLimit(2)
                }.padding([.leading, .trailing], 10)
            }.widgetURL(URL(string: "(-)\(entry.recipe.key ?? "")(-)\(entry.recipe.thumb ?? "")"))
            
        case .systemSmall:
            ZStack{
                Color.init(colorScheme == .dark ? UIColor.systemGray6 : UIColor.white).ignoresSafeArea()
                VStack(spacing: 5){
                    VStack{
                        NetworkImage(url: URL(string: entry.recipe.thumb ?? ""))
                            .frame(width: 70, height: 70, alignment: .center)
                        
                        
                        Text("\(entry.recipe.title ?? "No Data")")
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                }.padding([.leading, .trailing], 10)
            }.widgetURL(URL(string: "(-)\(entry.recipe.key ?? "")(-)\(entry.recipe.thumb ?? "")"))
        @unknown default:
            fatalError()
        }
    }
    
    struct NetworkImage: View {
        let url: URL?
        var body: some View {
            Group {
                if let url = url, let imageData = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: imageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                else {
                    Image("image_placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }.cornerRadius(10)
        }
    }
    
    @main
    struct Mangan_Widget: Widget {
        let kind: String = "Mangan_Widget"
        
        var body: some WidgetConfiguration {
            IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
                Mangan_WidgetEntryView(entry: entry)
            }
            .configurationDisplayName("Resep Hari Ini")
            .description("Temukan inspirasi resep memasak hari ini dengan mudah dan cepat")
        }
    }
    
    struct Mangan_Widget_Previews: PreviewProvider {
        static var previews: some View {
            Group{
                Mangan_WidgetEntryView(entry: SimpleEntry(date: Date(), recipe: .previewData))
                    .previewContext(WidgetPreviewContext(family: .systemSmall))
                Mangan_WidgetEntryView(entry: SimpleEntry(date: Date(), recipe: .previewData))
                    .previewContext(WidgetPreviewContext(family: .systemMedium))
                Mangan_WidgetEntryView(entry: SimpleEntry(date: Date(), recipe: .previewData))
                    .previewContext(WidgetPreviewContext(family: .systemLarge))
            }
        }
    }
    
}
