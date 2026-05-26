# /// script
# dependencies = [
#   "faker",
#   "tqdm",
# ]
# ///

import csv
import random
from contextlib import contextmanager
from datetime import timedelta
from pathlib import Path
from faker import Faker
from tqdm import tqdm

# --- Local Paths ---
BASE_DIR = Path(__file__).parent
CSV_DIR = BASE_DIR / "csv"
CTL_DIR = BASE_DIR / "ctl"

# --- Target Paths for .ctl files ---
# This path is used in generated INFILE directives within control files.
# By default, it points to the standard container path: /tmp/sqlldr/csv
C_CSV = "/tmp/sqlldr/csv"

# --- Realistic Automotive Data ---
CAR_DATA = {
    "Toyota": ["Corolla", "Yaris", "Auris", "RAV4", "C-HR", "Camry", "Hilux", "Prius", "Aygo", "Supra"],
    "Volkswagen": ["Golf", "Passat", "Polo", "Tiguan", "T-Roc", "Arteon", "Touareg", "ID.3", "ID.4", "Transporter"],
    "BMW": ["3 Series", "5 Series", "1 Series", "X3", "X5", "X1", "7 Series", "X7", "M4", "i3"],
    "Audi": ["A4", "A3", "A6", "Q5", "Q3", "Q7", "A5", "TT", "e-tron", "R8"],
    "Mercedes-Benz": ["C-Class", "E-Class", "A-Class", "GLC", "GLE", "S-Class", "CLA", "GLA", "EQS", "Vito"],
    "Ford": ["Focus", "Fiesta", "Mondeo", "Kuga", "Puma", "Mustang", "Ranger", "Explorer", "S-Max", "Transit"],
    "Skoda": ["Octavia", "Fabia", "Superb", "Karoq", "Kodiaq", "Kamiq", "Scala", "Enyaq", "Citigo", "Rapid"],
    "Hyundai": ["Tucson", "i30", "i20", "Kona", "IONIQ 5", "Santa Fe", "Bayon", "Elantra", "i10", "Staria"],
    "Kia": ["Ceed", "Sportage", "Stonic", "Niro", "EV6", "Sorento", "Rio", "Picanto", "Stinger", "XCeed"],
    "Renault": ["Clio", "Megane", "Captur", "Kadjar", "Zoe", "Arkana", "Talisman", "Scenic", "Twingo", "Master"],
    "Peugeot": ["208", "308", "3008", "5008", "2008", "508", "Partner", "Expert", "Rifter", "Boxer"],
    "Opel": ["Astra", "Corsa", "Insignia", "Mokka", "Grandland", "Crossland", "Combo", "Vivaro", "Zafira", "Adam"],
    "Volvo": ["XC60", "XC40", "XC90", "V60", "V40", "S60", "S90", "V90", "C40", "S40"],
    "Nissan": ["Qashqai", "Juke", "Leaf", "X-Trail", "Micra", "Navara", "Ariya", "Pulsar", "370Z", "GT-R"],
    "Honda": ["Civic", "CR-V", "HR-V", "Jazz", "Accord", "e", "NSX", "City", "Insight", "Odyssey"],
    "Mazda": ["CX-5", "CX-30", "3", "6", "2", "MX-5", "CX-3", "CX-60", "MX-30", "RX-8"],
    "Fiat": ["500", "Tipo", "Panda", "500X", "Ducato", "Doblo", "500L", "Punto", "Talento", "Bravo"],
    "Lexus": ["RX", "NX", "UX", "ES", "IS", "LS", "LC", "CT", "RC", "GX"],
    "Tesla": ["Model 3", "Model Y", "Model S", "Model X", "Cybertruck", "Roadster"],
    "Suzuki": ["Vitara", "Swift", "Ignis", "S-Cross", "Jimny", "Swace", "Across", "Baleno", "Alto", "Celerio"],
    "Seat": ["Leon", "Ibiza", "Ateca", "Arona", "Tarraco", "Alhambra", "Altea", "Exeo", "Mii", "Toledo"],
    "Cupra": ["Formentor", "Leon", "Ateca", "Born", "Tavascan"],
    "Jeep": ["Renegade", "Compass", "Grand Cherokee", "Wrangler", "Gladiator", "Cherokee"],
    "Land Rover": ["Defender", "Discovery", "Range Rover", "Evoque", "Velar", "Sport"],
    "Alfa Romeo": ["Giulia", "Stelvio", "Tonale", "Giulietta", "Mito", "4C"],
    "Mitsubishi": ["ASX", "Outlander", "Eclipse Cross", "L200", "Space Star", "Pajero"],
    "Subaru": ["Forester", "Outback", "XV", "Impreza", "WRX", "BRZ"],
    "Porsche": ["911", "Cayenne", "Macan", "Panamera", "Taycan", "718 Cayman"],
    "Jaguar": ["F-Pace", "E-Pace", "I-Pace", "XF", "XE", "F-Type"],
    "Dacia": ["Duster", "Sandero", "Jogger", "Spring", "Logan", "Lodgy"]
}

