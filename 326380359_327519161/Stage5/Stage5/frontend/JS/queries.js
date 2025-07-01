const API = "http://localhost:3001/api";

document.addEventListener("DOMContentLoaded", () => {
  //Query 1 – Update winetype_ by grape variety
  document.getElementById("runUpdateWineType").addEventListener("click", async () => {
    try {
      const res = await fetch(`${API}/update-winetype`, { method: "POST" });
      if (!res.ok) throw new Error(await res.text());
      const msg = await res.text();
      alert(msg || "Wine types updated successfully.");
    } catch (err) {
      alert("Error running update query: " + err.message);
    }
  });

  // Query 2 – Total bottles by grape variety
  document.getElementById("runBottleSummary").addEventListener("click", async () => {
    try {
      const res = await fetch(`${API}/bottle-summary`);
      if (!res.ok) throw new Error(await res.text());
      const data = await res.json();

      const resultBox = document.getElementById("bottleSummaryResult");
      resultBox.innerHTML = data.map(row =>
        `<strong>${row.variety}</strong>: ${row.total_bottles} bottles`
      ).join("<br>");
    } catch (err) {
      alert("Error fetching bottle summary: " + err.message);
    }
  });

  // Function – Get total bottles by wine type
  document.getElementById("runBottleCountFunction").addEventListener("click", async () => {
    const type = document.getElementById("wineTypeInput").value.trim();
    if (!type) return alert("Please enter a wine type.");

    try {
      const res = await fetch(`${API}/bottle-count?type=${encodeURIComponent(type)}`);
      if (!res.ok) throw new Error(await res.text());
      const data = await res.json();
      document.getElementById("bottleCountResult").innerText = `Total: ${data.count} bottles.`;
    } catch (err) {
      alert("Error fetching bottle count: " + err.message);
    }
  });

  // Procedure – Increase prices by supplier
  document.getElementById("runPriceUpdateProc").addEventListener("click", async () => {
    const supplier = document.getElementById("supplierNameInput").value.trim();
    const percent = document.getElementById("percentInput").value.trim();

    if (!supplier || !percent) {
      return alert("Please enter both supplier name and percent.");
    }

    try {
      const res = await fetch(`${API}/increase-prices`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ supplier, percent })
      });
      if (!res.ok) throw new Error(await res.text());
      const msg = await res.text();
      alert(msg || "Prices updated successfully.");
    } catch (err) {
      alert("Error running procedure: " + err.message);
    }
  });
});
