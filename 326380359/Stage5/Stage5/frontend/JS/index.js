document.addEventListener("DOMContentLoaded", async () => {
  const colors = getComputedStyle(document.documentElement);

  const wineColors = [
    colors.getPropertyValue('--color-merlot').trim(),
    colors.getPropertyValue('--color-cabernet').trim(),
    colors.getPropertyValue('--color-syrah').trim(),
    colors.getPropertyValue('--color-chardonnay').trim()
  ];

  // --- Fetch data from server ---
  const [employeesRes, productsRes, processesRes] = await Promise.all([
    fetch("http://localhost:3001/api/employees"),
    fetch("http://localhost:3001/api/finalproducts"),
    fetch("http://localhost:3001/api/production")
  ]);

  const employees = await employeesRes.json();
  const products = await productsRes.json();
  const processes = await processesRes.json();

  // --- Count wine types ---
  const wineCounts = {
    Merlot: 0,
    Cabernet: 0,
    Syrah: 0,
    Chardonnay: 0
  };

  products.forEach(p => {
    const type = p.winetype_;
    if (wineCounts[type] !== undefined) {
      wineCounts[type]++;
    }
  });

  console.log("Wine counts:", wineCounts);

  // --- Count unique wine types for overview ---
  const uniqueTypes = new Set(products.map(p => p.winetype_));

  // --- Overview data ---
  const overviewData = [
    employees.length,
    uniqueTypes.size,
    processes.length,
    0 // Orders – if you add later
  ];

  // --- Pie Chart: Wine Types ---
  const wineCtx = document.getElementById("wineChart").getContext("2d");
  new Chart(wineCtx, {
    type: "pie",
    data: {
      labels: Object.keys(wineCounts),
      datasets: [{
        label: "Bottles",
        data: Object.values(wineCounts),
        backgroundColor: wineColors
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: {
          labels: {
            color: "#f5f5f5",
            font: { family: "Lora" }
          }
        }
      }
    }
  });

  // --- Bar Chart: System Overview ---
  const overviewCtx = document.getElementById("overviewChart").getContext("2d");
  new Chart(overviewCtx, {
    type: "bar",
    data: {
      labels: ["Employees", "Wine Types", "Processes", "Orders"],
      datasets: [{
        label: "Count",
        data: overviewData,
        backgroundColor: colors.getPropertyValue('--color-merlot').trim()
      }]
    },
    options: {
      responsive: true,
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            stepSize: 1,
            color: "#f5f5f5",
            font: { family: "Lora" }
          },
          grid: { color: "#f5f5f5" }
        },
        x: {
          ticks: {
            color: "#f5f5f5",
            font: { family: "Lora" }
          },
          grid: { color: "#f5f5f5" }
        }
      },
      plugins: {
        legend: {
          labels: {
            color: "#f5f5f5",
            font: { family: "Lora" }
          }
        }
      }
    }
  });
});
