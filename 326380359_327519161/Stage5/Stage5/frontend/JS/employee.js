document.addEventListener("DOMContentLoaded", () => {
  const API = "http://localhost:3001/api/employees";

  // === DOM Elements ===
  const formModal = document.getElementById("formModal");
  const deleteModal = document.getElementById("deleteModal");
  const openFormBtn = document.getElementById("openFormBtn");
  const employeeForm = document.getElementById("employeeForm");
  const cancelBtn = document.getElementById("cancelBtn");
  const confirmDelete = document.getElementById("confirmDelete");
  const cancelDelete = document.getElementById("cancelDelete");
  const nameInput = document.getElementById("name");
  const hiredateInput = document.getElementById("hiredate");
  const roleInput = document.getElementById("role");
  const tableBody = document.getElementById("employeeTableBody");

  // === State ===
  let selectedId = null;
  let employeeToDelete = null;

  // === Event Listeners ===
  openFormBtn.addEventListener("click", () => {
    resetForm();
    selectedId = null;
    document.getElementById("formTitle").textContent = "Add Employee";
    formModal.classList.remove("hidden");
  });

  cancelBtn.addEventListener("click", () => formModal.classList.add("hidden"));
  cancelDelete.addEventListener("click", () => deleteModal.classList.add("hidden"));

  confirmDelete.addEventListener("click", async () => {
    if (!employeeToDelete) return;

    try {
      const res = await fetch(`${API}/${employeeToDelete}`, { method: "DELETE" });

      if (res.status === 500) {
        alert("⚠️ Cannot delete employee due to production links.");
      } else if (res.ok) {
        employeeToDelete = null;
        deleteModal.classList.add("hidden");
        loadEmployees();
      } else {
        alert("Delete failed with status " + res.status);
      }
    } catch (err) {
      console.error("Server error:", err);
    }
  });

  employeeForm.addEventListener("submit", async (e) => {
    e.preventDefault();

    const emp = {
      employeename: nameInput.value,
      hiredate: hiredateInput.value,
      roleid: parseInt(roleInput.value),
    };

    const method = selectedId ? "PUT" : "POST";
    const url = selectedId ? `${API}/${selectedId}` : API;

    await fetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(emp),
    });

    formModal.classList.add("hidden");
    loadEmployees();
  });

  // === Helpers ===
  function resetForm() {
    nameInput.value = "";
    hiredateInput.value = "";
    roleInput.value = "";
  }

 async function editEmployee(id) {
  try {
    const res = await fetch(`${API}/${id}`);
    if (!res.ok) throw new Error("Failed to fetch employee data");

    const emp = await res.json();

    selectedId = id;
    nameInput.value = emp.employeename;
    hiredateInput.value = emp.hiredate?.split("T")[0] || "";
    roleInput.value = emp.roleid;

    document.getElementById("formTitle").textContent = "Edit Employee";
    formModal.classList.remove("hidden");
  } catch (err) {
    alert("Error loading employee: " + err.message);
  }
 }


  function openDeleteModal(id) {
    employeeToDelete = id;
    deleteModal.classList.remove("hidden");
  }

  async function loadEmployees() {
    const res = await fetch(API);
    const data = await res.json();
    tableBody.innerHTML = "";

    data.forEach(emp => {
      const row = document.createElement("tr");

      const editBtn = document.createElement("button");
      editBtn.className = "edit-btn";
      editBtn.textContent = "Edit";
      editBtn.addEventListener("click", () => editEmployee(emp.employeeid));


      const deleteBtn = document.createElement("button");
      deleteBtn.className = "delete-btn";
      deleteBtn.textContent = "Delete";
      deleteBtn.addEventListener("click", () => openDeleteModal(emp.employeeid));

      const tdActions = document.createElement("td");
      tdActions.appendChild(editBtn);
      tdActions.appendChild(deleteBtn);

      row.innerHTML = `
        <td>${emp.employeeid}</td>
        <td>${emp.employeename}</td>
        <td>${emp.hiredate ? new Date(emp.hiredate).toLocaleDateString() : ''}</td>
        <td>${emp.roleid}</td>
      `;
      row.appendChild(tdActions);
      tableBody.appendChild(row);
    });
  }

  loadEmployees();
});
