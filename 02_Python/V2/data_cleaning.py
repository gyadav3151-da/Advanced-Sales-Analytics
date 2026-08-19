"""
Sales Data Cleaning Script (v2 - Production Ready)
---------------------------------------------------
Improvements:
- Added robust error handling
- Removed Excel preprocessing dependency
- Standardized schema handling
- Improved portability (relative paths)
- Safer column operations
"""

import pandas as pd
from pathlib import Path
import sys
import csv


# -------------------------------
# File Paths (GitHub-friendly)
# -------------------------------
BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_FILE = BASE_DIR / "01_Data" / "csv_raw" / "superstore_sales_raw.csv"
OUTPUT_FILE = BASE_DIR / "01_Data" / "csv_clean" / "v2_superstore_clean.csv"


# -------------------------------
# Load Data
# -------------------------------
def load_data(file_path: Path):
    """
    Loads a CSV file into a pandas DataFrame.

    Args:
        file_path (Path): Path to the raw CSV file.

    Returns:
        pd.DataFrame: Loaded dataset.

    Raises:
        SystemExit: If file is missing or empty.
    """
    try:
        return pd.read_csv(file_path, encoding="latin-1")

    except FileNotFoundError:
        print(f"❌ File not found: {file_path}")
        sys.exit(1)

    except pd.errors.EmptyDataError:
        print(f"❌ File is empty: {file_path}")
        sys.exit(1)


# -------------------------------
# Standardize Columns
# -------------------------------
def standardize_cols(df: pd.DataFrame):
    """
    Standardizes column names for consistency.

    - Converts to lowercase
    - Strips whitespace
    - Replaces spaces with underscores

    Args:
        df (pd.DataFrame): Raw dataframe

    Returns:
        pd.DataFrame: Cleaned dataframe with standardized columns
    """
    df.columns = (
        df.columns
        .str.lower()
        .str.strip()
        .str.replace(" ", "_")
    )

    return df

# -------------------------------
# Convert Dates to ISO Strings
# -------------------------------
def convert_dates_to_iso_strings(df: pd.DataFrame):
    """
    Converts raw date columns into ISO 8601 string format (YYYY-MM-DD).

    This function is designed for export-ready datasets where dates
    must be stored as standardized strings for CSV / SQL ingestion.

    It handles mixed-format Excel exports such as:
    - 8/27/2014
    - 11-11-2014
    - 07-08-17

    Approach:
    1. Normalizes separators (- → /)
    2. Parses dates using pandas datetime inference
    3. Converts datetime objects into ISO 8601 string format
    4. Invalid dates are coerced into NaT and remain missing

    Args:
        df (pd.DataFrame): Input dataframe with raw date columns

    Returns:
        pd.DataFrame: Dataframe with ISO-formatted date strings
    """

    date_cols = ["order_date", "ship_date"]

    for col in date_cols:
        if col not in df.columns:
            raise KeyError(f"Missing required column: {col}")

        # Normalize separators for consistency
        df[col] = (
            df[col]
            .astype(str)
            .str.replace("-", "/", regex=False)
        )

        # Parse to datetime
        df[col] = pd.to_datetime(df[col], errors="coerce")

        # Convert to ISO string format
        df[col] = df[col].dt.strftime("%Y-%m-%d")

    return df


# -------------------------------
# Save Cleaned Data
# -------------------------------
def save_data(df: pd.DataFrame, file_path: Path):
    """
    Exports dataframe to pipe-delimited CSV for SQL BULK INSERT.

    Uses safe quoting to handle commas and special characters in text fields.

    Args:
        df (pd.DataFrame): Cleaned dataset
        file_path (Path): Destination file path

    Returns:
        None
    """
    try:
        file_path.parent.mkdir(parents=True, exist_ok=True)

        df.to_csv(
            file_path,
            index=False,
            encoding="utf-8",
            sep='|',
            quoting=csv.QUOTE_NONE,
            escapechar="\\"
        )

        print("✅ Data cleaning completed successfully!")

    except PermissionError:
        print(f"❌ File is open or locked: {file_path}")
        sys.exit(1)

    except Exception as e:
        print(f"❌ Unexpected error while saving: {e}")
        sys.exit(1)



# -------------------------------
# Main Execution
# -------------------------------
def main():
    """
    Executes the end-to-end sales data cleaning pipeline.

    Pipeline steps:
    1. Load raw CSV data from input path
    2. Standardize column names and remove unnecessary fields
    3. Convert and normalize date columns into datetime format
    4. Save cleaned dataset in SQL-ready format

    Output:
        A cleaned CSV file optimized for SQL ingestion and analysis.

    Notes:
        - Designed for raw Excel-exported datasets with inconsistent formatting
        - Uses coercion-based parsing to handle invalid or mixed data formats
        - Safe to run repeatedly (idempotent output file overwrite)
    """
    print("Loading data...")
    df = load_data(INPUT_FILE)

    print("Standardizing columns...")
    df = standardize_cols(df)

    print("Converting dates...")
    df = convert_dates_to_iso_strings(df)

    print("Saving cleaned dataset...")
    save_data(df, OUTPUT_FILE)


if __name__ == "__main__":
    main()

