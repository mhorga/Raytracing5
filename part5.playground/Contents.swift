
import Foundation

let width = 400
let height = 200
let t0 = CFAbsoluteTimeGetCurrent()
let image = imageFromPixels(width, height)
let t1 = CFAbsoluteTimeGetCurrent()
t1-t0
image
