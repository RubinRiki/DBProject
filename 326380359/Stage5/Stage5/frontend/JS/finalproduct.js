const API = "http://localhost:3001/api/finalproducts";

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
const productIdInput = document.getElementById("productid");

let selectedBatch = null;
let productToDelete = null;

openFormBtn.addEventListener("click", () => {
  resetForm();
  selectedBatch = null;
  document.getElementById("formTitle").textContent = "Add Product";
  formModal.classList.remove("hidden");
});

cancelBtn.addEventListener("click", () => {
  formModal.classList.add("hidden");
});

cancelDelete.addEventListener("click", () => {
  deleteModal.classList.add("hidden");
});

confirmDelete.addEventListener("click", async () => {
  if (productToDelete !== null) {
    await fetch(`${API}/${productToDelete}`, { method: "DELETE" });
    productToDelete = null;
    deleteModal.classList.add("hidden");
    loadProducts();
  }
});

productForm.addEventListener("submit", async (e) => {
  e.preventDefault();

  const product = {
    qntityofbottle: parseFloat(qntityInput.value),
    batchnumber_: parseInt(batchInput.value),
    winetype_: wineTypeInput.value,
    bottlingdate_: bottlingDateInput.value,
    numbottls: parseInt(bottlesInput.value),
    productid: productIdInput.value || null,
  };

  await fetch(API, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(product),
  });

  formModal.classList.add("hidden");
  loadProducts();
});

function resetForm() {
  qntityInput.value = "";
  batchInput.value = "";
  wineTypeInput.value = "";
  bottlingDateInput.value = "";
  bottlesInput.value = "";
  productIdInput.value = "";
}

function promptDelete(batchnumber) {
  productToDelete = batchnumber;
  deleteModal.classList.remove("hidden");
}

async function loadProducts() {
  const res = await fetch(API);
  const data = await res.json();

  const tableBody = document.getElementById("productTableBody");
  tableBody.innerHTML = "";

  data.forEach(product => {
    const row = document.createElement("tr");
    row.innerHTML = `
      <td>${product.qntityofbottle}</td>
      <td>${product.batchnumber_}</td>
      <td>${product.winetype_}</td>
      <td>${product.bottlingdate_ ? new Date(product.bottlingdate_).toLocaleDateString() : ''}</td>
      <td>${product.numbottls}</td>
      <td>${product.productid ?? ''}</td>
      <td>
        <button class="delete-btn" onclick="promptDelete(${product.batchnumber_})">Delete</button>
      </td>
    `;
    tableBody.appendChild(row);
  });
}

document.addEventListener("DOMContentLoaded", loadProducts);
