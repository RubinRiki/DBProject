import csv
import random
from datetime import datetime, timedelta

start_date = datetime(2024, 1, 1)

with open("productionprocess.csv", mode="w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow([
        "processid_", "type_", "startdate_", "enddate_", 
        "seqnumber", "grapeid", "employeeid", "batchnumber_"
    ])

    process_id = 1
    for batch in range(1, 101):  # 100 batches, כל אחד יקבל 4 תהליכים
        batch_start = start_date + timedelta(days=random.randint(0, 100))
        batchnumber = random.randint(1, 400)  # מתוך טבלת finalproduct_

        for seq in range(1, 5):  # 4 שלבים לכל batch
            type_ = seq  # לדוגמה: 1=תסיסה, 2=סינון, ...
            start = batch_start + timedelta(days=(seq - 1) * 5)
            end = start + timedelta(days=random.randint(1, 3))

            grapeid = random.randint(1, 10)
            employeeid = random.randint(1, 50)

            writer.writerow([
                process_id, type_, start.date(), end.date(), 
                seq, grapeid, employeeid, batchnumber
            ])
            process_id += 1
