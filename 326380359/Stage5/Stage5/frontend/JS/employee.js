const API = "http://localhost:3001/api/employees";

document.getElementById("openFormBtn").addEventListener("click", () => {
  document.getElementById("formWrapper").classList.toggle("hidden");
});

document.addEventListener("DOMContentLoaded", () => {
  loadEmployees();

  document.getElementById("employeeForm").addEventListener("submit", async (e) => {
    e.preventDefault();

    const emp = {
      employeename: document.getElementById("name").value,
      roleid: parseInt(document.getElementById("role").value),
      hiredate: document.getElementById("hiredate").value,
    };

    await fetch(API, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(emp),
    });

    loadEmployees();
    e.target.reset();
  });
});

async function loadEmployees() {
  const res = await fetch(API);
  const data = await res.json();

  const tableBody = document.getElementById("employeeTableBody");
  tableBody.innerHTML = "";

  data.forEach(emp => {
    const row = document.createElement("tr");
    row.innerHTML = `
      <td>${emp.employeeid}</td>
      <td>${emp.employeename}</td>
      <td>${emp.hiredate ? new Date(emp.hiredate).toLocaleDateString() : ''}</td>
      <td>${emp.roleid}</td>
      <td><button class="delete-btn" onclick="deleteEmployee(${emp.employeeid})">Delete</button></td>
    `;
    tableBody.appendChild(row);
  });
}

async function deleteEmployee(id) {
  await fetch(`${API}/${id}`, { method: "DELETE" });
  loadEmployees();
}
