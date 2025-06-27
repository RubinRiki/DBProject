document.addEventListener("DOMContentLoaded", () => {
  const API = "http://localhost:3001/api/employees";

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

  let selectedId = null;
  let employeeToDelete = null;

  openFormBtn.addEventListener("click", () => {
    resetForm();
    selectedId = null;
    document.getElementById("formTitle").textContent = "Add Employee";
    formModal.classList.remove("hidden");
  });

  cancelBtn.addEventListener("click", () => {
    formModal.classList.add("hidden");
  });

  cancelDelete.addEventListener("click", () => {
    deleteModal.classList.add("hidden");
  });

  confirmDelete.addEventListener("click", async () => {
    if (employeeToDelete !== null) {
      await fetch(`${API}/${employeeToDelete}`, { method: "DELETE" });
      employeeToDelete = null;
      deleteModal.classList.add("hidden");
      loadEmployees();
    }
  });

  employeeForm.addEventListener("submit", async (e) => {
    e.preventDefault();

    const emp = {
      employeename: nameInput.value,
      hiredate: hiredateInput.value,
      roleid: parseInt(roleInput.value),
    };

    if (selectedId) {
      await fetch(`${API}/${selectedId}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(emp),
      });
    } else {
      await fetch(API, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(emp),
      });
    }

    formModal.classList.add("hidden");
    loadEmployees();
  });

  function resetForm() {
    nameInput.value = "";
    hiredateInput.value = "";
    roleInput.value = "";
  }

  window.editEmployee = function (id, name, hiredate, roleid) {
    selectedId = id;
    nameInput.value = name;
    hiredateInput.value = hiredate;
    roleInput.value = roleid;
    document.getElementById("formTitle").textContent = "Edit Employee";
    formModal.classList.remove("hidden");
  }

  window.promptDelete = function (id) {
    employeeToDelete = id;
    deleteModal.classList.remove("hidden");
  }

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
        <td>
          <button class="edit-btn" onclick="editEmployee(${emp.employeeid}, ${JSON.stringify(emp.employeename)}, '${emp.hiredate}', ${emp.roleid})">Edit</button>
          <button class="delete-btn" onclick="promptDelete(${emp.employeeid})">Delete</button>
        </td>
      `;
      tableBody.appendChild(row);
    });
  }

  loadEmployees();
});
