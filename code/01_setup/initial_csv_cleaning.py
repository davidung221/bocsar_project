#The initial dataset was in a wide table format. This code was needed to transform it into a form suitable for sql, as well as basic data wrangling.

import pandas as pd

# File paths
INPUT_FILE = "Incident_by_NSW.xlsx"
OUTPUT_FILE = "incidents_by_nsw_long.csv"


def main():
    # 1. Load the raw file
    print(f"Loading {INPUT_FILE}...")
    df = pd.read_excel(INPUT_FILE)

    # 2. Identify id columns vs date columns
    id_vars = ["State", "Offence category", "Subcategory", "2025 population", "2026 population"]
    date_cols = [c for c in df.columns if c not in id_vars]

    # 3. Unpivot (wide -> long)
    print("Reshaping from wide to long format...")
    long_df = df.melt(
        id_vars=id_vars,
        value_vars=date_cols,
        var_name="Month",
        value_name="Incident_Count",
    )

    # 4. Convert 'Jan 1995' style strings into a real date
    long_df["Month"] = pd.to_datetime(long_df["Month"], format="%b %Y")

    # 5. Drop rows with no incident count (common in gov't exports)
    long_df = long_df.dropna(subset=["Incident_Count"])

    # 6. Clean column names for SQL (lowercase, underscores)
    long_df.columns = (
        long_df.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_")
    )

    # 7. Convert dataframe to csv
    print(f"Writing {len(long_df)} rows to {OUTPUT_FILE}...")
    long_df.to_csv(OUTPUT_FILE, index=False)
    print("Done.")


if __name__ == "__main__":
    main()
