import pandas as pd
import argparse

# Add the DESeq2 result, followed by the gene2go hash file (from excon), followed by the GO2Actual name hash from GO (using the R code below)

#suppressMessages(library(GO.db))
#go <- keys(GO.db, keytype="GOID")
#df <- select(GO.db, columns=c("GOID","TERM"), keys=go, keytype="GOID")
#write.table(df, "df_goterms.txt", sep = "\t", row.names = FALSE, quote = FALSE, col.names = FALSE)


def main(file1, file2, file3):
    # Load the first TSV file into a DataFrame
    df1 = pd.read_csv(file1, sep='\t')
    print("df1 columns:", df1.columns)

    # Load the second TSV file into a DataFrame
    df2 = pd.read_csv(file2, sep='\t', header=None, names=['Gene', 'GO_ID'])
    print("df2 columns:", df2.columns)

    # Load the third TSV file containing GO_ID to GO_Name mapping
    df3 = pd.read_csv(file3, sep='\t')
    print("df3 columns:", df3.columns)

    # Ensure the correct column names are in df3
    if 'GO_ID' not in df3.columns or 'GO_Name' not in df3.columns:
        print("Error: df3 must contain 'GO_ID' and 'GO_Name' columns")
        return

    # Merge df2 with df3 to add GO names
    df2 = pd.merge(df2, df3, on='GO_ID', how='left')
    print("df2 after merge with df3:", df2.head())

    # Fill NaN values in GO_Name column with empty string and convert to string
    df2['GO_Name'] = df2['GO_Name'].fillna('').astype(str)

    # Group the GO IDs and GO Names by Gene and combine them into a single string
    df2_grouped = df2.groupby('Gene').agg({
        'GO_ID': lambda x: ','.join(x),
        'GO_Name': lambda x: ','.join(x)
    }).reset_index()
    print("df2_grouped:", df2_grouped.head())

    # Merge the grouped GO IDs and GO Names with the first DataFrame
    merged_df = pd.merge(df1, df2_grouped, left_on=df1.columns[0], right_on='Gene', how='left')

    # Drop the 'Gene' column that was added from df2_grouped during the merge
    merged_df.drop(columns=['Gene'], inplace=True)

    # Save the resulting DataFrame to a new TSV file
    output_file = 'merged_output_with_go_names.tsv'
    merged_df.to_csv(output_file, sep='\t', index=False)

    print(f"Merged file saved as '{output_file}'")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Merge TSV files based on gene names.')
    parser.add_argument('file1', help='The first TSV file containing gene data.')
    parser.add_argument('file2', help='The second TSV file containing gene and GO ID data.')
    parser.add_argument('file3', help='The third TSV file containing GO ID to GO Name mapping.')

    args = parser.parse_args()
    main(args.file1, args.file2, args.file3)
