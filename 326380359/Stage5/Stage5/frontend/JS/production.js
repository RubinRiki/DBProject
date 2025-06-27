// JS/production.js
const API = "http://localhost:3001/api/production";

// פתיחת / סגירת הטופס
document.getElementById("openFormBtn").addEventListener("click", () => {
  document.getElementById("formWrapper").classList.toggle("hidden");
});

// טעינת הדף
document.addEventListener("DOMContentLoaded", () => {
  loadProcesses();

  // שליחת הטופס
  document
    .getElementById("productionForm")
    .addEventListener("submit", async (e) => {
      e.preventDefault();

      // איסוף ערכים מהטופס – בדיוק לפי שמות העמודות ב-PG
      const process = {
        type_:        Number(document.getElementById("typeInput").value),
        seqnumber:    Number(document.getElementById("seqInput").value),
        grapeid:      Number(document.getElementById("grapeIdInput").value),
        employeeid:   Number(document.getElementById("employeeIdInput").value),
        batchnumber_: Number(document.getElementById("batchNumInput").value),
        startdate_:   document.getElementById("startDateInput").value,
        enddate_:     document.getElementById("endDateInput").value || null
      };

      await fetch(API, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(process)
      });

      loadProcesses();
      e.target.reset();
      document.getElementById("formWrapper").classList.add("hidden");
    });
});

// שליפת כל התהליכים
async function loadProcesses() {
  const res  = await fetch(API);
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
      <td>${p.startdate_.slice(0,10)}</td>
      <td>${p.enddate_ ? p.enddate_.slice(0,10) : ""}</td>
      <td>
        <button class="action-btn delete-btn" onclick="deleteProcess(${p.processid_})">
          Delete
        </button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

// מחיקה
async function deleteProcess(id) {
  await fetch(`${API}/${id}`, { method: "DELETE" });
  loadProcesses();
}
