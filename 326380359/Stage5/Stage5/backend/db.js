const { Pool } = require("pg");

const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "minip", // כאן נכניס את שם בסיס הנתונים
  password: "a327519161", // ופה תכניסי את הסיסמה שלך (אם יש)
  port: 5432,
});


module.exports = pool;
