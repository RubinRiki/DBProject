import csv
import random

with open("process_materials.csv", mode="w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow(["usageamount", "processid_", "materialid_"])

    used_pairs = set()

    while len(used_pairs) < 400:
        processid = random.randint(1, 400)        # מתוך טבלת productionprocess_
        materialid = random.randint(1, 10)         # חומרים בין 1 ל־10 בלבד
        key = (processid, materialid)
        if key not in used_pairs:
            usage = random.randint(1, 100)         # כמות שימוש אקראית
            writer.writerow([usage, processid, materialid])
            used_pairs.add(key)