# --- Table Definitions ---
TABLES = {
    "p_72_panstwo": {
        "count": 10,
        "cols": ["ID_PANSTWA", "NAZWA_PANSTWA"]
    },
    "p_72_wojewodztwo": {
        "count": 50,
        "cols": ["ID_WOJEWODZTWO", "ID_PANSTWA", "NAZWA_WOJEWODZTWA"]
    },
    "p_72_miasto": {
        "count": 200,
        "cols": ["ID_MIASTA", "ID_WOJEWODZTWO", "NAZWA_MIASTA"]
    },
    "p_72_ulica": {
        "count": 1000,
        "cols": ["ID_ULICA", "ID_MIASTA", "NAZWA_ULICY"]
    },
    "p_72_oddzial": {
        "count": 50,
        "cols": ["ID_ODDZIAL", "NAZWA_ODDZIALU", "TELEFON", "EMAIL", "GODZINY_OTWARCIA", "NUMER_BUDYNKU", "ID_ULICA", "KOD_POCZTOWY"]
    },
    "p_72_stanowisko": {
        "count": 15,
        "cols": ["ID_STANOWISKO", "NAZWA_STANOWISKA", "OPIS", "STAWKA_GODZINOWA"]
    },
    "p_72_pracownik": {
        "count": 300,
        "cols": ["ID_PRACOWNIK", "ID_ODDZIAL", "ID_STANOWISKO", "IMIE", "NAZWISKO", "PESEL", "TELEFON", "EMAIL", "DATA_ZATRUDNIENIA DATE 'YYYY-MM-DD'"]
    },
    "p_72_kategoria": {
        "count": 10,
        "cols": ["ID_KATEGORIA", "NAZWA_KATEGORII", "OPIS", "STAWKA_BAZOWA_NETTO"]
    },
    "p_72_kolor": {
        "count": 20,
        "cols": ["ID_KOLOR", "NAZWA_KOLORU"]
    },
    "p_72_marka": {
        "count": len(CAR_DATA),
        "cols": ["ID_MARKA", "NAZWA_MARKI"]
    },
    "p_72_model": {
        "count": sum(len(models) for models in CAR_DATA.values()),
        "cols": ["ID_MODEL", "NAZWA_MODELU", "ID_MARKA"]
    },
    "p_72_typ_paliwa": {
        "count": 6,
        "cols": ["ID_TYPU_PALIWA", "NAZWA_PALIWA"]
    },
    "p_72_typ_skrzyni": {
        "count": 4,
        "cols": ["ID_TYPU_SKRZYNI", "NAZWA_SKRZYNI"]
    },
    "p_72_samochod": {
        "count": 2000,
        "cols": ["ID_SAMOCHOD", "ID_ODDZIAL", "ID_TYPU_PALIWA", "ID_KOLOR", "ID_KATEGORIA", "ID_MODEL", "ID_TYPU_SKRZYNI", "NUMER_REJESTRACYJNY", "NUMER_VIN", "ROK_PRODUKCJI", "PRZEBIEG_KM", "POJEMNOSC_SILNIKA_CM3", "MOC_KM"]
    },
    "p_72_typ_ubezpieczenia": {
        "count": 10,
        "cols": ["ID_TYPU_UBEZPIECZENIA", "NAZWA_TYPU", "OPIS"]
    },
    "p_72_ubezpieczenie": {
        "count": 2500,
        "cols": ["ID_UBEZPIECZENIE", "ID_TYPU_UBEZPIECZENIA", "NUMER_POLISY", "DATA_OD DATE 'YYYY-MM-DD'", "DATA_DO DATE 'YYYY-MM-DD'", "KWOTA_POKRYCIA", "SKLADKA"]
    },
    "p_72_klient": {
        "count": 5000,
        "cols": ["ID_KLIENT", "IMIE", "NAZWISKO", "PESEL", "TELEFON", "EMAIL", "NUMER_DOWODU", "NUMER_PRAWA_JAZDY", "KATEGORIA_PRAWA_JAZDY", "DATA_WAZNOSCI_PRAWA_JAZDY DATE 'YYYY-MM-DD'", "DATA_REJESTRACJI DATE 'YYYY-MM-DD'"]
    },
    "p_72_wypozyczenia": {
        "count": 100000,
        "cols": [
            "ID_SAMOCHOD", "ID_KLIENT", "ID_ODDZIAL_WYDANIA", "ID_ODDZIAL_ODBIORU", "ID_UBEZPIECZENIE", "ID_PRACOWNIK_ODBIORU", "ID_PRACOWNIK_WYDANIA", 
            "STATUS_WYPOZYCZENIA", "UWAGI CHAR(500)", "DATA_WYDANIA DATE 'YYYY-MM-DD'", "DATA_PLANOWANEGO_ZWROTU DATE 'YYYY-MM-DD'", 
            "DATA_FAKTYCZNEGO_ZWROTU DATE 'YYYY-MM-DD' NULLIF DATA_FAKTYCZNEGO_ZWROTU=BLANKS", "KOSZT_TRANSPORTU", "PRZEBIEG_START", 
            "PRZEBIEG_FINISH INTEGER EXTERNAL NULLIF PRZEBIEG_FINISH=BLANKS", "PRZEBIEG_LIMIT", "CENA_DOBA", "CENA_RABAT_PROCENT", "KAUCJA"
        ]
    },
}

