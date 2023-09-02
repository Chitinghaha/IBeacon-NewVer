//
//  FileReadWriteService.swift
//  TactileMap
//
//  Created by 陳邦亢 on 2023/8/25.
//

import Foundation

class FileReadWriteService {
    static let shared = FileReadWriteService()
    
    func getAlliBeaconInfomation()-> [iBeaconModel] {
        var alliBeaconInfos: [iBeaconModel] = []
        
        do {
            let url = Bundle.main.url(
                forResource: "Resource.bundle/ibeaconInfos",
                withExtension: "json"
            )
            let data = try Data(contentsOf: url!, options: .alwaysMapped)
            
            alliBeaconInfos = try JSONDecoder().decode([iBeaconModel].self, from: data)
            
        } catch {
            print("getAlliBeaconInfomation failed, error :\(error)")
        }
        
        return alliBeaconInfos
    }
    
//    func readFavoritesJson() -> FavoriteMaps? {
//        if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
//                                                            in: .userDomainMask).first {
//            let pathWithFilename = documentDirectory.appendingPathComponent("FavoriteMaps.json")
//
//            do {
//                let savedJSONData = try Data(contentsOf: pathWithFilename)
//                let favoriteMaps = try? JSONDecoder().decode(FavoriteMaps.self, from: savedJSONData)
//
//                return favoriteMaps
//            }
//            catch {
//                _ = self.saveFavoritesJson(favorites: FavoriteMaps(mapNames: []))
//                print("read FavoritesJson failed, error: \(error)")
//            }
//        }
//
//        return nil
//    }
//
//    func saveFavoritesJson(favorites: FavoriteMaps) -> Bool{
//
//        if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
//                                                            in: .userDomainMask).first {
//            let pathWithFilename = documentDirectory.appendingPathComponent("FavoriteMaps.json")
//
//            let jsonEncoder = JSONEncoder()
//
//            jsonEncoder.outputFormatting = .prettyPrinted
//              // 將 JsonData 寫入 JsonURL = Stickers/sticker.json
//            do {
//
//                let jsonData = try jsonEncoder.encode(favorites)
//                try jsonData.write(to: pathWithFilename)
//                return true
//            } catch {
//                print("save FavoritesJson failed, error: \(error)")
//                return false
//            }
//        }
//        else {
//            return false
//        }
//    }
    
}
