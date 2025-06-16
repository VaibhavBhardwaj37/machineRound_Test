//
//  DetailScreenSportVC.swift
//  MachineRound_Swift
//
//  Created by Sanskar IOS Dev on 16/06/25.
//

import UIKit
import SDWebImage

class DetailScreenSportVC: UIViewController {

    @IBOutlet weak var imgSportimage: UIImageView!
    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var lblVenue: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDbName: UILabel!
    

    var sport: SportsAPI?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let sport = sport {
            titlelbl.text = sport.sport_name
            lblVenue.text = "🏟 Venue: \(sport.venue_name ?? "")"
            lblLocation.text = "📍 Cluster: \(sport.cluster_name ?? "")"
            lblDate.text = "🗓 Date: \(sport.start_date ?? "") - \(sport.end_date ?? "")"
            lblStatus.text = "✅ Status: \(sport.status ?? "")"
            lblDbName.text = "🎯 DB Name: \(sport.rf_sport_db_name ?? "")"
            
            if let urlString = sport.mascot_image_url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: urlString) {
                print("Image URL: \(urlString)")
                imgSportimage.sd_setImage(with: url, placeholderImage: UIImage(named: "photo")) { image, error, cacheType, url in
                    if let error = error {
                        print("SDWebImage error: \(error.localizedDescription)")
                    }
                }
            } else {
                imgSportimage.image = UIImage(named: "photo")
            }
        }
    }

    // MARK: - Navigation

    @IBAction func btnback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
