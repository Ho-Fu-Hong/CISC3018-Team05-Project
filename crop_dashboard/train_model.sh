#!/bin/bash
cd /var/www/html/crop_dashboard

# Start the virtual environment
source .venv/bin/activate

echo "1. Check the virtual environment..."
which python
python --version

echo "2. Inspection kit..."
pip list | grep -E "pandas|numpy|scikit-learn"

echo "3. Create a CSV file..."
if [ ! -f yield_df.csv ]; then
    python3 -c "
import json
import pandas as pd
print('Read JSON archive...')
with open('assets/data_all_records_new.json', 'r') as f:
    data = json.load(f)
print(f'load {len(data)} Pen data')
df = pd.DataFrame(data)
required_cols = ['Year', 'Rainfall', 'Pesticides', 'Avg_Temperature', 'Country', 'Crop', 'Yield']
df = df[required_cols]
df.to_csv('yield_df.csv', index=False)
print(f'create yield_df.csv，{len(df)} Pen data')
"
else
    echo "yield_df.csv Existing"
fi

echo "4. Training Model..."
python3 crop_yield_prediction.py train

echo "5. Inspection results..."
ls -la *.pkl

echo "6. Test prediction..."
python3 crop_yield_prediction.py 2026 800.0 50000.0 20.0 "belarus" "Maize"
