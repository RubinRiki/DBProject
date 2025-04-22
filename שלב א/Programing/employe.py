import random

roles_with_weights = {
    'mgr': 1,     # Manager
    'lead': 3,    # Lead
    'qa': 2,      # QA
    'tech': 6,    # Technician
    'op': 15,     # Operator
    'wrk': 10,    # Worker
    'clean': 5,   # Cleaner
    'lab': 4,     # Lab
    'mnt': 4      # Maintenance (קוצר ל-mnt כדי שיהיה עד 6 תווים)
}

first_names = [
    'Noam', 'Lior', 'Dana', 'Shai', 'Omer', 'Yael', 'Amit', 'Itay', 'Tamar',
    'Neta', 'Ron', 'Gal', 'Eden', 'Avi', 'Lena', 'Yoni', 'Eli', 'Sarit', 'Tal', 'Maya'
]

def choose_weighted_role():
    flat_list = [role for role, count in roles_with_weights.items() for _ in range(count)]
    return random.choice(flat_list)

with open("insert_employee.sql", "w") as f:
    f.write("CREATE TABLE employee (\n")
    f.write("  employeeid INT PRIMARY KEY,\n")
    f.write("  role VARCHAR(6),\n")
    f.write("  name VARCHAR(10)\n")
    f.write(");\n\n")

    for i in range(1, 51):
        emp_id = i
        name = random.choice(first_names)
        role = choose_weighted_role()
        f.write(f"INSERT INTO employee (employeeid, role, name) VALUES ({emp_id}, '{role}', '{name}');\n")
