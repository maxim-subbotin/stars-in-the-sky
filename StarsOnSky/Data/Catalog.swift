//
//  Catalog.swift
//  StarsOnSky
//
//  Created by Max Subbotin on 1/7/20.
//

import Foundation
import SQLite3

enum CatalogStatus {
    case OK
    case failed
}

class Catalog {
    public var stars = [Star]()
    private var dbName = "hyg"
    private var db: OpaquePointer?
    private var status = CatalogStatus.failed
    
    func connect() -> OpaquePointer? {
        let dbPath = Bundle.main.path(forResource: dbName, ofType: "sqlite")
        var db: OpaquePointer?
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("HYG db: connection was established")
            return db
        }
        print("HYG db: connection was failed")
        return nil
    }
    
    init() {
        db = connect()
        self.status = db == nil ? .OK : .failed
    }
    
    func getStars(brighterThan b: Double) -> [Star] {
        let query = "SELECT * FROM stars WHERE mag < \(b) AND id > 1 ORDER BY mag ASC"
        return execute(query: query)
    }
    
    func getStars(brighterThan b: Double, inHemispere hem: SkyHemishpere) -> [Star] {
        let query = hem == .north ? "SELECT * FROM stars WHERE mag < \(b) AND dec >= \(0) AND id > 1 ORDER BY mag ASC"
                                  : "SELECT * FROM stars WHERE mag < \(b) AND dec <= \(0) AND id > 1 ORDER BY mag ASC"
        return execute(query: query)
    }
    
    func execute(query: String) -> [Star] {
        var queryStatement: OpaquePointer?
        var stars = [Star]()
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let star = getStar(fromStatement: queryStatement!)
                stars.append(star)
            }
        } else {
            print("HYG db: query execution was failed")
        }
        
        return stars
    }
    
    func getStar(fromStatement stat: OpaquePointer) -> Star {
        let star = Star()
        star.id = Int(sqlite3_column_int(stat, 0))
        star.hip = Int(sqlite3_column_int(stat, 1))
        star.hd = Int(sqlite3_column_int(stat, 2))
        star.hr = Int(sqlite3_column_int(stat, 3))
        star.gl = String(cString: sqlite3_column_text(stat, 4))
        star.bf = String(cString: sqlite3_column_text(stat, 5))
        star.proper = String(cString: sqlite3_column_text(stat, 6))
        star.ra = sqlite3_column_double(stat, 7)
        star.dec = sqlite3_column_double(stat, 8)
        star.dist = sqlite3_column_double(stat, 9)
        star.pmra = sqlite3_column_double(stat, 10)
        star.pmdec = sqlite3_column_double(stat, 11)
        star.rv = sqlite3_column_double(stat, 12)
        star.mag = sqlite3_column_double(stat, 13)
        star.absmag = sqlite3_column_double(stat, 14)
        star.spect = String(cString: sqlite3_column_text(stat, 15))
        star.ci = sqlite3_column_double(stat, 16)
        star.x = sqlite3_column_double(stat, 17)
        star.y = sqlite3_column_double(stat, 18)
        star.z = sqlite3_column_double(stat, 19)
        star.vx = sqlite3_column_double(stat, 20)
        star.vy = sqlite3_column_double(stat, 21)
        star.vz = sqlite3_column_double(stat, 22)
        star.rarad = sqlite3_column_double(stat, 23)
        star.decrad = sqlite3_column_double(stat, 24)
        star.pmrarad = sqlite3_column_double(stat, 25)
        star.pmdecrad = sqlite3_column_double(stat, 26)
        star.bayer = String(cString: sqlite3_column_text(stat, 27))
        star.flam = Int(sqlite3_column_int(stat, 28))
        star.con = String(cString: sqlite3_column_text(stat, 29))
        star.comp = Int(sqlite3_column_int(stat, 30))
        star.comp_primary = Int(sqlite3_column_int(stat, 31))
        star.base = String(cString: sqlite3_column_text(stat, 32))
        star.lum = sqlite3_column_double(stat, 33)
        star.varType = String(cString: sqlite3_column_text(stat, 34))
        star.varMin = sqlite3_column_double(stat, 35)
        star.varMax = sqlite3_column_double(stat, 36)
        return star
    }
    
    func load() {
        // stars_with_names     ~150 stars
        // stars_less_than_4    ~520 stars
        // stars_less_than_5    ~1640 stars
        // hygdata_v3           ~120000 stars
        if let path = Bundle.main.path(forResource: "stars_less_than_5", ofType: "csv") {
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                if let lines = String(data: data, encoding: .utf8)?.components(separatedBy: "\n") {
                    for i in 1...lines.count - 1 {
                        let star = Star(withCSVString: lines[i])
                        stars.append(star)
                        
                        print("processing: \(Double(i * 100)/Double(lines.count))%")
                    }
                }
                
                /*let sortedStars = stars.filter({ $0.mag != nil && $0.mag! <= 5.0 })
                let txt = sortedStars.map({ $0.csvString }).joined(separator: "\n")
                print(txt)*/
                
                print("\(stars.count) were loaded")
            } catch {
                print("Error on catalog opening")
            }
        }
    }
    
}


