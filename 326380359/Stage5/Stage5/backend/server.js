const express = require("express");
const cors = require("cors");
const pool = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

/* ================================
   EMPLOYEES (employee_merge)
================================== */

// SELECT
app.get("/api/employees", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM employee_merge");
    res.json(result.rows);
  } catch (err) {
    console.error("Error", err);
    res.status(500).send("Failed to fetch employees");
  }
});

// INSERT
app.post("/api/employees", async (req, res) => {
  const { employeeid, employeename, hiredate, roleid } = req.body;
  try {
    await pool.query(
      "INSERT INTO employee_merge (employeename, hiredate, roleid) VALUES ($1, $2, $3)",
      [employeename, hiredate, roleid]
    );
    res.send("Employee added");
  } catch (err) {
     console.error("Error", err);
    res.status(500).send("Failed to add employee");
  }
});
// GET
app.get("/api/employees/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query("SELECT * FROM employee_merge WHERE employeeid = $1", [id]);
    if (result.rows.length === 0) {
      return res.status(404).send("Employee not found");
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error("Error", err);
    res.status(500).send("Failed to fetch employee");
  }
});


// UPDATE
app.put("/api/employees/:id", async (req, res) => {
  const { id } = req.params;
  const { employeename, hiredate, roleid } = req.body;
  try {
    await pool.query(
      "UPDATE employee_merge SET employeename=$1, hiredate=$2, roleid=$3 WHERE employeeid=$4",
      [employeename, hiredate, roleid, id]
    );
    res.send("Employee updated");
  } catch (err) {
    console.error("Error", err);
    res.status(500).send("Failed to update employee");
  }
});

// DELETE
app.delete("/api/employees/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query("DELETE FROM employee_merge WHERE employeeid = $1", [id]);
    res.send("Employee deleted");
  } catch (err) {
    console.error("Error", err);
    res.status(500).send("Failed to delete employee");
  }
});


/* ================================
   FINAL PRODUCTS (finalproduct_)
================================== */

// GET all final products
app.get("/api/finalproducts", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT batchnumber_, quntityofbottle, winetype_, bottlingdate_, numbottls
      FROM finalproduct_
      ORDER BY batchnumber_
    `);
    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching final products:", err);
    res.status(500).send("Failed to fetch final products");
  }
});

// GET single product by batch number
app.get("/api/finalproducts/:batchnumber", async (req, res) => {
  const { batchnumber } = req.params;
  try {
    const result = await pool.query(`
      SELECT batchnumber_, quntityofbottle, winetype_, bottlingdate_, numbottls
      FROM finalproduct_
      WHERE batchnumber_ = $1
    `, [batchnumber]);

    if (result.rows.length === 0) {
      return res.status(404).send("Final product not found");
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error("Error fetching final product:", err);
    res.status(500).send("Failed to fetch final product");
  }
});

// POST new final product
app.post("/api/finalproducts", async (req, res) => {
  const {
    quntityofbottle,
    winetype_,
    bottlingdate_,
    numbottls
  } = req.body;

  try {
    await pool.query(`
      INSERT INTO finalproduct_ (quntityofbottle, winetype_, bottlingdate_, numbottls)
      VALUES ($1, $2, $3, $4)
    `, [quntityofbottle, winetype_, bottlingdate_, numbottls]);

    res.status(201).send("Final product added");
  } catch (err) {
    console.error("Error adding final product:", err);
    res.status(500).send("Failed to add final product");
  }
});

// PUT update existing final product
app.put("/api/finalproducts/:batchnumber", async (req, res) => {
  const { batchnumber } = req.params;
  const {
    quntityofbottle,
    winetype_,
    bottlingdate_,
    numbottls
  } = req.body;

  try {
    const result = await pool.query(`
      UPDATE finalproduct_
      SET quntityofbottle = $1,
          winetype_ = $2,
          bottlingdate_ = $3,
          numbottls = $4
      WHERE batchnumber_ = $5
    `, [quntityofbottle, winetype_, bottlingdate_, numbottls, batchnumber]);

    if (result.rowCount === 0) {
      return res.status(404).send("Final product not found to update");
    }

    res.send("Final product updated");
  } catch (err) {
    console.error("Error updating final product:", err);
    res.status(500).send("Failed to update final product");
  }
});

// DELETE final product
app.delete("/api/finalproducts/:batchnumber", async (req, res) => {
  const { batchnumber } = req.params;
  try {
    const result = await pool.query(
      "DELETE FROM finalproduct_ WHERE batchnumber_ = $1",
      [batchnumber]
    );

    if (result.rowCount === 0) {
      return res.status(404).send("Final product not found to delete");
    }

    res.send("Final product deleted");
  } catch (err) {
    console.error("Error deleting final product:", err);
    res.status(500).send("Failed to delete final product");
  }
});

/* ================================
   PRODUCTION PROCESSES (productionprocess_)
================================== */

// GET all production processes
app.get("/api/production", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM productionprocess_ ORDER BY processid_");
    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching production processes:", err);
    res.status(500).send("Failed to fetch production processes");
  }
});

// GET single process by ID
app.get("/api/production/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      "SELECT * FROM productionprocess_ WHERE processid_ = $1",
      [id]
    );
    if (result.rows.length === 0) {
      return res.status(404).send("Process not found");
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error("Error fetching process:", err);
    res.status(500).send("Failed to fetch process");
  }
});

// GET available batches (less than 4 types)
app.get("/api/available-batches", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT batchnumber_
      FROM finalproduct_
      WHERE batchnumber_ NOT IN (
        SELECT batchnumber_
        FROM productionprocess_
        GROUP BY batchnumber_
        HAVING COUNT(DISTINCT type_) = 4
      )
    `);
    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching available batches:", err);
    res.status(500).send("Failed to fetch batches");
  }
});

