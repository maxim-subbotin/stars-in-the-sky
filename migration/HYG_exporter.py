import sqlite3
from sqlite3 import Error

hyg_csv_path = "/Volumes/Data/MyProjects/StarsOnSky/StarsOnSky/Data/hygdata_v3.csv"
hyg_sqlite_path = "/Volumes/Data/MyProjects/StarsOnSky/StarsOnSky/Data/hyg.sqlite"

class Star:
    id = 0
    hip = 0
    hd = 0
    hr = 0
    gl = ""
    bf = ""
    proper = ""
    ra = 0.0
    dec = 0.0
    dist = 0.0
    pmra = 0.0
    pmdec = 0.0
    rv = 0.0
    mag = 0.0
    absmag = 0.0
    spect = ""
    ci = 0.0
    x = 0.0
    y = 0.0
    z = 0.0
    vx = 0.0
    vy = 0.0
    vz = 0.0
    rarad = 0.0
    decrad = 0.0
    pmrarad = 0.0
    pmdecrad = 0.0
    bayer = ""
    flam = 0
    con = ""
    comp = 0
    comp_primary = 0
    base = ""
    lum = 0.0
    var_type = ""
    var_min = 0.0
    var_max = 0.0

    def sql_data(self):
        return  (self.hip, self.hd, self.hr, self.gl, self.bf, self.proper, self.ra, self.dec, self.dist,
                 self.pmra, self.pmdec, self.rv, self.mag, self.absmag, self.spect, self.ci, self.x, self.y, self.z,
                 self.vx, self.vy, self.vz, self.rarad, self.decrad, self.pmrarad, self.pmdecrad, self.bayer, self.flam, self.con,
                 self.comp, self.comp_primary, self.base, self.lum, self.var_type, self.var_min, self.var_max)

def read_csv():
    lines = []
    with open(hyg_csv_path, 'r') as file:
        for cnt, line in enumerate(file):
            lines.append(line)

    return lines

def to_int(str):
    if len(str) == 0:
        return 0
    else:
        return int(str)

def to_float(str):
    if len(str) == 0:
        return float("nan")
    elif str == '\n':
        return float("nan")
    else:
        return float(str)

def create_db():
    conn = None
    try:
        conn = sqlite3.connect(hyg_sqlite_path)
        print("DB connection: OK")
    except Error as e:
        print(e)
    return conn

def create_table(conn):
    script = """CREATE TABLE IF NOT EXISTS stars (
                id integer PRIMARY KEY,
                hip integer,
                hd integer,
                hr integer,
                gl text,
                bf text,
                proper text,
                ra real,
                dec real,
                dist real,
                pmra real,
                pmdec real,
                rv real,
                mag real,
                absmag real,
                spect text,
                ci real,
                x real,
                y real,
                z real,
                vx real,
                vy real,
                vz real,
                rarad real,
                decrad real,
                pmrarad real,
                pmdecrad real,
                bayer text,
                flam integer,
                con text,
                comp integer,
                comp_primary integer,
                base text,
                lum real,
                var_type text,
                var_min real,
                var_max real);"""
    try:
        c = conn.cursor()
        c.execute(script)
        print("Table creation: OK")
    except Error as e:
        print(e)

def save_star(star, conn):
    script = """INSERT INTO stars(
                hip,
                hd,
                hr,
                gl,
                bf,
                proper,
                ra,
                dec,
                dist,
                pmra,
                pmdec,
                rv,
                mag,
                absmag,
                spect,
                ci,
                x,
                y,
                z,
                vx,
                vy,
                vz,
                rarad,
                decrad,
                pmrarad,
                pmdecrad,
                bayer,
                flam,
                con,
                comp,
                comp_primary,
                base,
                lum,
                var_type,
                var_min,
                var_max)  
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """
    try:
        cur = conn.cursor()
        cur.execute(script, star.sql_data())
        print("Star adding: OK")
    except Error as e:
        print(e)

def process_hyg(conn):
    lines = read_csv()

    stars = []

    i = 0
    for line in lines:
        if i == 0:
            i += 1
            continue

        parts = line.split(",")
        if len(parts) == 37:
            star = Star()
            star.id = int(parts[0])
            star.hip = to_int(parts[1])
            star.hd = to_int(parts[2])
            star.hr = parts[3]
            star.gl = parts[4]
            star.bf = parts[5]
            star.proper = parts[6]
            star.ra = float(parts[7])
            star.dec = float(parts[8])
            star.dist = float(parts[9])
            star.pmra = float(parts[10])
            star.pmdec = float(parts[11])
            star.rv = float(parts[12])
            star.mag = float(parts[13])
            star.absmag = float(parts[14])
            star.spect = parts[15]
            star.ci = to_float(parts[16])
            star.x = float(parts[17])
            star.y = float(parts[18])
            star.z = float(parts[19])
            star.vx = float(parts[20])
            star.vy = float(parts[21])
            star.vz = float(parts[22])
            star.rarad = float(parts[23])
            star.decrad = float(parts[24])
            star.pmrarad = float(parts[25])
            star.pmdecrad = float(parts[26])
            star.bayer = parts[27]
            star.flam = to_int(parts[28])
            star.con = parts[29]
            star.comp = to_int(parts[30])
            star.comp_primary = to_int(parts[31])
            star.base = parts[32]
            star.lum = float(parts[33])
            star.var_type = parts[34]
            star.var_min = to_float(parts[35])
            star.var_max = to_float(parts[36])

            stars.append(star)

            save_star(star, conn)

        i += 1
        print "Completed: " + str(i * 100.0 / len(lines))

    print len(stars)


conn = create_db()
with conn:
    create_table(conn)
    process_hyg(conn)