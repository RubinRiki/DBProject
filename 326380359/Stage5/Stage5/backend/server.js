// server.js

const express = require("express");
const cors = require("cors");
const pool = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

// ✅ Grapes
app.get("/api/grapes", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM grapes");
    res.json(result.rows);
  } catch (err) {
    res.status(500).send("Failed to fetch grapes");
  }
});

// ✅ Employees
app.get("/api/employees", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM employee_local");
    res.json(result.rows);
} catch (err) {
  console.error('PG error:', err);   // <-- הדפסה
  res.status(500).send("Failed to fetch employees");
}

});

app.post("/api/employees", async (req, res) => {
  const { name, role, startdate } = req.body;
  try {
    await pool.query(
      "INSERT INTO employee_local (name, role, startdate) VALUES ($1, $2, $3)",
      [name, role, startdate]
    );
    res.send("Employee added");
  } catch (err) {
    res.status(500).send("Failed to add employee");
  }
});

// ✅ Final Products
app.get("/api/finalproducts", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM finalproduct_");
    res.json(result.rows);
  } catch (err) {
    res.status(500).send("Failed to fetch final products");
  }
});

// ✅ Production Processes
app.get("/api/production", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM productionprocess_");
    res.json(result.rows);
  } catch (err) {
    res.status(500).send("Failed to fetch production processes");
  }
});

// ✅ Queries – Update winetype_
app.post("/api/update-winetype", async (req, res) => {
  try {
    await pool.query(`
      UPDATE finalproduct_
      SET winetype_ = (
        SELECT gv.name
        FROM productionprocess_ p
        JOIN grapes g ON p.grapeid = g.grapeid
        JOIN grape_varieties gv ON g.variety = gv.id
        WHERE p.batchnumber_ = finalproduct_.batchnumber_
        LIMIT 1
      )
      WHERE batchnumber_ IN (
        SELECT batchnumber_
        FROM productionprocess_
        GROUP BY batchnumber_
        HAVING COUNT(DISTINCT type_) = 4
      )
    `);
    res.send("winetype_ column updated");
  } catch (err) {
    res.status(500).send("Failed to run update query");
  }
});

// ✅ Queries – Bottle summary
app.get("/api/bottle-summary", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT g.variety, SUM(fp.numbottls) AS total_bottles
      FROM grapes g
      JOIN productionprocess_ pp ON pp.grapeid = g.grapeid
      JOIN finalproduct_ fp ON fp.batchnumber_ = pp.batchnumber_
      GROUP BY g.variety
      ORDER BY total_bottles DESC
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).send("Failed to fetch summary");
  }
});

// ✅ Function – get_bottle_count_by_type
app.get("/api/bottle-count", async (req, res) => {
  const type = req.query.type;
  try {
    const result = await pool.query(`
      SELECT COALESCE(SUM(numbottls), 0) AS count
      FROM finalproduct_
      WHERE winetype_ = $1
    `, [type]);
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).send("Failed to fetch bottle count");
  }
});

// ✅ Procedure – increase_prices_by_supplier
app.post("/api/increase-prices", async (req, res) => {
  const { supplier, percent } = req.body;
  try {
    await pool.query(`
      UPDATE product_local
      SET price = price * (1 + $2 / 100.0)
      WHERE productid IN (
        SELECT oi.productid
        FROM orderitems_local oi
        JOIN orders_local o ON oi.orderid = o.orderid
        JOIN supplier_local s ON o.supplierid = s.supplierid
        WHERE s.suppliername = $1
      )
    `, [supplier, percent]);
    res.send("Prices updated successfully");
  } catch (err) {
    res.status(500).send("Failed to run procedure");
  }
});

// ✅ Start the server
app.listen(3001, () => {
  console.log("Server is running on http://localhost:3001");
});