fake = Faker("pl_PL")
Faker.seed(42)
random.seed(42)

@contextmanager
def csv_writer(table_name):
    """Context manager for writing CSV files."""
    file_path = CSV_DIR / f"{table_name}.csv"
    with open(file_path, "w", newline="", encoding="utf-8") as f:
        yield csv.writer(f)

def get_unique(func, seen_set):
    """Generate a unique value using the provided function and set."""
    while True:
        val = func()
        if val not in seen_set:
            seen_set.add(val)
            return val

def generate_data():
    """Generate all CSV data files."""
    CSV_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Generating data into {CSV_DIR}...")

    # Static helpers
    countries = ["Polska", "Niemcy", "Czechy", "Słowacja", "Litwa", "Austria", "Francja", "Hiszpania", "Włochy", "Holandia"]
    positions = ["Dyrektor", "Kierownik Oddziału", "Doradca Klienta", "Mechanik", "Księgowy", "Specjalista IT", "Pracownik Myjni", "Ochroniarz", "Kierowca", "Asystent Zarządu"]
    categories = ["Mini", "Economy", "Compact", "Standard", "Fullsize", "Premium", "Luxury", "SUV", "Van", "Convertible"]
    fuels = ["Benzyna", "Diesel", "LPG", "Hybryda", "Elektryczny", "Wodór"]
    gearboxes = ["Manualna", "Automatyczna", "Półautomatyczna", "CVT"]
    ins_types = ["OC Podstawowe", "AC Pełne", "NNW Kierowca", "Assistance Premium", "Szyby i Opony", "Kradzież", "Ochrona Prawna", "Pakiet VIP", "Półroczne OC", "AC Mini"]
    colors = ["Biały Perłowy", "Czarny Metalik", "Srebrny", "Grafitowy", "Granatowy", "Czerwony", "Niebieski", "Zielony", "Brązowy", "Bordowy", "Szary", "Złoty", "Żółty", "Pomarańczowy", "Fioletowy", "Turkusowy", "Piaskowy", "Limonkowy", "Miedziany", "Różowy"]

    # 1. Countries
    with csv_writer("p_72_panstwo") as writer:
        for i in range(1, TABLES["p_72_panstwo"]["count"] + 1):
            writer.writerow([i, countries[i-1]])

    # 2-4. Geography
    with csv_writer("p_72_wojewodztwo") as writer:
        for i in range(1, TABLES["p_72_wojewodztwo"]["count"] + 1):
            writer.writerow([i, random.randint(1, 10), fake.administrative_unit()])

    with csv_writer("p_72_miasto") as writer:
        for i in range(1, TABLES["p_72_miasto"]["count"] + 1):
            writer.writerow([i, random.randint(1, 50), fake.city()])

    with csv_writer("p_72_ulica") as writer:
        for i in range(1, TABLES["p_72_ulica"]["count"] + 1):
            writer.writerow([i, random.randint(1, 200), fake.street_name()])

    # 5. Branches
    with csv_writer("p_72_oddzial") as writer:
        for i in range(1, TABLES["p_72_oddzial"]["count"] + 1):
            writer.writerow([i, f"Oddział {fake.city()}", fake.phone_number()[:20], fake.email()[:100], "08:00-20:00", fake.building_number(), random.randint(1, 1000), fake.postcode()])

    # 6. Positions
    with csv_writer("p_72_stanowisko") as writer:
        for i in range(1, TABLES["p_72_stanowisko"]["count"] + 1):
            name = positions[i-1] if i <= len(positions) else f"Specjalista {i}"
            writer.writerow([i, name, f"Zakres obowiązków dla: {name}", round(random.uniform(30, 200), 2)])

    # 7. Employees
    pesels = set()
    with csv_writer("p_72_pracownik") as writer:
        for i in range(1, TABLES["p_72_pracownik"]["count"] + 1):
            writer.writerow([i, random.randint(1, 50), random.randint(1, 15), fake.first_name(), fake.last_name(), get_unique(fake.pesel, pesels), fake.phone_number()[:20], fake.email()[:100], fake.date_between(start_date="-10y", end_date="today")])

    # 8-13. Car Config
    with csv_writer("p_72_kategoria") as writer:
        for i in range(1, 11):
            writer.writerow([i, categories[i-1], f"Segment {categories[i-1]}", round(random.uniform(100, 1500), 2)])

    with csv_writer("p_72_kolor") as writer:
        for i in range(1, 21):
            writer.writerow([i, colors[i-1]])

    # Car Brands & Models (Linked)
    brand_list = list(CAR_DATA.keys())
    with csv_writer("p_72_marka") as writer:
        for i, brand in enumerate(brand_list, 1):
            writer.writerow([i, brand])

    model_id = 1
    model_map = {} # Store model IDs per brand for car generation
    with csv_writer("p_72_model") as writer:
        for brand_id, brand in enumerate(brand_list, 1):
            model_map[brand_id] = []
            for model_name in CAR_DATA[brand]:
                writer.writerow([model_id, model_name, brand_id])
                model_map[brand_id].append(model_id)
                model_id += 1

    with csv_writer("p_72_typ_paliwa") as writer:
        for i in range(1, 7): writer.writerow([i, fuels[i-1]])
    with csv_writer("p_72_typ_skrzyni") as writer:
        for i in range(1, 5): writer.writerow([i, gearboxes[i-1]])

    # 14. Cars
    vins, plates = set(), set()
    all_model_ids = [mid for ids in model_map.values() for mid in ids]
    with csv_writer("p_72_samochod") as writer:
        for i in range(1, TABLES["p_72_samochod"]["count"] + 1):
            writer.writerow([
                i, 
                random.randint(1, 50),      # Oddzial
                random.randint(1, 6),       # Paliwo
                random.randint(1, 20),      # Kolor
                random.randint(1, 10),      # Kategoria
                random.choice(all_model_ids), # Model
                random.randint(1, 4),       # Skrzynia
                get_unique(fake.license_plate, plates), 
                get_unique(lambda: fake.bothify('??###############').upper(), vins), 
                random.randint(2018, 2024), 
                random.randint(0, 150000), 
                random.randint(999, 4500), 
                random.randint(75, 600)
            ])

    # 15-16. Insurance
    with csv_writer("p_72_typ_ubezpieczenia") as writer:
        for i in range(1, 11): writer.writerow([i, ins_types[i-1], f"Warunki polisy: {ins_types[i-1]}"])
    with csv_writer("p_72_ubezpieczenie") as writer:
        for i in range(1, TABLES["p_72_ubezpieczenie"]["count"] + 1):
            d_od = fake.date_between(start_date="-2y", end_date="today")
            writer.writerow([i, random.randint(1, 10), fake.bothify('POL-#########'), d_od, d_od + timedelta(days=365), round(random.uniform(20000, 500000), 2), round(random.uniform(400, 8000), 2)])

    # 17. Clients
    pesels_k = set()
    with csv_writer("p_72_klient") as writer:
        for i in range(1, TABLES["p_72_klient"]["count"] + 1):
            writer.writerow([
                i, fake.first_name(), fake.last_name(), get_unique(fake.pesel, pesels_k), 
                fake.phone_number()[:20], fake.email()[:100], fake.bothify('???######').upper(), 
                fake.bothify('#####/##/####'), random.choice("ABCD"), 
                fake.date_between(start_date="today", end_date="+10y"), 
                fake.date_between(start_date="-5y", end_date="today")
            ])

    # 18. Rentals
    with csv_writer("p_72_wypozyczenia") as writer:
        for i in tqdm(range(1, TABLES["p_72_wypozyczenia"]["count"] + 1), desc="Generating Rentals"):
            d_wy = fake.date_between(start_date="-3y", end_date="today")
            status = random.choice(["ZAKOŃCZONE", "AKTYWNE", "ANULOWANE", "REZERWACJA"])
            d_fk, p_fi = ("", "")
            if status == "ZAKOŃCZONE":
                d_fk = d_wy + timedelta(days=random.randint(1, 21))
                p_fi = random.randint(100, 300000)
            
            writer.writerow([
                random.randint(1, 2000),    # Samochod
                random.randint(1, 5000),    # Klient
                random.randint(1, 50),      # Wydanie
                random.randint(1, 50),      # Odbior
                random.randint(1, 2500),    # Ubezpieczenie
                random.randint(1, 300),     # Pracownik Odb
                random.randint(1, 300),     # Pracownik Wyd
                status, fake.sentence()[:500], d_wy, d_wy + timedelta(days=random.randint(1, 14)), 
                d_fk, round(random.uniform(0, 300), 2), random.randint(0, 200000), p_fi, 
                random.randint(100, 3000), round(random.uniform(90, 800), 2), 
                round(random.uniform(0, 15), 2), round(random.uniform(300, 4000), 2)
            ])

def generate_ctl():
    """Generate SQL*Loader control files."""
    CTL_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Generating control files into {CTL_DIR}...")
    for table, cfg in TABLES.items():
        ctl_content = (
            "OPTIONS (SKIP=0, ERRORS=100000)\n"
            "LOAD DATA\n"
            f"INFILE '{C_CSV}/{table}.csv'\n"
            f"INTO TABLE {table.upper()}\n"
            "APPEND\n"
            "FIELDS TERMINATED BY ','\n"
            "OPTIONALLY ENCLOSED BY '\"'\n"
            "TRAILING NULLCOLS\n"
            "(\n"
            f"  {',\n  '.join(cfg['cols'])}\n"
            ")\n"
        )
        (CTL_DIR / f"{table}.ctl").write_text(ctl_content)

if __name__ == "__main__":
    generate_data()
    generate_ctl()
