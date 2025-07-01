const { Pool } = require("pg");

const pool = new Pool({
  user: "riki",
  host: "localhost",
  database: "mydatabase", // כאן נכניס את שם בסיס הנתונים
  password: "1234", // ופה תכניסי את הסיסמה שלך (אם יש)
  port: 5432,
});


module.exports = pool;
