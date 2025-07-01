
document.addEventListener("DOMContentLoaded", () => {
  const API = "http://localhost:3001/api/production";

  // DOM references
  const formModal = document.getElementById("formModal");
  const deleteModal = document.getElementById("deleteModal");
  const form = document.getElementById("productionForm");
  const formTitle = document.getElementById("formTitle");
  const tableBody = document.getElementById("productionTableBody");

  const inputs = {
    type: document.getElementById("typeInput"),
    grapeId: document.getElementById("grapeIdInput"),
    employeeId: document.getElementById("employeeIdInput"),
    batchNum: document.getElementById("batchNumInput"),
    startDate: document.getElementById("startDateInput"),
    endDate: document.getElementById("endDateInput")
  };

  let selectedId = null;
  let deleteIds = null;

  // Event Listeners
  document.getElementById("openFormBtn").onclick = async () => {
    resetForm();
    formTitle.textContent = "Add Production Process";
    formModal.classList.remove("hidden");
    await loadAvailableBatches();
    await loadAvailableGrapes();
  };

  document.getElementById("cancelBtn").onclick = () => {
    formModal.classList.add("hidden");
    resetForm();
  };

  document.getElementById("cancelDelete").onclick = () => {
    deleteModal.classList.add("hidden");
  };

  document.getElementById("confirmDelete").onclick = performDeletion;

  form.onsubmit = async (e) => {
    e.preventDefault();
    const process = buildProcessObject();

    if (!isValid(process)) return alert("Please fill in all required fields correctly.");

    if (!selectedId && await isDuplicate(process)) return alert("This batch already has a process of the selected type.");

    try {
      const res = await fetch(selectedId ? `${API}/${selectedId}` : API, {
        method: selectedId ? "PUT" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(process)
      });

      if (!res.ok) throw new Error(await res.text());

      formModal.classList.add("hidden");
      resetForm();
      loadProcesses();
    } catch (err) {
      alert("Error saving: " + err.message);
    }
  };

  async function promptDelete(id) {
    try {
      const res = await fetch(`${API}/${id}`);
      const process = await res.json();
      const batchRes = await fetch(`${API}/by-batch/${process.batchnumber_}`);
      const all = await batchRes.json();

      const types = new Set(all.map(p => p.type_));
      const confirmText = types.size === 4 ?
        "There are 4 process types for this batch. Delete ALL of them?" :
        "Are you sure you want to delete this process?";

      if (!confirm(confirmText)) return;

      deleteIds = types.size === 4 ? all.map(p => p.processid_) : [id];
      deleteModal.classList.remove("hidden");
    } catch (err) {
      alert("Error preparing deletion: " + err.message);
    }
  }

  async function performDeletion() {
    if (!deleteIds) return;
    try {
      for (const id of deleteIds) {
        const res = await fetch(`${API}/${id}`, { method: "DELETE" });
        if (!res.ok) throw new Error(`Failed to delete process ${id}`);
      }
      alert("Deleted successfully.");
      loadProcesses();
    } catch (err) {
      alert("Error during deletion: " + err.message);
    } finally {
      deleteIds = null;
      deleteModal.classList.add("hidden");
    }
  }

  async function editProcess(id) {
    try {
      const res = await fetch(`${API}/${id}`);
      const process = await res.json();
      selectedId = id;

      Object.assign(inputs, {
        type: { value: process.type_ },
        grapeId: { innerHTML: `<option selected>${process.grapeid}</option>` },
        employeeId: { value: process.employeeid },
        batchNum: { innerHTML: `<option value="${process.batchnumber_}" selected>${process.batchnumber_}</option>` },
        startDate: { value: process.startdate_.split("T")[0] },
        endDate: { value: process.enddate_ ? process.enddate_.split("T")[0] : "" }
      });

      ["type", "grapeId", "employeeId", "batchNum"].forEach(k => inputs[k].disabled = true);
      formTitle.textContent = "Edit Production Process";
      formModal.classList.remove("hidden");
    } catch (err) {
      alert("Error loading process: " + err.message);
    }
  }

  function buildProcessObject() {
    return {
      type_: parseInt(inputs.type.value),
      seqnumber: parseInt(inputs.type.value),
      grapeid: parseInt(inputs.grapeId.value),
      employeeid: parseInt(inputs.employeeId.value),
      batchnumber_: parseInt(inputs.batchNum.value),
      startdate_: inputs.startDate.value,
      enddate_: inputs.endDate.value || null
    };
  }

  function isValid(p) {
    return p.type_ >= 1 && !isNaN(p.grapeid) && !isNaN(p.employeeid) && !isNaN(p.batchnumber_) && p.startdate_;
  }

  async function isDuplicate(p) {
    const res = await fetch(`${API}/check-duplicate`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ type_: p.type_, batchnumber_: p.batchnumber_ })
    });
    const { exists } = await res.json();
    return exists;
  }

  function resetForm() {
    selectedId = null;
    for (let key in inputs) {
      if (["grapeId", "batchNum"].includes(key)) {
        inputs[key].innerHTML = `<option value="" disabled selected>Select ${key}</option>`;
      } else {
        inputs[key].value = "";
      }
      inputs[key].disabled = false;
    }
  }

  async function loadAvailableBatches() {
    try {
      const res = await fetch("http://localhost:3001/api/available-batches");
      const batches = await res.json();
      inputs.batchNum.innerHTML = '<option value="" disabled selected>Select Batch</option>';
      batches.forEach(b => {
        const opt = new Option(b.batchnumber_, b.batchnumber_);
        inputs.batchNum.appendChild(opt);
      });
    } catch (err) {
      alert("Error loading batches: " + err.message);
    }
  }

  async function loadAvailableGrapes() {
    try {
      const res = await fetch("http://localhost:3001/api/grapes");
      const grapes = await res.json();
      inputs.grapeId.innerHTML = '<option value="" disabled selected>Select Grape</option>';
      grapes.forEach(g => {
        const opt = new Option(g.name || `Grape ${g.grapeid}`, g.grapeid);
        inputs.grapeId.appendChild(opt);
      });
    } catch (err) {
      alert("Error loading grapes: " + err.message);
    }
  }

  async function loadProcesses() {
    try {
      const res = await fetch(API);
      const data = await res.json();
      tableBody.innerHTML = "";

      data.forEach(proc => {
        const row = document.createElement("tr");
        row.innerHTML = `
          <td>${proc.processid_}</td>
          <td>${proc.type_}</td>
          <td>${proc.grapeid}</td>
          <td>${proc.employeeid}</td>
          <td>${proc.batchnumber_}</td>
          <td>${proc.startdate_ ? new Date(proc.startdate_).toLocaleDateString() : ""}</td>
          <td>${proc.enddate_ ? new Date(proc.enddate_).toLocaleDateString() : ""}</td>`;

        const tdActions = document.createElement("td");
        tdActions.append(...["Edit", "Delete"].map(txt => {
          const btn = document.createElement("button");
          btn.textContent = txt;
          btn.className = `${txt.toLowerCase()}-btn`;
          btn.onclick = () => txt === "Edit" ? editProcess(proc.processid_) : promptDelete(proc.processid_);
          return btn;
        }));

        row.appendChild(tdActions);
        tableBody.appendChild(row);
      });
    } catch (err) {
      alert("Error loading processes: " + err.message);
    }
  }

  loadProcesses();
});