// GET grapes for dropdown
app.get("/api/grapes", async (req, res) => {
  try {
    const result = await pool.query("SELECT grapeid, variety FROM grapes ORDER BY grapeid");
    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching grapes:", err);
    res.status(500).send("Failed to fetch grapes");
  }
});

// POST new production process (create)
app.post("/api/production", async (req, res) => {
  const {
    type_,
    seqnumber,
    grapeid,
    employeeid,
    batchnumber_,
    startdate_,
    enddate_
  } = req.body;

  try {
    // Check if the same type already exists for this batch
    const exists = await pool.query(
      `SELECT 1 FROM productionprocess_
       WHERE batchnumber_ = $1 AND type_ = $2`,
      [batchnumber_, type_]
    );

    if (exists.rows.length > 0) {
      return res.status(400).send("A process of this type already exists for the selected batch");
    }

    // Count how many distinct types already exist for this batch
    const typeCount = await pool.query(
      `SELECT COUNT(DISTINCT type_) AS count
       FROM productionprocess_
       WHERE batchnumber_ = $1`,
      [batchnumber_]
    );

    if (typeCount.rows[0].count >= 4) {
      return res.status(400).send("Cannot add more than 4 different types for this batch");
    }

    // Insert new process
    await pool.query(
      `INSERT INTO productionprocess_
       (type_, seqnumber, grapeid, employeeid, batchnumber_, startdate_, enddate_)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [type_, seqnumber, grapeid, employeeid, batchnumber_, startdate_, enddate_]
    );

    res.status(201).send("Production process added successfully");
  } catch (err) {
    console.error("Error adding process:", err);
    res.status(500).send("Failed to add production process");
  }
});

// PUT update dates only (edit)
app.put("/api/production/:id", async (req, res) => {
  const { id } = req.params;
  const { startdate_, enddate_ } = req.body;

  try {
    const result = await pool.query(
      `UPDATE productionprocess_
       SET startdate_ = $1, enddate_ = $2
       WHERE processid_ = $3`,
      [startdate_, enddate_, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).send("Process not found");
    }

    res.send("Process dates updated successfully");
  } catch (err) {
    console.error("Error updating process:", err);
    res.status(500).send("Failed to update process");
  }
});

// DELETE process
app.delete("/api/production/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      "DELETE FROM productionprocess_ WHERE processid_ = $1",
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).send("Process not found");
    }

    res.send("Production process deleted successfully");
  } catch (err) {
    console.error("Error deleting process:", err);
    res.status(500).send("Failed to delete process");
  }
});

app.post("/api/production/check-duplicate", async (req, res) => {
  const { type_, batchnumber_ } = req.body;

  if (type_ == null || batchnumber_ == null) {
    return res.status(400).json({ error: "Missing fields" });
  }

  try {
    const result = await pool.query(
      `SELECT 1 FROM productionprocess_ WHERE type_ = $1 AND batchnumber_ = $2 LIMIT 1`,
      [type_, batchnumber_]
    );

    res.json({ exists: result.rows.length > 0 });
  } catch (err) {
    console.error("Error checking duplicate:", err);
    res.status(500).json({ error: "Database error" });
  }
});

// GET /api/production/by-batch/:batchId
app.get("/api/production/by-batch/:batchId", async (req, res) => {
  const batchId = parseInt(req.params.batchId, 10);
  if (isNaN(batchId)) {
    return res.status(400).json({ error: "Invalid batch ID" });
  }

  try {
    const query = `
      SELECT * FROM productionprocess_
      WHERE batchnumber_ = $1
    `;
    const result = await pool.query(query, [batchId]);
    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching batch processes:", err);
    res.status(500).json({ error: "Server error fetching batch processes" });
  }
});


  // DELETE all processes by batch number (when there are 4 types)
app.delete("/api/production/by-batch/:batchnumber", async (req, res) => {
  const batchnumber = parseInt(req.params.batchnumber, 10);
  if (isNaN(batchnumber)) {
    return res.status(400).json({ error: "Invalid batch number" });
  }

  try {
    const result = await pool.query(
      "DELETE FROM productionprocess_ WHERE batchnumber_ = $1",
      [batchnumber]
    );

    res.status(204).send(); // success, no content
  } catch (err) {
    console.error("Error deleting by batch:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});


/* ================================
   SPECIAL QUERIES (UNCHANGED)
================================== */

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
    console.error("Error", err);
    res.status(500).send("Failed to fetch summary");
  }
});

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
    console.error("Error", err);
    res.status(500).send("Failed to fetch bottle count");
  }
});

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
    console.error("Error", err);
    res.status(500).send("Failed to run procedure");
  }
});

/* ================================
   SERVER START
================================== */

app.listen(3001, () => {
  console.log("Server is running on http://localhost:3001");
});
