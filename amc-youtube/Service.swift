//
//  Service.swift
//  amc-youtube
//
//  Created by thisdjango on 14.02.2020.
//  Copyright © 2020 thisdjango. All rights reserved.
//

import UIKit


class Service {
    
    static let shared = Service()

    let TOKEN = "AIzaSyDvlb82XRQVe0Kyl_olqWyJ1SwddGl_ImQ"
    let CHANNEL_ID = "UCLtPOhNcK2_oSeJl43y-qWw"
    
    var tmp_titles:[String] = []
    var tmp_imgs:[UIImage] = []
    var labels:[String] = []
    var previewImages:[PreviewImagesVideoSet] = []
    var titlesVideo:[TitleVideoSet] = []
    var videos:[Videos] = []
    
    static func grabData(tableView: UITableView){
        let PLAYLIST_URL_LINK = "https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=UCLtPOhNcK2_oSeJl43y-qWw&maxResults=50&key=AIzaSyDvlb82XRQVe0Kyl_olqWyJ1SwddGl_ImQ"
        guard let url = URL(string: PLAYLIST_URL_LINK) else {
            print("unlucky :(")
            return
        }
        let request = URLRequest(url: url)
        print("in loadContent")
        let task0 = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                print(error?.localizedDescription ?? "no description for error provided!\n")
                return
            }

            guard let data = data else { return }
            
            guard let playlist = try? JSONDecoder().decode(Playlist.self, from: data) else {
                print("Error: can't parse gists")
                return
            }
            playlistsData = playlist.items
            print(playlistsData)
            grabTitleAndVideos(tableView: tableView)
        }
        
        task0.resume()
    }
    
    static func grabTitleAndVideos(tableView: UITableView){
        print("Titles: ")
        for playlist in playlistsData {
            shared.labels.append(playlist.snippet.title)
            let VIDEOS_URL_LINK = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=\(playlist.id)&key=AIzaSyDvlb82XRQVe0Kyl_olqWyJ1SwddGl_ImQ"
            guard let url = URL(string: VIDEOS_URL_LINK) else {
                print("getVideos unlucky")
                return
            }
            
            let request = URLRequest(url: url)
            let task1 = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    print(error?.localizedDescription ?? "no description for error provided!\n")
                    return
                }
                
                guard let data = data else { return }
                
                guard let videos1 = try? JSONDecoder().decode(Videos.self, from: data) else {
                    print("Error: can't parse gists")
                    return
                }
                print("without er")
                shared.videos.append(videos1)
                grabMediaContent(tableView: tableView, video_set: videos1)
            }
            
            task1.resume()
        }
    }
    
    static func grabMediaContent(tableView: UITableView, video_set: Videos){
        DispatchQueue.global(qos: .userInitiated).sync {
        var urlString:String
        for one in video_set.items {
            urlString = one.snippet.thumbnails.high.url;
            
            guard let url = URL(string: urlString) else { return }
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "no description for error provided!\n")
                    return
                }
                guard let data = data else { return }
                if let image = UIImage(data: data) {
                    shared.tmp_imgs.append(image)
                    shared.tmp_titles.append(one.snippet.title)
                    print("AAAAAAAAAAASSSSSS")
                    print(shared.tmp_titles)
                    print(shared.tmp_imgs)
                    print(image)
                }
               
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
                
            }
            task.resume()
            }
        shared.previewImages.append(PreviewImagesVideoSet(previewImagesVideos: shared.tmp_imgs))
        shared.titlesVideo.append(TitleVideoSet(titlesVideoset: shared.tmp_titles))
        print("JJJJJJJJJJJJJJJJJ")
        print(shared.tmp_titles)
        print(shared.tmp_imgs)
        shared.tmp_titles = [] as [String]
        shared.tmp_imgs = [] as [UIImage]
        }
        }
    
}
