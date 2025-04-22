import csv
import random

with open("process_containers.csv", mode="w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow(["containerid_", "processid_"])

    used_pairs = set()

    while len(used_pairs) < 1000:
        containerid = random.randint(1, 400)
        processid = random.randint(1, 400)
        pair = (containerid, processid)
        if pair not in used_pairs:
            writer.writerow([containerid, processid])
            used_pairs.add(pair)
