document.addEventListener("DOMContentLoaded", () => {

const API = "http://localhost:3001/api/finalproducts";

// Elements
const formModal = document.getElementById("formModal");
const deleteModal = document.getElementById("deleteModal");
const openFormBtn = document.getElementById("openFormBtn");
const productForm = document.getElementById("productForm");
const cancelBtn = document.getElementById("cancelBtn");
const confirmDelete = document.getElementById("confirmDelete");
const cancelDelete = document.getElementById("cancelDelete");

const qntityInput = document.getElementById("qntityofbottle");
const batchInput = document.getElementById("batchnumber_");
const wineTypeInput = document.getElementById("winetype_");
const bottlingDateInput = document.getElementById("bottlingdate_");
const bottlesInput = document.getElementById("numbottls");

const formTitle = document.getElementById("formTitle");
const tableBody = document.getElementById("productTableBody");

let selectedBatch = null;
let productToDelete = null;

openFormBtn.addEventListener("click", () => {
  resetForm();
  selectedBatch = null;
  formTitle.textContent = "Add Product";
  formModal.classList.remove("hidden");
});

cancelBtn.addEventListener("click", () => {
  formModal.classList.add("hidden");
  resetForm();
});

cancelDelete.addEventListener("click", () => {
  deleteModal.classList.add("hidden");
});

confirmDelete.addEventListener("click", async () => {
  if (productToDelete !== null) {
    try {
      const res = await fetch(`${API}/${productToDelete}`, { method: "DELETE" });
      if (!res.ok) throw new Error("Failed to delete product");
      loadProducts();
    } catch (error) {
      alert("Error deleting product: " + error.message);
    } finally {
      productToDelete = null;
      deleteModal.classList.add("hidden");
    }
  }
});

productForm.addEventListener("submit", async (e) => {
  e.preventDefault();

  const product = {
    quntityofbottle: parseFloat(qntityInput.value),
    winetype_: wineTypeInput.value,
    bottlingdate_: bottlingDateInput.value,
    numbottls: parseInt(bottlesInput.value)
  };

  const method = selectedBatch === null ? "POST" : "PUT";
  const url = selectedBatch === null ? API : `${API}/${selectedBatch}`;

  try {
    const res = await fetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(product),
    });

    if (!res.ok) {
      const errorText = await res.text();
      throw new Error("Server error: " + errorText);
    }

    formModal.classList.add("hidden");
    resetForm();
    loadProducts();
  } catch (error) {
    alert("Error saving product: " + error.message);
  }
});

function resetForm() {
  qntityInput.value = "";
  batchInput.value = "";
  wineTypeInput.value = "";
  bottlingDateInput.value = "";
  bottlesInput.value = "";
  batchInput.disabled = false;
}

function promptDelete(batchnumber) {
  productToDelete = batchnumber;
  deleteModal.classList.remove("hidden");
}

async function editProduct(batchnumber) {
  try {
    const res = await fetch(`${API}/${batchnumber}`);
    if (!res.ok) throw new Error("Failed to fetch product data");

    const product = await res.json();

    qntityInput.value = product.quntityofbottle;
    batchInput.value = product.batchnumber_;
    wineTypeInput.value = product.winetype_;
    bottlingDateInput.value = product.bottlingdate_?.split("T")[0] || "";
    bottlesInput.value = product.numbottls;

    batchInput.disabled = true;
    selectedBatch = batchnumber;
    formTitle.textContent = "Edit Product";
    formModal.classList.remove("hidden");
  } catch (error) {
    alert("Error loading product for edit: " + error.message);
  }
}

async function loadProducts() {
  try {
    const res = await fetch(API);
    if (!res.ok) throw new Error("Failed to load products");

    const data = await res.json();
    tableBody.innerHTML = "";

    data.forEach(product => {
      const row = document.createElement("tr");

      const editBtn = document.createElement("button");
      editBtn.className = "edit-btn";
      editBtn.textContent = "Edit";
      editBtn.addEventListener("click", () => editProduct(product.batchnumber_));

      const deleteBtn = document.createElement("button");
      deleteBtn.className = "delete-btn";
      deleteBtn.textContent = "Delete";
      deleteBtn.addEventListener("click", () => promptDelete(product.batchnumber_));

      const tdActions = document.createElement("td");
      tdActions.appendChild(editBtn);
      tdActions.appendChild(deleteBtn);

      row.innerHTML = `
        <td>${product.quntityofbottle}</td>
        <td>${product.batchnumber_}</td>
        <td>${product.winetype_}</td>
        <td>${product.bottlingdate_ ? new Date(product.bottlingdate_).toLocaleDateString() : ''}</td>
        <td>${product.numbottls}</td>
      `;
      row.appendChild(tdActions);
      tableBody.appendChild(row);
    });
  } catch (error) {
    alert("Error loading products: " + error.message);
  }
}
loadProducts();
});
