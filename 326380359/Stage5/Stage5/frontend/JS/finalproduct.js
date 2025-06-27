const API = "http://localhost:3001/api/finalproducts";

document.getElementById("openFormBtn").addEventListener("click", () => {
  document.getElementById("formWrapper").classList.toggle("hidden");
});

document.addEventListener("DOMContentLoaded", () => {
  loadProducts();

  document.getElementById("productForm").addEventListener("submit", async (e) => {
    e.preventDefault();

    const product = {
      qntityofbottle: parseFloat(document.getElementById("qntityofbottle").value),
      batchnumber_: parseInt(document.getElementById("batchnumber_").value),
      winetype_: document.getElementById("winetype_").value,
      bottlingdate_: document.getElementById("bottlingdate_").value,
      numbottls: parseInt(document.getElementById("numbottls").value),
      productid: document.getElementById("productid").value || null,
    };

    await fetch(API, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(product),
    });

    loadProducts();
    e.target.reset();
  });
});

async function loadProducts() {
  const res = await fetch(API);
  const data = await res.json();

  const tableBody = document.getElementById("productTableBody");
  tableBody.innerHTML = "";

  data.forEach(product => {
    const row = document.createElement("tr");
    row.innerHTML = `
      <td>${product.quntityofbottle}</td>
      <td>${product.batchnumber_}</td>
      <td>${product.winetype_}</td>
      <td>${product.bottlingdate_ ? new Date(product.bottlingdate_).toLocaleDateString() : ''}</td>
      <td>${product.numbottls}</td>
      <td>${product.productid ?? ''}</td>
      <td><button class="delete-btn" onclick="deleteProduct(${product.batchnumber_})">Delete</button></td>
    `;
    tableBody.appendChild(row);
  });
}


async function deleteProduct(batchnumber) {
  await fetch(`${API}/${batchnumber}`, { method: "DELETE" });
  loadProducts();
}
