"""
Sales Data Cleaning Script
--------------------------
This script:
1. Loads raw sales data
2. Converts date columns to ISO format
3. Cleans text encoding issues
4. Prepares data for SQL import
5. Exports cleaned dataset
"""

import pandas as pd


# -------------------------------
# File Paths (Relative for GitHub)
# -------------------------------
INPUT_FILE = "01_Data/csv_raw/Superstore_sales_raw.csv"
OUTPUT_FILE = "01_Data/csv_clean/v1_superstore_sql_ready.csv"


# -------------------------------
# Load Data
# -------------------------------
def load_data(file_path):
    return pd.read_csv(file_path, encoding="utf-8-sig")


# -------------------------------
# Convert Dates to ISO Format
# -------------------------------
def convert_dates(df):
    df["Order_Date"] = pd.to_datetime(df["Order_Date"], format="%d-%m-%Y")
    df["Ship_Date"] = pd.to_datetime(df["Ship_Date"], format="%d-%m-%Y")

    df["Order_Date"] = df["Order_Date"].dt.strftime("%Y-%m-%d")
    df["Ship_Date"] = df["Ship_Date"].dt.strftime("%Y-%m-%d")

    return df


# -------------------------------
# Clean Text Columns
# -------------------------------
def clean_text(df):
    df["Product_Name"] = (
        df["Product_Name"]
        .str.replace("â€", '"', regex=False)
        .str.replace("â€œ", '"', regex=False)
        .str.replace("â€“", "-", regex=False)
        .str.replace("â€”", "-", regex=False)
        .str.replace("\u00A0", " ", regex=False)
        .str.strip()
    )

    # Escape quotes for SQL
    df["Product_Name"] = df["Product_Name"].str.replace('"', '""', regex=False)

    return df


# -------------------------------
# Save Cleaned Data
# -------------------------------
def save_data(df, file_path):
    df.to_csv(
        file_path,
        index=False,
        encoding="utf-8",
        quotechar='"',
        quoting=1,
        sep="|",
        lineterminator="\n"
    )


# -------------------------------
# Main Execution
# -------------------------------
def main():
    print("Loading data...")
    df = load_data(INPUT_FILE)

    print("Converting date columns...")
    df = convert_dates(df)

    print("Cleaning text fields...")
    df = clean_text(df)

    print("Saving cleaned data...")
    save_data(df, OUTPUT_FILE)

    print("Data cleaning completed successfully!")


if __name__ == "__main__":
    main()
