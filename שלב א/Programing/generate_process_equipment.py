import csv
import random

with open("process_equipment.csv", mode="w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow(["equipmentid_", "processid_"])

    used_pairs = set()

    while len(used_pairs) < 1000:
        processid = random.randint(1, 400)
        equipmentid = random.randint(1, 40)
        pair = (equipmentid, processid)
        if pair not in used_pairs:
            writer.writerow([equipmentid, processid])
            used_pairs.add(pair)