//id = 32263
//hip = 323494
//hd = 48915
//hr = 2491
//gl = Gl 244A
//bf = 9Alp CMa
//proper = Sirius
//ra = 6.752481
//dec = -16.716116
//dist = 2.6371
//pmra = -546.01
//pmdec = -1223.08
//rv = -9.4
//mag = -1.440
//absmag = 1.454
//spect = A0m...
//ci = 0.009
//x = -0.494323
//y = 2.476731
//z = -0.758485
//vx = 0.00000953
//vy = -0.00001207
//vz = -0.00001221
//rarad = 1.7677953696021995
//decrad = -0.291751258517685
//pmrarad = -0.000002647131177201389
//pmdecrad = -0.000005929659164
//bayer = Alp
//flam = 9
//con = CMa
//comp = 1,
//comp_primary = 32263
//base = Gl 244
//lum = 22.824433121735034,
//var =
//var_min = -1.333
//var_max = -1.523
class Star {
    public var id: Int = 0
    public var hip: Int?
    public var hd: Int?
    public var hr: Int?
    public var gl: String?
    public var bf: String?
    public var proper: String?
    public var ra: Double?   // right ascension
    public var dec: Double?  // declination
    public var dist: Double?
    public var pmra: Double?
    public var pmdec: Double?
    public var rv: Double?
    public var mag: Double?
    public var absmag: Double?
    public var spect: String?
    public var ci: Double?
    public var x: Double?
    public var y: Double?
    public var z: Double?
    public var vx: Double?
    public var vy: Double?
    public var vz: Double?
    public var rarad: Double?
    public var decrad: Double?
    public var pmrarad: Double?
    public var pmdecrad: Double?
    public var bayer: String?
    public var flam: Int?
    public var con: String?
    public var comp: Int?
    public var comp_primary: Int?
    public var base: String?
    public var lum: Double?
    public var varType: String?
    public var varMin: Double?
    public var varMax: Double?
    
    init() {
        
    }
    
    init(withCSVString str: String) {
        let parts = str.components(separatedBy: ",")
        if parts.count != 37 {
            return
        }
        
        self.id = Int(parts[0]) ?? 0
        self.hip = Int(parts[1])
        self.hd = Int(parts[2])
        self.hr = Int(parts[3])
        self.gl = parts[4]
        self.bf = parts[5]
        self.proper = parts[6].count == 0 ? nil : parts[6]
        self.ra = Double(parts[7])
        self.dec = Double(parts[8])
        self.dist = Double(parts[9])
        self.pmra = Double(parts[10])
        self.pmdec = Double(parts[11])
        self.rv = Double(parts[12])
        self.mag = Double(parts[13])
        self.absmag = Double(parts[14])
        self.spect = parts[15]
        self.ci = Double(parts[16])
        self.x = Double(parts[17])
        self.y = Double(parts[18])
        self.z = Double(parts[19])
        self.vx = Double(parts[20])
        self.vy = Double(parts[21])
        self.vz = Double(parts[22])
        self.rarad = Double(parts[23])
        self.decrad = Double(parts[24])
        self.pmrarad = Double(parts[25])
        self.pmdecrad = Double(parts[26])
        self.bayer = parts[27]
        self.flam = Int(parts[28])
        self.con = parts[29]
        self.comp = Int(parts[30])
        self.comp_primary = Int(parts[31])
        self.base = parts[32]
        self.lum = Double(parts[33])
        self.varType = parts[34]
        self.varMin = Double(parts[35])
        self.varMax = Double(parts[36])
    }
    
    public var csvString: String {
        let params = ["\(self.id)",
            hip != nil ? "\(hip!)" : "",
        hd != nil ? "\(hd!)" : "",
        hr != nil ? "\(hr!)" : "",
        gl != nil ? "\(gl!)" : "",
        bf != nil ? "\(bf!)" : "",
        proper != nil ? "\(proper!)" : "",
        ra != nil ? "\(ra!)" : "",
        dec != nil ? "\(dec!)" : "",
        dist != nil ? "\(dist!)" : "",
        pmra != nil ? "\(pmra!)" : "",
        pmdec != nil ? "\(pmdec!)" : "",
        rv != nil ? "\(rv!)" : "",
        mag != nil ? "\(mag!)" : "",
        absmag != nil ? "\(absmag!)" : "",
        spect != nil ? "\(spect!)" : "",
        ci != nil ? "\(ci!)" : "",
        x != nil ? "\(x!)" : "",
        y != nil ? "\(y!)" : "",
        z != nil ? "\(z!)" : "",
        vx != nil ? "\(vx!)" : "",
        vy != nil ? "\(vy!)" : "",
        vz != nil ? "\(vz!)" : "",
        rarad != nil ? "\(rarad!)" : "",
        decrad != nil ? "\(decrad!)" : "",
        pmrarad != nil ? "\(pmrarad!)" : "",
        pmdecrad != nil ? "\(pmdecrad!)" : "",
        bayer != nil ? "\(bayer!)" : "",
        flam != nil ? "\(flam!)" : "",
        con != nil ? "\(con!)" : "",
        comp != nil ? "\(comp!)" : "",
        comp_primary != nil ? "\(comp_primary!)" : "",
        base != nil ? "\(base!)" : "",
        lum != nil ? "\(lum!)" : "",
        varType != nil ? "\(varType!)" : "",
        varMin != nil ? "\(varMin!)" : "",
        varMax != nil ? "\(varMax!)" : ""]
        return params.joined(separator: ",")
    }
}
