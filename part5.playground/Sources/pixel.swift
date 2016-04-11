
import CoreImage
import simd

public struct Pixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    public init(red: UInt8, green: UInt8, blue: UInt8) {
        r = red
        g = green
        b = blue
        a = 255
    }
}

func random_scene() -> Hitable_list {
    var objects = [Hitable]()
    objects.append(Sphere(c: float3(0, -1000, 0), r: 1000, m: Lambertian(albedo: float3(0.5, 0.5, 0.5))))
    for a in -2..<3 {
        for b in -2..<3 {
            let materialChoice = drand48()
            let center = float3(Float(a) + 0.9 * Float(drand48()), 0.2, Float(b) + 0.9 * Float(drand48()))
            if length(center - float3(4, 0.2, 0)) > 0.9 {
                if materialChoice < 0.8 {   // diffuse
                    let albedo = float3(Float(drand48()) * Float(drand48()), Float(drand48()) * Float(drand48()), Float(drand48()) * Float(drand48()))
                    objects.append(Sphere(c: center, r: 0.2, m: Lambertian(albedo: albedo)))
                } else if materialChoice < 0.95 {   // metal
                    let albedo = float3(0.5 * (1 + Float(drand48())), 0.5 * (1 + Float(drand48())), 0.5 * (1 + Float(drand48())))
                    objects.append(Sphere(c: center, r: 0.2, m: Metal(albedo: albedo, fuzz: Float(0.5 * drand48()))))
                } else {    // glass
                    objects.append(Sphere(c: center, r: 0.2, m: Dielectric()))
                }
            }
        }
    }
    objects.append(Sphere(c: float3(0, 0.7, 0), r: 0.7, m: Dielectric()))
    objects.append(Sphere(c: float3(-3, 0.7, 0), r: 0.7, m: Lambertian(albedo: float3(0.4, 0.2, 0.1))))
    objects.append(Sphere(c: float3(3, 0.7, 0), r: 0.7, m: Metal(albedo: float3(0.7, 0.6, 0.5), fuzz: 0.0)))
    return Hitable_list(list: objects)
}

public func imageFromPixels(width: Int, _ height: Int) -> CIImage {
    var pixel = Pixel(red: 0, green: 0, blue: 0)
    var pixels = [Pixel](count: width * height, repeatedValue: pixel)
    let lookFrom = float3(10, 1.5, -3)
    let lookAt = float3()
    let cam = Camera(lookFrom: lookFrom, lookAt: lookAt, vup: float3(0, -1, 0), vfov: 15, aspect: Float(width) / Float(height))
    let world = random_scene()
    for i in 0..<width {
        for j in 0..<height {
            var col = float3()
            let ns = 10
            for _ in 0..<ns {
                let u = (Float(i) + Float(drand48())) / Float(width)
                let v = (Float(j) + Float(drand48())) / Float(height)
                let r = cam.get_ray(u, v)
                col += color(r, world, 0)
            }
            col /= float3(Float(ns))
            col = float3(sqrt(col.x), sqrt(col.y), sqrt(col.z))
            pixel = Pixel(red: UInt8(col.x * 255), green: UInt8(col.y * 255), blue: UInt8(col.z * 255))
            pixels[i + j * width] = pixel
        }
    }
    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
    let providerRef = CGDataProviderCreateWithCFData(NSData(bytes: pixels, length: pixels.count * sizeof(Pixel)))
    let image = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, width * sizeof(Pixel), rgbColorSpace, bitmapInfo, providerRef, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
    return CIImage(CGImage: image!)
}
