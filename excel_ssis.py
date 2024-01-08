import pandas as pd

# Read excel file and write each sheet to a csv file (warning: takes a long time)

# Read excel file
xls = pd.ExcelFile('ssis_data/final_ssis.xlsx')

# Get the sheet names
sheet_names = xls.sheet_names

# Loop through each sheet and write to csv file
for sheet in sheet_names:
    df = pd.read_excel('ssis_data/final_ssis.xlsx', sheet_name=sheet)
    df.to_csv('ssis_data/' + sheet + '.csv', index=False)
