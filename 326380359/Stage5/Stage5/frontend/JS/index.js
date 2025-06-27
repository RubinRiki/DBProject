document.addEventListener("DOMContentLoaded", () => {
  // גרף עוגה – Wine Types
  const wineCtx = document.getElementById("wineChart").getContext("2d");
  new Chart(wineCtx, {
    type: "pie",
    data: {
      labels: ["Merlot", "Cabernet", "Syrah", "Chardonnay"],
      datasets: [{
        label: "Bottles",
        data: [120, 80, 45, 60],
        backgroundColor: ["#8e24aa", "#5e35b1", "#3949ab", "#039be5"]
      }]
    },
    options: {
      responsive: true
    }
  });

  // גרף עמודות – סטטיסטיקה כללית
  const overviewCtx = document.getElementById("overviewChart").getContext("2d");
  new Chart(overviewCtx, {
    type: "bar",
    data: {
      labels: ["Employees", "Wine Types", "Processes", "Orders"],
      datasets: [{
        label: "Count",
        data: [9, 4, 6, 3],
        backgroundColor: "#26a69a"
      }]
    },
    options: {
      scales: {
        y: {
          beginAtZero: true,
          ticks: { stepSize: 1 }
        }
      },
      responsive: true
    }
  });
});
