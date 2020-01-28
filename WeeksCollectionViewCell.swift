

import UIKit

class WeeksCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var labelWeekName: UILabel!
    @IBOutlet weak var viewWeekSelection: UIView!
    
    override func awakeFromNib() {
      viewWeekSelection.layer.cornerRadius = 10
    }
}
