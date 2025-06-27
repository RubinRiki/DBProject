const API = "http://localhost:3001/api/production";

const formModal = document.getElementById("formModal");
const deleteModal = document.getElementById("deleteModal");
const openFormBtn = document.getElementById("openFormBtn");
const productionForm = document.getElementById("productionForm");
const cancelBtn = document.getElementById("cancelBtn");
const confirmDelete = document.getElementById("confirmDelete");
const cancelDelete = document.getElementById("cancelDelete");

const typeInput = document.getElementById("typeInput");
const seqInput = document.getElementById("seqInput");
const grapeIdInput = document.getElementById("grapeIdInput");
const employeeIdInput = document.getElementById("employeeIdInput");
const batchNumInput = document.getElementById("batchNumInput");
const startDateInput = document.getElementById("startDateInput");
const endDateInput = document.getElementById("endDateInput");

let selectedId = null;
let processToDelete = null;

openFormBtn.addEventListener("click", () => {
  resetForm();
  formModal.classList.remove("hidden");
});

cancelBtn.addEventListener("click", () => {
  formModal.classList.add("hidden");
});

cancelDelete.addEventListener("click", () => {
  deleteModal.classList.add("hidden");
});

confirmDelete.addEventListener("click", async () => {
  if (processToDelete !== null) {
    await fetch(`${API}/${processToDelete}`, { method: "DELETE" });
    deleteModal.classList.add("hidden");
    loadProcesses();
  }
});

productionForm.addEventListener("submit", async (e) => {
  e.preventDefault();

  const process = {
    type_: Number(typeInput.value),
    seqnumber: Number(seqInput.value),
    grapeid: Number(grapeIdInput.value),
    employeeid: Number(employeeIdInput.value),
    batchnumber_: Number(batchNumInput.value),
    startdate_: startDateInput.value,
    enddate_: endDateInput.value || null,
  };

  await fetch(API, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(process),
  });

  formModal.classList.add("hidden");
  loadProcesses();
});

function resetForm() {
  typeInput.value = "";
  seqInput.value = "";
  grapeIdInput.value = "";
  employeeIdInput.value = "";
  batchNumInput.value = "";
  startDateInput.value = "";
  endDateInput.value = "";
}

function promptDelete(id) {
  processToDelete = id;
  deleteModal.classList.remove("hidden");
}

async function loadProcesses() {
  const res = await fetch(API);
  const data = await res.json();

  const tbody = document.getElementById("processTableBody");
  tbody.innerHTML = "";

  data.forEach((p) => {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${p.processid_}</td>
      <td>${p.type_}</td>
      <td>${p.seqnumber}</td>
      <td>${p.grapeid}</td>
      <td>${p.employeeid}</td>
      <td>${p.batchnumber_}</td>
      <td>${p.startdate_?.slice(0, 10)}</td>
      <td>${p.enddate_ ? p.enddate_.slice(0, 10) : ""}</td>
      <td>
        <button class="delete-btn" onclick="promptDelete(${p.processid_})">Delete</button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

document.addEventListener("DOMContentLoaded", loadProcesses);
