--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Debian 17.4-1.pgdg120+2)
-- Dumped by pg_dump version 17.2

-- Started on 2025-05-27 10:35:25

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 57619)
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


--
-- TOC entry 258 (class 1255 OID 90423)
-- Name: add_material_if_not_exists(integer, character varying, double precision, integer); Type: PROCEDURE; Schema: public; Owner: riki
--

CREATE PROCEDURE public.add_material_if_not_exists(IN mat_id integer, IN mat_name character varying, IN quantity double precision, IN supplier_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
  existing_material RECORD;
BEGIN
  SELECT * INTO existing_material FROM materials_ WHERE materialid_ = mat_id;

  IF NOT FOUND THEN
    INSERT INTO materials_ (materialid_, name_, quantityavailable_, supplierid_)
    VALUES (mat_id, mat_name, quantity, supplier_id);
    RAISE NOTICE 'New material added: %, Quantity: %', mat_name, quantity;
  ELSE
    RAISE NOTICE 'Material already exists: %', existing_material.name_;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error while adding material: %', SQLERRM;
END;
$$;


ALTER PROCEDURE public.add_material_if_not_exists(IN mat_id integer, IN mat_name character varying, IN quantity double precision, IN supplier_id integer) OWNER TO riki;

--
-- TOC entry 255 (class 1255 OID 90420)
-- Name: get_bottle_count_by_type(character varying); Type: FUNCTION; Schema: public; Owner: riki
--

CREATE FUNCTION public.get_bottle_count_by_type(winetype_input character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
  bottle_count INTEGER := 0;
  cur CURSOR FOR 
    SELECT numbottls 
    FROM finalproduct_ 
    WHERE winetype_ = winetype_input;
BEGIN
  OPEN cur;

  LOOP
    FETCH cur INTO rec;
    EXIT WHEN NOT FOUND;

    IF rec.numbottls IS NOT NULL THEN
      bottle_count := bottle_count + rec.numbottls;
    END IF;
  END LOOP;

  CLOSE cur;

  RAISE NOTICE 'Total bottles for %: %', winetype_input, bottle_count;
  RETURN bottle_count;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error in function: %', SQLERRM;
    RETURN -1;
END;
$$;


ALTER FUNCTION public.get_bottle_count_by_type(winetype_input character varying) OWNER TO riki;

--
-- TOC entry 256 (class 1255 OID 90421)
-- Name: get_orders_by_supplier(character varying); Type: FUNCTION; Schema: public; Owner: riki
--

CREATE FUNCTION public.get_orders_by_supplier(supplier_name_input character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
  orders_cursor refcursor;
BEGIN
  OPEN orders_cursor FOR
    SELECT o.orderid, o.orderdate
    FROM orders_local o
    JOIN supplier_local s ON o.supplierid = s.supplierid
    WHERE s.suppliername = supplier_name_input;

  RETURN orders_cursor;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error in get_orders_by_supplier: %', SQLERRM;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.get_orders_by_supplier(supplier_name_input character varying) OWNER TO riki;

--
-- TOC entry 257 (class 1255 OID 90422)
-- Name: increase_prices_by_supplier(character varying, numeric); Type: PROCEDURE; Schema: public; Owner: riki
--

CREATE PROCEDURE public.increase_prices_by_supplier(IN supplier_name_input character varying, IN percent_increase numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
  prod RECORD;
  updated_count INTEGER := 0;
BEGIN
  FOR prod IN
    SELECT p.productid, p.price
    FROM product_local p
    JOIN orders_local o ON o.supplierid = (SELECT supplierid FROM supplier_local WHERE suppliername = supplier_name_input)
    JOIN orderitems_local oi ON o.orderid = oi.orderid AND oi.productid = p.productid
  LOOP
    UPDATE product_local
    SET price = price * (1 + percent_increase / 100)
    WHERE productid = prod.productid;

    updated_count := updated_count + 1;
    RAISE NOTICE 'Updated product %: new price set', prod.productid;
  END LOOP;

  RAISE NOTICE 'Total products updated: %', updated_count;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error during price update: %', SQLERRM;
END;
$$;


ALTER PROCEDURE public.increase_prices_by_supplier(IN supplier_name_input character varying, IN percent_increase numeric) OWNER TO riki;

--
-- TOC entry 272 (class 1255 OID 90429)
-- Name: update_bottling_date_if_completed(); Type: FUNCTION; Schema: public; Owner: riki
--

CREATE FUNCTION public.update_bottling_date_if_completed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  process_type_count INT;
BEGIN
  -- בדיקה כמה סוגי תהליך שונים בוצעו עבור האצווה
  SELECT COUNT(DISTINCT Type_) INTO process_type_count
  FROM ProductionProcess_
  WHERE BatchNumber_ = NEW.BatchNumber_;

  -- אם בוצעו כל 4 הסוגים - נעדכן את BottlingDate
  IF process_type_count = 4 THEN
    UPDATE FinalProduct_
    SET BottlingDate_ = NOW()
    WHERE BatchNumber_ = NEW.BatchNumber_;

    RAISE NOTICE 'All 4 process types completed. BottlingDate updated for batch %', NEW.BatchNumber_;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_bottling_date_if_completed() OWNER TO riki;

--
-- TOC entry 259 (class 1255 OID 90424)
-- Name: update_last_updated(); Type: FUNCTION; Schema: public; Owner: riki
--

CREATE FUNCTION public.update_last_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.last_updated := NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_last_updated() OWNER TO riki;

--
-- TOC entry 260 (class 1255 OID 90426)
-- Name: validate_material_quantity(); Type: FUNCTION; Schema: public; Owner: riki
--

CREATE FUNCTION public.validate_material_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.quantityavailable_ < 0 THEN
    RAISE EXCEPTION 'Cannot insert material with negative quantity';
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_material_quantity() OWNER TO riki;

--
-- TOC entry 2178 (class 1417 OID 57626)
-- Name: satge3_server; Type: SERVER; Schema: -; Owner: riki
--

CREATE SERVER satge3_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'satge3',
    host 'localhost',
    port '5432'
);


ALTER SERVER satge3_server OWNER TO riki;

--
-- TOC entry 3587 (class 0 OID 0)
-- Name: USER MAPPING riki SERVER satge3_server; Type: USER MAPPING; Schema: -; Owner: riki
--

CREATE USER MAPPING FOR riki SERVER satge3_server OPTIONS (
    password '1234',
    "user" 'riki'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 40961)
-- Name: containers_; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.containers_ (
    containerid_ integer NOT NULL,
    type_ integer,
    capacityl_ double precision
);


ALTER TABLE public.containers_ OWNER TO riki;

--
-- TOC entry 219 (class 1259 OID 40964)
-- Name: employee; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.employee (
    employeeid integer NOT NULL,
    role character varying(6),
    name character varying(10) NOT NULL
);


ALTER TABLE public.employee OWNER TO riki;

--
-- TOC entry 238 (class 1259 OID 65921)
-- Name: employee_local; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.employee_local (
    employeeid numeric(5,0) NOT NULL,
    employeename character varying(15),
    hiredate date,
    roleid numeric(3,0)
);


ALTER TABLE public.employee_local OWNER TO riki;

--
-- TOC entry 246 (class 1259 OID 66016)
-- Name: employee_merge; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.employee_merge (
    employeeid integer NOT NULL,
    employeename text NOT NULL,
    hiredate date,
    roleid integer
);


ALTER TABLE public.employee_merge OWNER TO riki;

--
-- TOC entry 245 (class 1259 OID 66015)
-- Name: employee_merge_employeeid_seq; Type: SEQUENCE; Schema: public; Owner: riki
--

CREATE SEQUENCE public.employee_merge_employeeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_merge_employeeid_seq OWNER TO riki;

--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 245
-- Name: employee_merge_employeeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: riki
--

ALTER SEQUENCE public.employee_merge_employeeid_seq OWNED BY public.employee_merge.employeeid;


--
-- TOC entry 234 (class 1259 OID 57660)
-- Name: employee_stage3; Type: FOREIGN TABLE; Schema: public; Owner: riki
--

CREATE FOREIGN TABLE public.employee_stage3 (
    employeeid integer,
    employeename character varying(100),
    hiredate date,
    roleid integer
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'employee'
);


ALTER FOREIGN TABLE public.employee_stage3 OWNER TO riki;

--
-- TOC entry 220 (class 1259 OID 40967)
-- Name: finalproduct_; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.finalproduct_ (
    quntityofbottle double precision,
    batchnumber_ integer NOT NULL,
    winetype_ character varying(30),
    bottlingdate_ date,
    numbottls integer NOT NULL,
    productid integer,
    CONSTRAINT check_positive_bottles CHECK ((numbottls >= 0))
);


ALTER TABLE public.finalproduct_ OWNER TO riki;

--
-- TOC entry 228 (class 1259 OID 41052)
-- Name: grape_varieties; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.grape_varieties (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.grape_varieties OWNER TO riki;

--
-- TOC entry 221 (class 1259 OID 40970)
-- Name: grapes; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.grapes (
    grapeid integer NOT NULL,
    variety integer,
    harvestdate_ date
);


ALTER TABLE public.grapes OWNER TO riki;

--
-- TOC entry 222 (class 1259 OID 40973)
-- Name: materials_; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.materials_ (
    materialid_ integer NOT NULL,
    name_ character varying(10),
    supplierid_ integer,
    quantityavailable_ double precision
);


ALTER TABLE public.materials_ OWNER TO riki;

--
-- TOC entry 242 (class 1259 OID 65941)
-- Name: orderitems_local; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.orderitems_local (
    orderid numeric(5,0),
    productid numeric(5,0),
    quantity numeric(5,0),
    supplierprice numeric(5,2)
);


ALTER TABLE public.orderitems_local OWNER TO riki;

--
-- TOC entry 233 (class 1259 OID 57649)
-- Name: orderitems_stage3; Type: FOREIGN TABLE; Schema: public; Owner: riki
--

CREATE FOREIGN TABLE public.orderitems_stage3 (
    orderid integer,
    productid integer,
    quantity integer,
    supplierprice double precision
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'orderitems'
);


ALTER FOREIGN TABLE public.orderitems_stage3 OWNER TO riki;

--
-- TOC entry 247 (class 1259 OID 74072)
-- Name: ordermaterials; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.ordermaterials (
    orderid integer NOT NULL,
    materialid integer NOT NULL,
    quantity integer NOT NULL,
    supplierprice numeric(10,2) NOT NULL
);


ALTER TABLE public.ordermaterials OWNER TO riki;

--
-- TOC entry 241 (class 1259 OID 65936)
-- Name: orders_local; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.orders_local (
    orderid numeric(5,0) NOT NULL,
    orderdate date,
    paymentterms character varying(15),
    supplierid numeric(5,0)
);


ALTER TABLE public.orders_local OWNER TO riki;

--
-- TOC entry 232 (class 1259 OID 57646)
-- Name: orders_stage3; Type: FOREIGN TABLE; Schema: public; Owner: riki
--

CREATE FOREIGN TABLE public.orders_stage3 (
    orderid integer,
    orderdate date,
    paymentterms character varying(100),
    supplierid integer
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'orders'
);


ALTER FOREIGN TABLE public.orders_stage3 OWNER TO riki;

--
-- TOC entry 223 (class 1259 OID 40976)
-- Name: process_equipment; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.process_equipment (
    equipmentid_ integer NOT NULL,
    processid_ integer NOT NULL
);


ALTER TABLE public.process_equipment OWNER TO riki;

--
-- TOC entry 224 (class 1259 OID 40979)
-- Name: process_materials; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.process_materials (
    usageamount integer,
    processid_ integer NOT NULL,
    materialid_ integer NOT NULL
);


ALTER TABLE public.process_materials OWNER TO riki;

--
-- TOC entry 225 (class 1259 OID 40982)
-- Name: processcontainers; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.processcontainers (
    containerid_ integer NOT NULL,
    processid_ integer NOT NULL
);


ALTER TABLE public.processcontainers OWNER TO riki;

--
-- TOC entry 240 (class 1259 OID 65931)
-- Name: product_local; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.product_local (
    productid numeric(5,0) NOT NULL,
    productname character varying(15),
    price numeric(5,2),
    brand character varying(15),
    stockquantity numeric(5,0),
    last_updated timestamp without time zone
);


ALTER TABLE public.product_local OWNER TO riki;

--
-- TOC entry 229 (class 1259 OID 57628)
-- Name: product_stage3; Type: FOREIGN TABLE; Schema: public; Owner: riki
--

CREATE FOREIGN TABLE public.product_stage3 (
    productid integer,
    productname character varying(100),
    price double precision,
    brand character varying(100),
    stockquantity integer
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'product'
);


ALTER FOREIGN TABLE public.product_stage3 OWNER TO riki;

--
-- TOC entry 226 (class 1259 OID 40985)
-- Name: productionequipment_; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.productionequipment_ (
    equipmentid_ integer NOT NULL,
    type_ character(10),
    status_ character varying(10)
);


ALTER TABLE public.productionequipment_ OWNER TO riki;

--
-- TOC entry 227 (class 1259 OID 40988)
-- Name: productionprocess_; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.productionprocess_ (
    processid_ integer NOT NULL,
    type_ integer,
    startdate_ date,
    enddate_ date,
    seqnumber integer,
    grapeid integer,
    employeeid integer,
    batchnumber_ integer
);


ALTER TABLE public.productionprocess_ OWNER TO riki;

--
-- TOC entry 243 (class 1259 OID 65944)
-- Name: purchase_local; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.purchase_local (
    purchaseid numeric(5,0) NOT NULL,
    purchasedate date,
    paymentmethod character varying(15),
    employeeid integer
);


ALTER TABLE public.purchase_local OWNER TO riki;

--
-- TOC entry 236 (class 1259 OID 65913)
-- Name: purchase_stage3; Type: FOREIGN TABLE; Schema: public; Owner: riki
--

CREATE FOREIGN TABLE public.purchase_stage3 (
    purchaseid numeric(5,0),
    purchasedate character varying(15),
    paymentmethod character varying(15),
    employeeid numeric(5,0)
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'purchase'
);


ALTER FOREIGN TABLE public.purchase_stage3 OWNER TO riki;

--
-- TOC entry 244 (class 1259 OID 65949)
-- Name: purchaseitems_local; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.purchaseitems_local (
    purchaseid numeric(5,0),
    productid numeric(5,0),
    quantity numeric(5,0)
);


ALTER TABLE public.purchaseitems_local OWNER TO riki;

--
-- TOC entry 235 (class 1259 OID 65910)
-- Name: purchaseitems_stage3; Type: FOREIGN TABLE; Schema: public; Owner: riki
--

CREATE FOREIGN TABLE public.purchaseitems_stage3 (
    purchaseid numeric(5,0),
    productid numeric(5,0),
    quantity numeric(5,0)
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'purchaseitems'
);


ALTER FOREIGN TABLE public.purchaseitems_stage3 OWNER TO riki;

--
-- TOC entry 237 (class 1259 OID 65916)
-- Name: role_local; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.role_local (
    roleid numeric(3,0) NOT NULL,
    rolename character varying(15),
    hourlywage numeric(5,2)
);


ALTER TABLE public.role_local OWNER TO riki;

--
-- TOC entry 231 (class 1259 OID 57643)
-- Name: role_stage3; Type: FOREIGN TABLE; Schema: public; Owner: riki
--

CREATE FOREIGN TABLE public.role_stage3 (
    roleid integer,
    rolename character varying(50),
    hourlywage double precision
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'role'
);


ALTER FOREIGN TABLE public.role_stage3 OWNER TO riki;

--
-- TOC entry 239 (class 1259 OID 65926)
-- Name: supplier_local; Type: TABLE; Schema: public; Owner: riki
--

CREATE TABLE public.supplier_local (
    supplierid numeric(5,0) NOT NULL,
    suppliername character varying(15),
    phone character varying(10)
);


ALTER TABLE public.supplier_local OWNER TO riki;

--
-- TOC entry 230 (class 1259 OID 57637)
-- Name: supplier_stage3; Type: FOREIGN TABLE; Schema: public; Owner: riki
--

CREATE FOREIGN TABLE public.supplier_stage3 (
    supplierid integer,
    suppliername character varying(100),
    phone character varying(20)
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'supplier'
);


ALTER FOREIGN TABLE public.supplier_stage3 OWNER TO riki;

--
-- TOC entry 249 (class 1259 OID 82233)
-- Name: view_order_supplier_summary; Type: VIEW; Schema: public; Owner: riki
--

CREATE VIEW public.view_order_supplier_summary AS
 SELECT o.orderid,
    o.orderdate,
    s.suppliername
   FROM (public.orders_local o
     JOIN public.supplier_local s ON ((o.supplierid = s.supplierid)));


ALTER VIEW public.view_order_supplier_summary OWNER TO riki;

--
-- TOC entry 248 (class 1259 OID 82228)
-- Name: view_production_bottling_summary; Type: VIEW; Schema: public; Owner: riki
--

CREATE VIEW public.view_production_bottling_summary AS
 SELECT pp.processid_,
    pp.startdate_,
    fp.batchnumber_,
    fp.winetype_,
    fp.numbottls,
    c.capacityl_ AS container_capacity
   FROM (((public.productionprocess_ pp
     JOIN public.finalproduct_ fp ON ((pp.batchnumber_ = fp.batchnumber_)))
     JOIN public.processcontainers pc ON ((pp.processid_ = pc.processid_)))
     JOIN public.containers_ c ON ((pc.containerid_ = c.containerid_)));


ALTER VIEW public.view_production_bottling_summary OWNER TO riki;

--
-- TOC entry 3345 (class 2604 OID 66019)
-- Name: employee_merge employeeid; Type: DEFAULT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.employee_merge ALTER COLUMN employeeid SET DEFAULT nextval('public.employee_merge_employeeid_seq'::regclass);


--
-- TOC entry 3559 (class 0 OID 40961)
-- Dependencies: 218
-- Data for Name: containers_; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.containers_ (containerid_, type_, capacityl_) FROM stdin;
1	4	787
2	7	76
3	9	763
4	10	253
5	9	574
6	4	894
7	2	839
8	8	634
9	10	367
10	9	248
11	8	21
12	10	498
13	6	896
14	6	177
15	8	1
16	8	249
17	4	660
18	7	213
19	6	737
20	5	451
21	3	549
22	3	605
23	4	603
24	2	729
25	7	872
26	5	274
27	6	979
28	3	853
29	3	711
30	4	502
31	10	538
32	7	42
33	6	754
34	8	829
35	2	437
36	1	343
37	2	149
38	7	913
39	9	312
40	9	398
41	6	482
42	9	469
43	6	753
44	5	585
45	10	797
46	7	460
47	9	377
48	4	41
49	1	673
50	9	186
51	2	761
52	6	385
53	10	296
54	1	49
55	8	791
56	8	223
57	9	1000
58	7	821
59	2	11
60	2	171
61	8	763
62	2	776
63	3	394
64	6	438
65	4	673
66	3	566
67	3	928
68	7	574
69	1	560
70	5	22
71	10	341
72	9	646
73	5	415
74	1	702
75	5	223
76	10	373
77	10	647
78	2	550
79	6	296
80	5	932
81	6	216
82	10	847
83	8	452
84	4	25
85	7	514
86	8	10
87	5	599
88	4	391
89	10	932
90	2	463
91	3	232
92	2	869
93	3	289
94	7	396
95	6	325
96	3	260
97	7	520
98	7	678
99	8	132
100	6	425
101	1	215
102	10	402
103	6	15
104	5	938
105	5	955
106	2	769
107	2	962
108	1	355
109	8	676
110	3	214
111	6	968
112	10	877
113	1	974
114	5	323
115	7	678
116	9	486
117	4	941
118	9	342
119	1	566
120	2	409
121	7	553
122	10	978
123	3	741
124	3	673
125	4	506
126	9	147
127	7	784
128	7	376
129	8	478
130	7	414
131	7	106
132	9	264
133	3	631
134	8	371
135	2	424
136	8	608
137	8	974
138	3	361
139	7	722
140	10	394
141	7	846
142	9	402
143	7	65
144	8	93
145	3	82
146	7	33
147	4	604
148	8	306
149	4	908
150	6	862
151	1	951
152	6	848
153	9	322
154	2	438
155	3	853
156	2	844
157	1	83
158	4	936
159	2	39
160	8	55
161	5	823
162	6	776
163	6	146
164	4	118
165	9	589
166	3	323
167	3	555
168	1	869
169	3	402
170	6	464
171	5	613
172	5	170
173	2	436
174	5	393
175	4	727
176	7	341
177	3	237
178	5	252
179	3	688
180	7	43
181	1	55
182	10	315
183	2	582
184	10	131
185	3	181
186	8	729
187	6	677
188	7	723
189	2	197
190	9	80
191	6	236
192	7	300
193	8	223
194	5	331
195	9	605
196	1	585
197	1	536
198	4	664
199	3	740
200	2	373
201	9	983
202	5	665
203	10	16
204	6	487
205	10	673
206	6	710
207	4	54
208	3	673
209	7	553
210	3	244
211	4	215
212	1	519
213	4	851
214	6	661
215	7	305
216	8	469
217	3	738
218	6	141
219	1	703
220	9	543
221	5	650
222	9	356
223	6	455
224	3	949
225	9	562
226	10	820
227	7	989
228	1	82
229	8	814
230	5	167
231	6	849
232	3	561
233	9	938
234	4	318
235	1	698
236	10	668
237	8	54
238	3	162
239	3	783
240	10	859
241	6	472
242	2	574
243	4	858
244	4	493
245	1	7
246	8	359
247	7	992
248	10	49
249	2	656
250	1	8
251	2	517
252	3	647
253	10	675
254	9	889
255	7	804
256	7	995
257	3	571
258	9	809
259	6	305
260	10	506
261	7	650
262	1	59
263	5	651
264	9	109
265	6	818
266	2	600
267	7	56
268	6	706
269	1	368
270	10	807
271	5	760
272	9	85
273	9	196
274	2	347
275	3	123
276	6	934
277	10	890
278	4	142
279	4	360
280	6	596
281	10	306
282	1	351
283	5	726
284	4	712
285	5	254
286	8	890
287	6	125
288	9	677
289	10	877
290	7	16
291	4	232
292	1	324
293	6	937
294	4	792
295	8	911
296	5	745
297	8	574
298	6	26
299	9	744
300	1	315
301	7	953
302	1	167
303	3	150
304	9	19
305	6	454
306	7	552
307	10	74
308	4	521
309	3	691
310	10	250
311	1	89
312	4	45
313	9	742
314	5	283
315	1	583
316	7	196
317	3	490
318	4	264
319	6	797
320	9	132
321	7	484
322	4	481
323	6	186
324	10	821
325	10	184
326	10	47
327	1	745
328	1	989
329	4	421
330	9	7
331	1	318
332	5	602
333	5	959
334	3	410
335	4	778
336	6	986
337	5	860
338	2	47
339	2	217
340	1	67
341	4	394
342	5	741
343	9	794
344	9	807
345	2	329
346	1	146
347	2	831
348	5	97
349	9	110
350	9	303
351	2	575
352	7	576
353	4	393
354	6	323
355	7	703
356	8	557
357	4	171
358	10	189
359	8	966
360	8	99
361	2	226
362	1	84
363	8	30
364	6	990
365	8	211
366	2	507
367	2	138
368	5	806
369	8	296
370	3	369
371	4	230
372	6	152
373	4	866
374	7	683
375	8	423
376	3	808
377	4	458
378	8	267
379	7	192
380	9	988
381	9	363
382	4	184
383	4	275
384	5	965
385	6	720
386	4	185
387	9	6
388	5	945
389	7	748
390	9	286
391	8	223
392	7	879
393	8	23
394	9	928
395	8	534
396	6	318
397	1	823
398	7	95
399	4	338
400	2	288
401	3	674
402	5	674
403	1	91
404	7	80
405	5	787
406	6	552
407	6	288
408	7	168
409	3	896
410	5	503
411	6	478
412	4	866
413	7	888
414	7	541
415	9	847
416	1	193
417	8	837
418	10	398
419	2	252
420	1	889
421	1	646
422	2	383
423	2	337
424	5	800
425	2	940
426	5	482
427	1	385
428	1	540
429	6	227
430	10	709
431	5	234
432	10	93
433	4	958
434	1	90
435	8	108
436	5	958
437	1	223
438	9	860
439	10	814
440	6	561
441	10	7
442	10	609
443	5	709
444	9	127
445	9	54
446	9	89
447	8	163
448	9	1000
449	8	260
450	3	985
451	1	479
452	3	124
453	5	711
454	4	694
455	8	839
456	5	568
457	9	786
458	4	678
459	8	358
460	6	698
461	3	987
462	3	318
463	10	747
464	3	729
465	10	927
466	2	784
467	6	235
468	3	178
469	1	969
470	10	549
471	2	788
472	10	41
473	3	411
474	6	530
475	1	511
476	9	903
477	6	76
478	8	454
479	5	549
480	10	755
481	3	418
482	9	200
483	8	160
484	5	385
485	3	15
486	1	206
487	3	930
488	3	642
489	5	675
490	6	795
491	4	539
492	1	643
493	1	779
494	7	874
495	2	606
496	3	240
497	9	837
498	8	87
499	2	476
500	1	330
501	3	783
502	3	191
503	5	370
504	9	790
505	10	203
506	9	215
507	4	512
508	5	477
509	9	777
510	4	207
511	1	624
512	7	783
513	2	163
514	1	440
515	9	427
516	3	907
517	5	482
518	1	323
519	5	259
520	1	960
521	2	792
522	2	415
523	5	673
524	3	674
525	6	646
526	5	828
527	6	529
528	2	122
529	8	269
530	2	479
531	1	985
532	4	497
533	2	9
534	10	508
535	2	284
536	8	971
537	6	804
538	9	681
539	4	423
540	5	992
541	9	966
542	9	158
543	4	604
544	5	786
545	5	395
546	3	709
547	8	617
548	1	753
549	10	407
550	3	401
551	9	461
552	8	179
553	5	401
554	9	871
555	9	972
556	4	831
557	5	105
558	7	549
559	5	826
560	2	501
561	10	31
562	7	397
563	4	307
564	5	3
565	1	511
566	3	902
567	5	629
568	4	545
569	8	745
570	10	844
571	6	458
572	7	41
573	8	680
574	4	172
575	2	806
576	1	576
577	4	707
578	9	595
579	5	926
580	9	869
581	5	924
582	5	956
583	5	802
584	6	799
585	5	297
586	8	40
587	1	569
588	4	515
589	5	880
590	10	866
591	6	610
592	5	351
593	9	329
594	7	206
595	3	115
596	3	190
597	8	587
598	8	320
599	2	388
600	4	386
\.


--
-- TOC entry 3560 (class 0 OID 40964)
-- Dependencies: 219
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.employee (employeeid, role, name) FROM stdin;
1	mnt	Itay
2	qa	Gal
3	wrk	Lior
4	lead	Tamar
5	clean	Neta
6	clean	Yoni
7	op	Gal
8	lead	Tal
9	op	Eden
10	op	Itay
11	op	Eden
12	wrk	Maya
13	tech	Sarit
14	wrk	Amit
15	wrk	Avi
16	op	Eli
17	op	Neta
18	op	Gal
19	clean	Itay
20	mnt	Omer
21	qa	Eli
22	wrk	Shai
23	op	Maya
24	op	Omer
25	clean	Sarit
26	mnt	Avi
27	wrk	Yoni
28	qa	Gal
29	clean	Shai
30	tech	Maya
31	op	Sarit
32	lab	Avi
33	tech	Noam
34	qa	Itay
35	wrk	Yael
36	op	Maya
37	lab	Itay
38	op	Amit
39	lead	Yael
40	op	Shai
41	op	Omer
42	mnt	Avi
43	wrk	Amit
44	lab	Yoni
45	op	Shai
46	clean	Lior
47	op	Shai
48	lab	Yael
49	op	Lena
50	mnt	Maya
888	qa	garry
\.


--
-- TOC entry 3571 (class 0 OID 65921)
-- Dependencies: 238
-- Data for Name: employee_local; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.employee_local (employeeid, employeename, hiredate, roleid) FROM stdin;
1	יואב כהן	2025-01-01	1
2	נועה לוי	2025-01-02	1
3	דניאל מזרחי	2025-01-03	1
5	תמר רוזן	2025-01-05	1
11	יעל שרון	2025-01-01	3
12	עומר דרור	2025-01-02	2
13	ליה שמש	2025-01-03	5
14	עידן בר	2025-01-04	6
15	מתן רז	2025-01-05	4
4	אדם פרידמן	2025-01-04	1
\.


--
-- TOC entry 3579 (class 0 OID 66016)
-- Dependencies: 246
-- Data for Name: employee_merge; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.employee_merge (employeeid, employeename, hiredate, roleid) FROM stdin;
1	יואב כהן	2025-01-01	1
2	נועה לוי	2025-01-02	1
3	דניאל מזרחי	2025-01-03	1
5	תמר רוזן	2025-01-05	1
11	יעל שרון	2025-01-01	3
12	עומר דרור	2025-01-02	2
13	ליה שמש	2025-01-03	5
14	עידן בר	2025-01-04	6
15	מתן רז	2025-01-05	4
4	אדם פרידמן	2025-01-04	1
39	Yael	\N	8
8	Tal	\N	8
50	Maya	\N	9
42	Avi	\N	9
26	Avi	\N	9
20	Omer	\N	9
49	Lena	\N	10
47	Shai	\N	10
45	Shai	\N	10
41	Omer	\N	10
40	Shai	\N	10
38	Amit	\N	10
36	Maya	\N	10
31	Sarit	\N	10
24	Omer	\N	10
23	Maya	\N	10
18	Gal	\N	10
17	Neta	\N	10
16	Eli	\N	10
10	Itay	\N	10
9	Eden	\N	10
7	Gal	\N	10
888	garry	\N	11
34	Itay	\N	11
28	Gal	\N	11
21	Eli	\N	11
33	Noam	\N	13
30	Maya	\N	13
43	Amit	\N	14
35	Yael	\N	14
27	Yoni	\N	14
22	Shai	\N	14
46	Lior	\N	6
29	Shai	\N	6
25	Sarit	\N	6
19	Itay	\N	6
48	Yael	\N	7
44	Yoni	\N	7
37	Itay	\N	7
32	Avi	\N	7
6	Yoni	\N	7
\.


--
-- TOC entry 3561 (class 0 OID 40967)
-- Dependencies: 220
-- Data for Name: finalproduct_; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.finalproduct_ (quntityofbottle, batchnumber_, winetype_, bottlingdate_, numbottls, productid) FROM stdin;
1.5	1	Syrah	2024-11-01	511	\N
0.5	2	Syrah	2025-04-03	498	\N
1	3	Gamay	2024-09-05	711	\N
1	4	Merlot	2024-07-19	753	\N
1.5	10	Syrah	2025-03-31	316	\N
1	11	Pinot Noir	2024-09-08	185	\N
1	12	Merlot	2024-05-08	650	\N
1	14	Merlot	2025-04-06	449	\N
1	16	Dolcetto	2024-05-28	391	\N
0.75	17	Syrah	2025-02-26	785	\N
1	18	Barbera	2025-01-18	574	\N
0.75	19	Malbec	2024-09-01	195	\N
1	23	Dolcetto	2024-10-01	688	\N
1.5	24	Gamay	2024-10-10	363	\N
0.75	25	Syrah	2025-03-05	625	\N
1.5	26	Riesling	2025-03-22	719	\N
0.75	27	Dolcetto	2024-05-20	664	\N
0.75	28	Malbec	2024-05-19	293	\N
0.5	29	Gamay	2025-02-07	467	\N
1	31	Dolcetto	2025-04-13	384	\N
0.75	32	Merlot	2024-09-20	783	\N
1	34	Malbec	2024-11-24	687	\N
0.5	35	Gamay	2024-06-07	438	\N
0.5	36	Merlot	2024-12-03	587	\N
0.75	37	Pinot Noir	2024-12-18	524	\N
1	38	Gamay	2024-10-12	218	\N
0.5	39	Dolcetto	2024-08-01	542	\N
1.5	40	Gamay	2024-12-16	742	\N
0.5	41	Syrah	2025-04-10	332	\N
1.5	42	Syrah	2024-06-28	172	\N
1	43	Malbec	2024-06-07	133	\N
1.5	45	Dolcetto	2024-04-26	170	\N
0.75	46	Dolcetto	2024-12-06	385	\N
1.5	47	Barbera	2024-07-12	414	\N
0.5	48	Merlot	2024-10-25	471	\N
1	49	Dolcetto	2024-10-13	401	\N
1	51	Gamay	2024-10-03	266	\N
1.5	52	Pinot Noir	2024-06-13	227	\N
0.5	54	Riesling	2024-10-05	520	\N
0.75	55	Merlot	2024-10-22	513	\N
0.5	56	Dolcetto	2024-07-24	360	\N
1.5	57	Pinot Noir	2024-06-29	388	\N
0.75	58	Syrah	2024-09-23	684	\N
1	59	Malbec	2024-06-18	393	\N
1	60	Syrah	2024-11-24	635	\N
1.5	61	Dolcetto	2025-01-29	507	\N
0.5	62	Pinot Noir	2025-03-12	513	\N
0.75	13	Merlot	2024-10-14	796	\N
0.75	64	Syrah	2025-03-30	553	\N
0.75	65	Pinot Noir	2024-08-21	600	\N
0.5	66	Barbera	2024-12-25	550	\N
1	15	Merlot	2024-05-08	176	\N
1	20	Merlot	2024-11-27	462	\N
1	69	Malbec	2024-05-19	454	\N
0.75	22	Merlot	2025-04-17	592	\N
0.5	71	Riesling	2024-05-26	280	\N
1.5	72	Barbera	2024-08-17	716	\N
0.75	73	Riesling	2024-04-29	363	\N
0.5	74	Riesling	2024-07-21	639	\N
0.75	75	Merlot	2024-11-09	555	\N
0.75	76	Barbera	2024-04-25	599	\N
1	77	Dolcetto	2025-04-04	103	\N
0.5	78	Gamay	2024-10-03	275	\N
0.75	79	Merlot	2024-09-17	522	\N
0.75	80	Malbec	2025-04-07	651	\N
1	81	Malbec	2024-06-01	635	\N
0.75	82	Pinot Noir	2024-08-09	194	\N
0.75	83	Pinot Noir	2024-11-25	673	\N
0.75	44	Merlot	2024-11-29	566	\N
0.5	53	Merlot	2025-04-17	271	\N
0.5	67	Merlot	2024-12-03	224	\N
1.5	87	Riesling	2025-03-19	788	\N
0.75	70	Merlot	2024-10-27	662	\N
0.75	84	Merlot	2025-04-03	414	\N
1	888	5885	2025-05-05	100	\N
1.5	91	Malbec	2024-11-25	481	\N
0.75	92	Gamay	2025-02-22	174	\N
1	93	Riesling	2024-05-11	311	\N
0.5	94	Gamay	2024-10-14	214	\N
0.5	95	Syrah	2024-06-04	121	\N
0.5	96	Barbera	2024-10-22	377	\N
0.75	97	Barbera	2024-09-01	336	\N
1	98	Merlot	2024-06-05	120	\N
0.5	5	Barbera	2024-04-25	205	401
1	6	Pinot Noir	2024-07-26	266	402
0.5	101	Dolcetto	2024-06-22	420	\N
1	102	Pinot Noir	2025-01-08	111	\N
0.5	7	Barbera	2024-10-25	200	403
0.5	104	Riesling	2024-05-17	750	\N
1.5	105	Barbera	2025-01-29	157	\N
1.5	106	Merlot	2024-04-30	173	\N
0.75	107	Syrah	2025-01-31	555	\N
0.5	108	Riesling	2024-07-16	607	\N
0.75	109	Malbec	2024-08-21	408	\N
1	110	Dolcetto	2024-09-11	240	\N
1	8	Merlot	2025-03-09	632	404
0.5	112	Riesling	2024-08-05	771	\N
1	113	Pinot Noir	2024-11-12	570	\N
0.75	114	Syrah	2025-03-06	764	\N
0.75	115	Dolcetto	2024-07-16	677	\N
1	116	Merlot	2024-09-07	648	\N
1.5	117	Syrah	2024-05-18	329	\N
0.75	118	Syrah	2024-09-28	797	\N
1.5	119	Dolcetto	2024-10-26	343	\N
1	120	Pinot Noir	2025-02-24	153	\N
1	121	Merlot	2024-09-03	252	\N
0.5	122	Barbera	2024-08-11	276	\N
1.5	123	Syrah	2024-08-22	176	\N
1.5	9	Syrah	2024-11-08	679	405
1	125	Riesling	2025-02-18	506	\N
1	127	Gamay	2024-12-07	613	\N
0.75	128	Gamay	2024-12-03	501	\N
0.75	129	Dolcetto	2025-01-22	111	\N
1	130	Gamay	2024-05-04	497	\N
1.5	131	Merlot	2025-01-30	162	\N
1	133	Pinot Noir	2024-07-10	670	\N
1	134	Barbera	2024-08-30	306	\N
1.5	135	Gamay	2024-07-05	758	\N
1.5	136	Barbera	2024-12-24	611	\N
1.5	137	Malbec	2024-04-29	240	\N
0.75	138	Gamay	2025-03-16	798	\N
1.5	139	Riesling	2024-08-06	202	\N
0.75	30	Gamay	2024-09-07	330	\N
0.75	141	Pinot Noir	2025-02-23	692	\N
1.5	142	Syrah	2024-12-14	113	\N
0.75	143	Malbec	2025-01-22	335	\N
0.75	144	Barbera	2024-07-29	520	\N
1.5	145	Riesling	2024-08-26	513	\N
0.5	33	Malbec	2024-06-13	118	\N
1.5	147	Merlot	2024-10-28	200	\N
0.75	148	Malbec	2024-10-11	729	\N
0.5	149	Riesling	2024-09-26	511	\N
0.5	150	Riesling	2024-06-07	267	\N
1	151	Syrah	2024-09-27	593	\N
1	152	Malbec	2024-08-05	200	\N
0.75	153	Riesling	2024-05-29	370	\N
0.5	154	Syrah	2024-05-23	547	\N
0.5	155	Merlot	2024-12-13	464	\N
1	156	Pinot Noir	2025-03-10	184	\N
1	157	Pinot Noir	2024-06-02	387	\N
0.5	63	Syrah	2024-06-13	521	\N
1.5	159	Syrah	2025-04-19	268	\N
1.5	160	Dolcetto	2024-12-26	300	\N
0.5	161	Barbera	2024-06-05	301	\N
0.75	86	Syrah	2025-02-21	268	\N
1	88	Gamay	2024-07-27	213	\N
0.75	164	Pinot Noir	2024-12-18	699	\N
0.75	165	Barbera	2024-11-18	334	\N
1	166	Malbec	2024-09-19	530	\N
1.5	167	Merlot	2025-02-22	332	\N
0.5	168	Syrah	2024-11-20	472	\N
1.5	169	Barbera	2025-02-03	330	\N
0.5	170	Malbec	2024-07-14	510	\N
0.5	171	Gamay	2025-04-19	134	\N
1.5	99	Gamay	2025-04-15	503	\N
1.5	173	Syrah	2024-10-21	621	\N
1	174	Merlot	2024-05-04	250	\N
0.5	175	Syrah	2024-10-07	629	\N
0.75	176	Pinot Noir	2025-02-25	138	\N
0.75	177	Gamay	2024-06-20	738	\N
0.75	178	Syrah	2024-08-26	724	\N
0.5	179	Dolcetto	2024-09-10	448	\N
1.5	180	Dolcetto	2024-09-09	751	\N
1	111	Malbec	2024-10-11	613	\N
0.75	182	Riesling	2024-12-14	726	\N
1	183	Malbec	2024-06-09	120	\N
1	184	Merlot	2025-02-12	225	\N
0.75	185	Merlot	2024-05-09	798	\N
1.5	146	Syrah	2024-12-12	603	\N
1	187	Dolcetto	2024-05-09	568	\N
1	188	Pinot Noir	2025-04-05	209	\N
0.75	189	Syrah	2024-09-06	615	\N
0.75	191	Barbera	2024-12-20	707	\N
1.5	192	Pinot Noir	2025-03-12	544	\N
0.5	193	Syrah	2024-08-10	250	\N
0.75	194	Syrah	2024-06-24	318	\N
0.75	195	Dolcetto	2025-03-12	657	\N
1.5	196	Merlot	2024-05-23	564	\N
0.5	197	Riesling	2025-02-22	225	\N
1.5	198	Pinot Noir	2024-11-07	340	\N
0.5	199	Barbera	2024-06-26	526	\N
0.5	200	Dolcetto	2025-03-29	513	\N
0.75	201	Dolcetto	2024-08-28	204	\N
0.5	203	Barbera	2025-01-22	232	\N
1.5	204	Merlot	2025-02-01	205	\N
0.75	202	Syrah	2024-06-20	548	\N
0.75	206	Syrah	2024-07-23	292	\N
1.5	208	Dolcetto	2024-10-13	509	\N
0.5	209	Gamay	2024-09-07	391	\N
0.5	210	Pinot Noir	2025-04-11	350	\N
0.75	211	Riesling	2024-10-16	587	\N
1.5	212	Riesling	2025-03-22	773	\N
1.5	213	Merlot	2025-02-04	597	\N
1	214	Dolcetto	2025-01-24	349	\N
1	216	Pinot Noir	2024-11-28	198	\N
1	217	Pinot Noir	2024-06-30	712	\N
1	218	Riesling	2025-03-06	791	\N
0.5	207	Malbec	2025-01-03	679	\N
0.75	223	Barbera	2024-09-27	445	\N
0.75	224	Dolcetto	2024-07-31	142	\N
1.5	225	Malbec	2024-04-30	587	\N
1	221	Syrah	2024-08-04	571	\N
1	227	Dolcetto	2024-12-26	545	\N
1.5	229	Barbera	2025-03-21	784	\N
0.5	231	Riesling	2024-07-20	380	\N
1	232	Merlot	2025-03-12	532	\N
0.5	237	Barbera	2024-06-24	700	\N
0.5	238	Merlot	2024-09-25	659	\N
1	240	Pinot Noir	2024-04-26	251	\N
0.75	241	Merlot	2024-11-26	669	\N
1	243	Syrah	2024-08-19	140	\N
1.5	244	Barbera	2024-07-05	132	\N
1.5	245	Barbera	2025-03-27	467	\N
1	246	Dolcetto	2025-02-06	433	\N
1.5	247	Merlot	2024-12-23	789	\N
1.5	248	Malbec	2025-01-03	367	\N
1.5	222	Riesling	2025-05-26	655	\N
1	250	Merlot	2024-11-06	341	\N
0.5	251	Pinot Noir	2024-07-23	440	\N
1.5	252	Dolcetto	2024-04-26	577	\N
0.75	253	Syrah	2024-10-08	703	\N
1	255	Pinot Noir	2025-03-17	216	\N
1	256	Riesling	2024-10-10	484	\N
0.5	257	Dolcetto	2025-04-15	271	\N
0.5	258	Merlot	2024-06-17	294	\N
0.75	259	Syrah	2025-01-11	789	\N
1.5	261	Pinot Noir	2025-04-02	394	\N
1	262	Malbec	2024-04-26	785	\N
1	263	Riesling	2024-09-16	132	\N
1	264	Gamay	2024-07-18	544	\N
0.5	265	Dolcetto	2024-07-25	105	\N
0.75	268	Barbera	2024-09-17	119	\N
1.5	269	Barbera	2025-02-11	370	\N
1.5	271	Malbec	2024-06-30	198	\N
1.5	272	Dolcetto	2024-05-10	105	\N
1.5	273	Syrah	2024-06-21	665	\N
0.5	274	Malbec	2024-11-22	761	\N
0.5	275	Malbec	2024-06-10	250	\N
0.75	276	Riesling	2024-06-18	719	\N
0.75	278	Gamay	2024-11-14	539	\N
0.5	279	Riesling	2024-10-26	582	\N
0.75	68	Barbera	2024-11-09	240	\N
1.5	281	Malbec	2025-03-22	263	\N
1	282	Merlot	2025-02-07	549	\N
1	283	Riesling	2024-09-03	633	\N
1	284	Pinot Noir	2024-07-29	477	\N
0.75	285	Dolcetto	2024-09-05	365	\N
0.5	286	Pinot Noir	2024-07-26	285	\N
1.5	288	Merlot	2024-09-20	295	\N
0.75	89	Merlot	2024-08-27	542	\N
1	290	Syrah	2025-01-15	683	\N
0.75	291	Gamay	2025-02-23	192	\N
0.75	292	Barbera	2024-11-30	578	\N
0.75	293	Barbera	2024-04-25	697	\N
0.75	294	Dolcetto	2024-07-14	607	\N
0.75	295	Gamay	2024-08-02	102	\N
0.5	90	Gamay	2024-06-03	517	\N
0.5	297	Malbec	2024-10-22	512	\N
1	298	Syrah	2024-05-23	435	\N
1.5	299	Gamay	2024-12-24	483	\N
0.5	300	Gamay	2024-04-22	499	\N
0.75	103	Barbera	2024-05-13	462	\N
1.5	302	Gamay	2024-08-29	274	\N
0.75	303	Barbera	2025-02-19	540	\N
1.5	304	Merlot	2024-10-16	727	\N
1	305	Dolcetto	2024-08-16	323	\N
0.5	306	Riesling	2025-04-06	640	\N
1.5	307	Merlot	2025-03-24	587	\N
1	308	Pinot Noir	2024-07-09	347	\N
0.75	309	Gamay	2025-03-23	215	\N
1	310	Syrah	2024-05-14	350	\N
0.75	311	Barbera	2024-11-09	329	\N
1.5	312	Merlot	2024-10-30	115	\N
0.75	313	Dolcetto	2024-06-27	639	\N
1	314	Gamay	2024-05-30	689	\N
0.5	315	Malbec	2024-10-05	269	\N
1	316	Dolcetto	2024-08-22	388	\N
0.75	384	Gamay	2024-08-03	174	\N
1	318	Gamay	2024-05-05	179	\N
0.75	126	Merlot	2024-11-11	457	\N
1	320	Pinot Noir	2024-09-04	133	\N
1.5	321	Syrah	2024-06-23	564	\N
1	322	Syrah	2024-05-24	239	\N
1.5	323	Barbera	2024-08-07	689	\N
0.5	324	Gamay	2025-01-23	503	\N
1.5	163	Gamay	2024-05-06	330	\N
0.75	327	Barbera	2024-09-04	198	\N
1	215	Gamay	2024-09-14	368	\N
0.5	329	Gamay	2024-07-01	664	\N
1.5	330	Merlot	2025-04-14	431	\N
1	332	Gamay	2024-07-22	663	\N
1	333	Dolcetto	2025-03-21	490	\N
1.5	334	Dolcetto	2025-03-29	695	\N
1	335	Riesling	2025-02-23	369	\N
0.75	336	Pinot Noir	2024-05-30	378	\N
0.75	337	Pinot Noir	2024-12-29	722	\N
1	338	Barbera	2024-10-14	629	\N
1	339	Barbera	2025-02-04	383	\N
1.5	340	Syrah	2025-03-19	120	\N
1	341	Gamay	2025-03-26	107	\N
0.75	226	Malbec	2024-08-20	731	\N
1	343	Merlot	2025-02-04	153	\N
1.5	344	Merlot	2025-03-15	670	\N
1.5	239	Malbec	2025-02-12	699	\N
0.75	346	Gamay	2024-06-23	521	\N
1	347	Pinot Noir	2024-12-21	775	\N
0.75	348	Gamay	2024-04-29	213	\N
1	349	Gamay	2025-02-20	116	\N
0.5	350	Barbera	2024-06-23	504	\N
0.75	351	Malbec	2024-05-06	318	\N
0.5	352	Merlot	2025-02-20	344	\N
1.5	353	Syrah	2025-01-31	444	\N
1.5	354	Dolcetto	2025-02-27	268	\N
0.75	355	Barbera	2025-02-14	302	\N
1.5	356	Barbera	2024-12-17	692	\N
0.75	357	Dolcetto	2024-10-10	534	\N
1	358	Merlot	2024-12-19	571	\N
1.5	359	Dolcetto	2024-11-22	348	\N
0.75	361	Dolcetto	2024-10-11	286	\N
1.5	362	Pinot Noir	2025-03-29	701	\N
0.75	364	Pinot Noir	2025-01-13	515	\N
0.75	365	Riesling	2024-08-10	436	\N
0.75	317	Merlot	2024-09-03	133	\N
0.75	367	Gamay	2024-05-27	498	\N
1	368	Gamay	2024-08-30	646	\N
1	369	Dolcetto	2025-04-12	357	\N
1.5	370	Syrah	2024-05-15	632	\N
0.75	371	Merlot	2025-03-25	404	\N
1.5	372	Pinot Noir	2024-06-06	385	\N
0.5	325	Syrah	2025-01-05	572	\N
1	375	Dolcetto	2024-09-07	434	\N
1.5	376	Merlot	2024-08-11	286	\N
0.5	377	Dolcetto	2024-11-10	736	\N
0.75	378	Pinot Noir	2024-09-18	766	\N
1.5	379	Syrah	2025-04-13	640	\N
0.5	380	Malbec	2025-04-07	695	\N
1.5	382	Pinot Noir	2024-10-10	439	\N
1	385	Malbec	2024-10-12	713	\N
0.5	386	Dolcetto	2025-03-21	237	\N
0.5	387	Merlot	2024-05-14	280	\N
1	388	Dolcetto	2024-12-03	405	\N
0.75	391	Dolcetto	2024-11-16	458	\N
0.75	392	Gamay	2024-11-07	248	\N
0.5	393	Pinot Noir	2024-11-22	291	\N
1.5	394	Riesling	2024-06-17	705	\N
1.5	395	Gamay	2024-09-11	122	\N
0.5	396	Barbera	2024-12-01	118	\N
0.75	398	Pinot Noir	2024-12-20	576	\N
1.5	401	Barbera	2024-08-30	200	\N
1.5	402	Riesling	2025-01-31	593	\N
0.75	403	Syrah	2024-09-14	663	\N
0.75	404	Malbec	2025-02-16	668	\N
1	405	Dolcetto	2024-11-23	692	\N
1	406	Dolcetto	2025-03-15	449	\N
0.75	407	Dolcetto	2025-04-19	165	\N
0.5	408	Riesling	2024-10-12	372	\N
1.5	409	Malbec	2025-04-19	713	\N
0.75	410	Riesling	2024-08-14	158	\N
1	411	Dolcetto	2024-08-16	627	\N
1	412	Gamay	2025-04-15	596	\N
1	413	Merlot	2024-06-05	416	\N
1	414	Riesling	2025-01-04	442	\N
1	415	Pinot Noir	2024-04-28	157	\N
1	416	Gamay	2025-02-28	456	\N
0.5	417	Malbec	2025-02-27	157	\N
0.75	418	Riesling	2024-08-13	204	\N
0.5	419	Pinot Noir	2024-10-31	111	\N
0.5	420	Gamay	2024-07-27	145	\N
0.5	421	Syrah	2024-08-29	533	\N
1	422	Pinot Noir	2024-05-18	471	\N
1.5	423	Pinot Noir	2024-10-18	595	\N
1	424	Gamay	2025-02-25	525	\N
0.5	425	Barbera	2024-12-18	203	\N
1.5	426	Barbera	2024-05-26	277	\N
1.5	427	Dolcetto	2024-11-20	624	\N
1	428	Barbera	2024-04-21	192	\N
0.75	429	Malbec	2024-06-12	363	\N
1	430	Malbec	2024-05-07	332	\N
1.5	431	Riesling	2024-05-26	427	\N
1.5	432	Merlot	2024-05-07	193	\N
0.5	433	Riesling	2024-11-22	361	\N
0.75	434	Malbec	2024-06-07	552	\N
0.5	435	Syrah	2024-05-30	753	\N
1	436	Barbera	2025-04-05	175	\N
1	437	Syrah	2025-01-04	450	\N
1.5	438	Barbera	2024-06-10	287	\N
1.5	439	Merlot	2025-01-24	169	\N
0.75	440	Dolcetto	2024-09-29	722	\N
1.5	441	Merlot	2025-04-12	562	\N
1.5	442	Riesling	2024-06-17	226	\N
0.5	443	Merlot	2024-10-14	264	\N
1	444	Riesling	2024-06-01	130	\N
1	445	Riesling	2025-03-25	638	\N
0.5	446	Malbec	2025-04-14	726	\N
0.75	447	Riesling	2024-07-31	408	\N
1	448	Barbera	2024-09-19	765	\N
0.75	449	Barbera	2024-08-04	447	\N
0.75	450	Malbec	2025-01-23	764	\N
1.5	451	Merlot	2025-03-29	274	\N
1	452	Pinot Noir	2025-01-12	410	\N
0.75	453	Barbera	2025-02-12	109	\N
1	454	Malbec	2025-03-28	472	\N
0.5	455	Malbec	2024-09-22	482	\N
0.5	456	Gamay	2024-07-20	391	\N
1.5	457	Merlot	2024-08-15	666	\N
1.5	458	Riesling	2025-02-24	772	\N
0.5	459	Pinot Noir	2024-06-30	749	\N
0.5	460	Merlot	2024-04-28	100	\N
1	461	Syrah	2024-07-02	749	\N
1.5	462	Gamay	2025-03-02	249	\N
1.5	463	Pinot Noir	2025-04-16	148	\N
0.5	464	Pinot Noir	2024-10-01	688	\N
1	465	Riesling	2025-04-10	585	\N
0.5	466	Malbec	2024-11-20	549	\N
0.75	467	Merlot	2025-02-05	755	\N
0.75	468	Syrah	2024-07-28	488	\N
1	469	Barbera	2024-07-30	591	\N
1	470	Syrah	2024-05-05	753	\N
0.5	471	Syrah	2024-06-26	243	\N
0.5	472	Riesling	2024-11-22	200	\N
0.5	473	Barbera	2024-11-06	238	\N
1	474	Syrah	2025-03-25	366	\N
0.5	475	Barbera	2024-07-18	309	\N
1.5	476	Gamay	2024-08-25	672	\N
0.5	477	Syrah	2024-11-09	625	\N
0.5	478	Riesling	2024-05-05	531	\N
0.75	479	Syrah	2024-10-16	573	\N
0.5	480	Dolcetto	2025-04-17	316	\N
0.5	481	Syrah	2024-10-20	690	\N
1.5	482	Malbec	2024-08-15	682	\N
0.5	483	Barbera	2025-04-13	388	\N
0.75	484	Malbec	2024-11-18	647	\N
0.5	485	Syrah	2024-09-13	454	\N
1	486	Dolcetto	2024-05-27	305	\N
0.5	487	Dolcetto	2024-12-24	145	\N
0.5	488	Merlot	2025-02-23	107	\N
0.5	489	Gamay	2024-04-24	697	\N
1	490	Syrah	2025-03-12	795	\N
1	491	Malbec	2025-02-19	381	\N
1.5	492	Gamay	2025-01-03	226	\N
0.75	493	Malbec	2024-08-05	727	\N
0.75	494	Syrah	2024-07-04	268	\N
0.75	495	Riesling	2024-09-27	224	\N
0.5	496	Syrah	2025-01-05	331	\N
0.75	497	Pinot Noir	2025-01-03	724	\N
0.75	498	Syrah	2024-12-10	547	\N
1.5	499	Pinot Noir	2024-10-29	227	\N
0.5	500	Riesling	2024-12-23	571	\N
0.75	501	Syrah	2025-01-06	435	\N
0.75	502	Dolcetto	2024-05-01	333	\N
1	503	Dolcetto	2024-10-15	489	\N
1	504	Dolcetto	2025-03-04	757	\N
0.75	505	Malbec	2025-01-23	636	\N
1	506	Dolcetto	2024-08-20	103	\N
0.5	507	Merlot	2025-04-05	309	\N
0.75	508	Merlot	2024-05-30	193	\N
1	509	Merlot	2024-07-21	436	\N
1	510	Syrah	2024-11-11	279	\N
1	511	Riesling	2024-09-27	547	\N
0.5	512	Riesling	2024-10-26	427	\N
1.5	513	Riesling	2024-04-30	202	\N
1.5	514	Pinot Noir	2025-03-29	733	\N
1	515	Pinot Noir	2025-03-28	544	\N
0.5	516	Malbec	2024-10-17	405	\N
0.75	517	Dolcetto	2024-05-25	584	\N
0.75	518	Barbera	2024-05-18	519	\N
0.75	519	Syrah	2024-12-06	402	\N
1	520	Barbera	2025-03-13	293	\N
1.5	521	Pinot Noir	2024-06-18	244	\N
1	522	Barbera	2024-09-01	629	\N
1.5	523	Malbec	2025-04-11	235	\N
1	524	Pinot Noir	2025-02-09	255	\N
0.75	525	Malbec	2024-11-02	615	\N
0.5	526	Merlot	2025-01-22	384	\N
0.75	527	Syrah	2025-04-19	628	\N
1.5	528	Pinot Noir	2025-02-09	439	\N
1	529	Merlot	2024-10-17	245	\N
1	530	Barbera	2025-04-14	734	\N
0.5	531	Barbera	2024-07-11	381	\N
0.75	532	Dolcetto	2024-12-14	329	\N
0.5	533	Pinot Noir	2024-09-06	113	\N
0.5	534	Malbec	2024-08-18	730	\N
0.5	535	Pinot Noir	2024-06-21	741	\N
0.5	536	Pinot Noir	2024-05-11	244	\N
1	537	Dolcetto	2024-11-25	699	\N
0.5	538	Gamay	2025-02-15	393	\N
0.75	539	Barbera	2024-08-22	268	\N
0.5	540	Pinot Noir	2024-06-10	136	\N
1.5	541	Barbera	2024-05-23	506	\N
0.75	542	Gamay	2024-10-31	252	\N
0.5	543	Syrah	2025-04-09	500	\N
0.5	544	Pinot Noir	2025-04-13	394	\N
1	545	Gamay	2024-05-06	406	\N
0.75	546	Dolcetto	2024-07-17	483	\N
1.5	547	Merlot	2024-07-25	669	\N
0.5	548	Syrah	2024-07-06	635	\N
0.75	549	Pinot Noir	2024-10-12	254	\N
0.5	550	Riesling	2025-03-13	162	\N
0.5	551	Malbec	2024-04-22	713	\N
0.75	552	Malbec	2025-01-14	668	\N
1.5	553	Riesling	2024-04-25	202	\N
1.5	554	Barbera	2024-12-16	160	\N
0.75	555	Barbera	2024-06-12	293	\N
0.5	556	Barbera	2024-12-03	511	\N
0.75	557	Barbera	2025-04-05	392	\N
0.75	558	Pinot Noir	2024-06-10	736	\N
0.5	559	Riesling	2024-05-21	352	\N
0.5	560	Gamay	2024-11-05	470	\N
0.75	561	Dolcetto	2024-12-25	636	\N
0.5	562	Syrah	2025-01-17	296	\N
0.5	563	Dolcetto	2024-12-15	776	\N
1.5	564	Gamay	2024-11-22	349	\N
0.75	565	Dolcetto	2025-02-25	680	\N
1	566	Dolcetto	2024-04-24	264	\N
1.5	567	Dolcetto	2025-02-18	222	\N
1.5	568	Dolcetto	2024-09-17	749	\N
1	569	Pinot Noir	2025-03-10	757	\N
0.5	570	Riesling	2025-01-17	240	\N
1.5	571	Pinot Noir	2024-07-26	232	\N
0.75	572	Syrah	2024-05-26	791	\N
1	573	Dolcetto	2025-01-09	323	\N
0.75	574	Pinot Noir	2025-02-05	311	\N
0.75	575	Syrah	2024-09-07	238	\N
1.5	576	Barbera	2024-10-20	414	\N
1.5	577	Merlot	2024-08-06	229	\N
0.5	578	Riesling	2024-10-15	157	\N
1	579	Barbera	2024-10-31	505	\N
1.5	580	Merlot	2025-01-09	244	\N
1.5	581	Pinot Noir	2024-12-30	700	\N
1	582	Merlot	2024-10-24	319	\N
0.75	583	Malbec	2024-05-22	749	\N
0.5	584	Merlot	2024-11-04	672	\N
1	585	Pinot Noir	2024-12-22	591	\N
1	586	Merlot	2025-03-01	532	\N
0.5	587	Merlot	2024-05-19	543	\N
0.5	588	Malbec	2025-01-19	533	\N
1	589	Barbera	2024-10-30	361	\N
1	590	Riesling	2024-09-19	703	\N
0.75	591	Malbec	2024-07-16	301	\N
0.5	592	Dolcetto	2024-06-08	365	\N
1	593	Malbec	2024-10-17	215	\N
0.75	594	Barbera	2024-10-11	303	\N
0.5	595	Syrah	2024-12-25	158	\N
0.75	596	Barbera	2024-09-07	180	\N
1.5	597	Riesling	2025-04-20	140	\N
0.5	598	Merlot	2025-03-11	363	\N
1.5	599	Gamay	2024-09-04	419	\N
0.5	600	Pinot Noir	2024-05-12	798	\N
0.5	162	Barbera	2024-11-21	440	\N
1.5	186	Syrah	2024-05-12	458	\N
0.5	326	Gamay	2024-09-04	331	\N
1	331	Syrah	2024-06-13	724	\N
1	21	Riesling	2024-09-29	663	\N
0.75	50	Riesling	2024-12-23	673	\N
0.75	85	Merlot	2025-01-17	222	\N
1.5	100	Barbera	2024-10-12	124	\N
1	124	Merlot	2025-03-02	235	\N
1	132	Syrah	2024-06-23	685	\N
1	140	Syrah	2024-11-17	680	\N
0.75	158	Merlot	2024-07-30	363	\N
1.5	172	Malbec	2025-01-06	640	\N
0.75	181	Merlot	2024-08-04	364	\N
0.75	190	Merlot	2024-05-09	221	\N
0.75	205	Syrah	2024-06-19	268	\N
0.75	219	Riesling	2024-08-26	754	\N
0.75	220	Merlot	2024-11-01	604	\N
1	228	Merlot	2024-09-30	118	\N
1.5	230	Merlot	2024-08-05	411	\N
0.5	233	Malbec	2024-11-30	276	\N
0.75	234	Barbera	2025-02-04	279	\N
1	235	Merlot	2024-11-06	454	\N
1	236	Gamay	2024-07-28	438	\N
1	242	Merlot	2024-09-05	297	\N
1	249	Merlot	2025-02-27	583	\N
1.5	254	Merlot	2025-01-11	213	\N
1.5	260	Syrah	2024-08-08	684	\N
0.75	266	Syrah	2024-11-14	387	\N
0.75	267	Merlot	2025-03-13	392	\N
0.5	270	Merlot	2024-11-23	761	\N
1.5	277	Malbec	2024-07-06	465	\N
0.5	280	Pinot Noir	2025-03-02	745	\N
1	287	Syrah	2025-01-03	397	\N
0.75	289	Merlot	2024-08-16	342	\N
0.5	296	Riesling	2024-05-27	354	\N
0.5	301	Merlot	2024-11-21	346	\N
1.5	319	Merlot	2025-02-12	243	\N
1.5	328	Syrah	2024-09-20	537	\N
1.5	342	Syrah	2025-02-13	381	\N
1.5	345	Malbec	2025-01-19	637	\N
0.5	360	Riesling	2024-09-23	126	\N
0.5	363	Barbera	2024-05-07	495	\N
1.5	366	Merlot	2024-06-14	521	\N
0.75	373	Gamay	2025-03-19	162	\N
0.5	374	Merlot	2024-07-18	389	\N
0.5	381	Syrah	2024-06-02	610	\N
1.5	383	Merlot	2024-06-22	588	\N
0.5	389	Merlot	2024-06-12	482	\N
0.75	390	Syrah	2024-11-19	365	\N
1	397	Gamay	2024-09-29	523	\N
0.75	399	Merlot	2025-01-07	578	\N
0.5	400	Merlot	2024-12-11	173	\N
1	777	Merlot	2025-05-05	100	\N
\.


--
-- TOC entry 3569 (class 0 OID 41052)
-- Dependencies: 228
-- Data for Name: grape_varieties; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.grape_varieties (id, name) FROM stdin;
3369	Merlot
9472	Syrah
6932	Malbec
3848	Gamay
1349	Barbera
2116	Pinot Noir
9836	Riesling
9662	Dolcetto
5429	Cabernet Sauvignon
5885	Zinfandel
\.


--
-- TOC entry 3562 (class 0 OID 40970)
-- Dependencies: 221
-- Data for Name: grapes; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.grapes (grapeid, variety, harvestdate_) FROM stdin;
1	3369	2025-03-12
2	9472	2024-10-02
3	6932	2025-01-20
4	3848	2025-02-26
5	1349	2024-12-13
6	2116	2024-05-31
7	9836	2024-07-26
8	9662	2024-04-23
9	5429	2024-11-08
10	5885	2024-10-31
777	3369	2025-05-01
\.


--
-- TOC entry 3563 (class 0 OID 40973)
-- Dependencies: 222
-- Data for Name: materials_; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.materials_ (materialid_, name_, supplierid_, quantityavailable_) FROM stdin;
6	yeast	880133468	73.32
7	sorbate\t	974486834	512.04
8	acid	953896930	374.76
9	filter	144301605	19.71
10	gloves	987389467	387.44
1	bottle\t	981402913	897.19
2	cork\t	208634251	919.72
3	label\t	572814245	409.40999999999997
4	cleaner\t	829758960	557.17
5	rinse\t	361346674	405.1
888	New Sugar	1	50
999	Oak Wood	1	150
\.


--
-- TOC entry 3575 (class 0 OID 65941)
-- Dependencies: 242
-- Data for Name: orderitems_local; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.orderitems_local (orderid, productid, quantity, supplierprice) FROM stdin;
1	289	14	14.00
1	11	28	3.00
2	232	30	15.00
2	115	11	16.00
2	129	18	17.00
2	6	15	15.00
2	283	24	10.00
2	365	28	23.00
2	252	24	15.00
2	139	27	16.00
2	162	24	16.00
2	226	16	14.00
2	363	24	9.00
2	343	26	5.00
2	244	11	13.00
3	169	29	4.00
3	171	19	10.00
3	235	25	3.00
3	193	26	3.00
3	236	30	24.00
3	258	16	3.00
3	85	24	14.00
3	88	29	7.00
3	259	12	17.00
3	170	14	13.00
3	310	27	6.00
3	79	29	16.00
3	125	26	7.00
3	370	22	2.00
3	204	15	3.00
3	275	17	4.00
3	276	16	13.00
3	59	29	14.00
4	136	23	5.00
4	164	21	17.00
4	256	18	21.00
4	70	14	7.00
4	283	15	10.00
4	196	27	4.00
4	27	20	20.00
5	14	19	13.00
5	360	30	9.00
5	200	14	16.00
5	102	19	10.00
5	119	15	20.00
5	47	20	20.00
5	390	17	7.00
5	219	16	4.00
5	236	30	24.00
5	183	23	25.00
5	117	14	21.00
5	59	23	14.00
5	46	23	7.00
5	264	12	20.00
5	248	26	5.00
6	118	21	3.00
6	261	16	3.00
6	304	11	5.00
6	390	21	7.00
6	128	28	3.00
6	309	19	22.00
6	82	24	23.00
6	221	17	25.00
6	49	10	22.00
6	293	17	4.00
6	136	11	5.00
6	227	16	2.00
6	204	10	3.00
6	95	17	7.00
6	149	24	20.00
6	134	10	8.00
6	285	21	24.00
6	199	22	24.00
6	213	13	23.00
6	339	13	22.00
7	161	14	11.00
7	279	26	11.00
7	108	13	19.00
7	293	15	4.00
7	116	30	14.00
8	323	22	3.00
8	308	24	11.00
8	150	17	4.00
8	62	24	18.00
8	281	12	9.00
8	101	22	22.00
8	248	10	5.00
8	371	19	19.00
8	185	22	9.00
8	270	24	7.00
8	366	23	8.00
8	275	13	4.00
8	291	21	19.00
8	188	22	12.00
9	265	24	7.00
9	180	29	3.00
9	303	18	18.00
9	211	17	22.00
9	95	21	7.00
9	331	18	17.00
9	314	19	15.00
9	229	21	14.00
10	57	17	7.00
10	46	11	7.00
10	241	25	7.00
10	143	26	8.00
10	224	19	11.00
10	300	22	11.00
10	400	11	3.00
10	75	30	15.00
10	348	21	23.00
10	317	21	20.00
10	159	30	24.00
10	101	27	22.00
10	294	28	20.00
10	394	16	14.00
10	296	20	10.00
10	330	20	11.00
10	396	15	5.00
10	154	16	13.00
11	108	29	19.00
12	168	28	13.00
12	310	19	6.00
12	287	11	21.00
12	88	25	7.00
12	385	17	16.00
12	30	13	20.00
12	399	27	3.00
12	282	23	20.00
12	4	17	7.00
12	154	16	13.00
12	344	11	9.00
12	354	20	20.00
13	52	23	13.00
13	131	29	2.00
13	17	26	5.00
13	281	12	9.00
13	154	16	13.00
13	386	28	23.00
13	214	17	13.00
13	394	17	14.00
13	308	14	11.00
13	265	11	7.00
13	390	25	7.00
13	227	13	2.00
13	140	29	3.00
13	51	25	22.00
13	222	30	5.00
13	320	27	11.00
13	117	21	21.00
13	333	19	13.00
13	235	26	3.00
13	164	18	17.00
14	122	22	14.00
14	63	11	17.00
14	128	30	3.00
14	335	10	13.00
14	95	19	7.00
15	58	19	20.00
15	364	26	7.00
15	189	14	4.00
16	242	19	13.00
16	173	25	24.00
16	176	15	3.00
16	109	15	10.00
17	36	14	12.00
18	15	27	23.00
18	37	25	9.00
18	378	24	14.00
18	380	28	12.00
18	158	26	11.00
18	228	22	5.00
18	152	20	20.00
18	323	16	3.00
18	11	23	3.00
18	388	30	4.00
18	394	27	14.00
18	389	30	14.00
18	19	15	17.00
18	141	30	6.00
18	242	25	13.00
18	316	22	16.00
19	341	28	24.00
19	238	21	10.00
19	242	21	13.00
19	344	27	9.00
19	71	24	22.00
19	205	11	6.00
20	193	21	3.00
20	39	15	21.00
20	82	19	23.00
20	264	20	20.00
20	385	21	16.00
20	318	24	7.00
20	34	17	4.00
20	101	25	22.00
20	374	23	20.00
20	311	19	24.00
20	282	13	20.00
20	124	19	24.00
20	290	11	10.00
21	143	22	8.00
21	376	23	9.00
21	16	18	5.00
21	329	21	23.00
21	171	13	10.00
21	263	15	8.00
21	227	25	2.00
21	174	11	6.00
21	122	10	14.00
21	326	11	22.00
21	6	23	15.00
21	118	20	3.00
21	279	22	11.00
21	336	23	19.00
21	192	18	13.00
21	15	28	23.00
21	154	28	13.00
22	381	19	13.00
22	78	22	16.00
22	334	24	25.00
22	276	22	13.00
22	318	14	7.00
22	297	21	11.00
22	70	24	7.00
22	107	12	20.00
22	202	15	15.00
22	289	14	14.00
22	362	13	16.00
22	182	19	8.00
22	306	30	21.00
22	53	12	6.00
22	124	28	24.00
23	78	12	16.00
23	212	29	11.00
23	51	13	22.00
23	323	14	3.00
23	50	19	9.00
23	6	22	15.00
23	172	13	3.00
23	301	13	15.00
23	99	12	21.00
23	57	24	7.00
23	13	13	11.00
23	365	25	23.00
23	79	16	16.00
23	388	18	4.00
23	316	22	16.00
23	165	21	20.00
23	101	30	22.00
24	2	18	16.00
24	42	27	14.00
24	93	22	21.00
24	210	16	23.00
24	337	30	5.00
25	316	24	16.00
25	311	13	24.00
25	331	18	17.00
25	230	15	11.00
26	149	18	20.00
26	160	21	24.00
26	1	25	18.00
27	248	15	5.00
27	185	29	9.00
27	81	11	24.00
27	290	27	10.00
27	54	23	23.00
27	397	11	4.00
27	356	23	22.00
27	36	27	12.00
27	157	21	9.00
27	127	19	21.00
27	125	19	7.00
27	263	12	8.00
27	396	17	5.00
27	28	18	5.00
28	110	22	7.00
28	69	15	24.00
28	176	17	3.00
28	379	15	3.00
28	130	28	17.00
28	323	15	3.00
28	32	22	25.00
28	45	30	22.00
28	203	17	16.00
28	331	21	17.00
29	127	10	21.00
29	238	24	10.00
29	275	10	4.00
29	362	17	16.00
29	176	28	3.00
29	262	16	11.00
29	147	22	20.00
29	314	19	15.00
29	241	12	7.00
29	385	21	16.00
29	261	23	3.00
29	24	14	19.00
29	230	28	11.00
30	367	13	21.00
30	99	19	21.00
30	390	18	7.00
30	169	10	4.00
30	46	29	7.00
30	180	25	3.00
30	393	23	11.00
30	73	23	22.00
30	268	10	23.00
30	42	24	14.00
30	317	20	20.00
30	192	17	13.00
30	272	27	17.00
30	339	17	22.00
30	69	16	24.00
30	289	24	14.00
31	51	15	22.00
31	62	28	18.00
31	33	29	18.00
31	25	29	23.00
31	128	12	3.00
31	326	14	22.00
31	320	19	11.00
31	152	19	20.00
31	117	10	21.00
32	289	25	14.00
32	393	11	11.00
32	41	12	3.00
32	63	18	17.00
32	60	20	19.00
32	320	14	11.00
32	342	28	22.00
32	113	16	9.00
32	170	26	13.00
32	207	25	15.00
32	14	19	13.00
32	85	20	14.00
32	238	22	10.00
32	336	10	19.00
32	235	18	3.00
32	143	22	8.00
33	330	16	11.00
33	70	26	7.00
33	2	26	16.00
33	377	25	3.00
34	345	21	8.00
34	195	30	21.00
34	139	26	16.00
34	70	13	7.00
34	103	10	24.00
34	119	27	20.00
34	153	21	15.00
34	198	29	22.00
34	50	28	9.00
34	52	29	13.00
34	228	20	5.00
34	324	25	17.00
34	63	16	17.00
35	84	16	15.00
35	59	19	14.00
35	355	10	23.00
35	117	17	21.00
36	121	30	4.00
36	99	14	21.00
36	390	22	7.00
36	71	13	22.00
36	130	10	17.00
36	149	13	20.00
36	20	22	3.00
36	139	15	16.00
36	50	14	9.00
37	49	18	22.00
37	138	19	7.00
37	396	21	5.00
37	360	11	9.00
37	16	17	5.00
37	110	14	7.00
37	66	21	5.00
37	394	23	14.00
37	237	22	11.00
37	349	26	12.00
37	347	25	4.00
37	268	21	23.00
37	348	25	23.00
37	96	22	21.00
37	265	11	7.00
37	54	17	23.00
37	115	18	16.00
37	366	15	8.00
37	292	22	22.00
38	328	11	21.00
38	327	19	4.00
38	393	22	11.00
38	85	26	14.00
38	229	11	14.00
38	19	21	17.00
38	316	10	16.00
38	331	22	17.00
38	249	30	15.00
38	23	19	21.00
38	386	11	23.00
38	273	27	20.00
38	141	19	6.00
38	289	16	14.00
39	303	17	18.00
39	6	17	15.00
39	73	18	22.00
39	267	28	10.00
39	310	26	6.00
40	97	15	2.00
40	346	20	8.00
40	198	12	22.00
40	60	27	19.00
40	169	28	4.00
40	302	25	7.00
40	309	20	22.00
40	124	19	24.00
40	327	26	4.00
40	241	27	7.00
41	268	21	23.00
41	49	15	22.00
41	397	17	4.00
41	333	22	13.00
41	394	21	14.00
41	59	23	14.00
42	11	15	3.00
42	169	15	4.00
42	108	13	19.00
42	64	26	12.00
43	300	20	11.00
43	227	18	2.00
43	170	13	13.00
43	243	11	21.00
43	74	11	6.00
43	112	28	5.00
43	100	23	21.00
43	10	12	8.00
43	134	11	8.00
43	20	21	3.00
43	77	13	10.00
43	195	19	21.00
43	18	26	15.00
43	24	13	19.00
43	263	20	8.00
44	30	21	20.00
44	392	27	8.00
44	332	19	24.00
45	270	23	7.00
45	375	15	8.00
45	339	15	22.00
45	271	13	6.00
45	337	21	5.00
45	231	28	18.00
45	83	20	4.00
45	120	27	10.00
46	355	21	23.00
47	65	18	16.00
47	365	12	23.00
48	349	25	12.00
48	344	16	9.00
48	11	11	3.00
48	219	11	4.00
48	281	25	9.00
48	78	15	16.00
48	199	28	24.00
48	139	30	16.00
48	10	12	8.00
48	316	28	16.00
48	301	29	15.00
48	109	30	10.00
48	385	26	16.00
48	292	14	22.00
48	366	12	8.00
48	20	24	3.00
48	314	17	15.00
48	101	20	22.00
49	130	15	17.00
49	139	22	16.00
49	170	16	13.00
49	263	22	8.00
49	84	24	15.00
49	201	16	4.00
50	330	19	11.00
50	324	14	17.00
50	384	20	24.00
50	87	20	18.00
50	211	20	22.00
50	109	22	10.00
50	382	26	17.00
50	308	11	11.00
50	106	20	24.00
50	392	29	8.00
50	357	22	20.00
50	27	10	20.00
50	4	11	7.00
50	36	10	12.00
50	298	20	24.00
50	293	30	4.00
\.


--
-- TOC entry 3580 (class 0 OID 74072)
-- Dependencies: 247
-- Data for Name: ordermaterials; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.ordermaterials (orderid, materialid, quantity, supplierprice) FROM stdin;
51	1	100	3.50
52	2	200	1.20
53	3	300	0.80
54	4	50	5.00
55	5	120	2.40
\.


--
-- TOC entry 3574 (class 0 OID 65936)
-- Dependencies: 241
-- Data for Name: orders_local; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.orders_local (orderid, orderdate, paymentterms, supplierid) FROM stdin;
1	2025-02-12	מזומן	6
2	2025-01-20	שוטף +30	15
3	2025-03-03	שוטף +60	13
4	2025-03-20	שוטף +60	1
5	2025-03-19	אשראי	3
6	2025-01-30	מזומן	14
7	2025-03-26	שוטף +60	19
8	2025-01-14	תשלומים	20
9	2025-02-09	אשראי	14
10	2025-01-09	אשראי	16
11	2025-03-03	שוטף +30	8
12	2025-03-11	תשלומים	18
13	2025-03-24	אשראי	3
14	2025-03-08	שוטף +30	6
15	2025-01-03	תשלומים	13
16	2025-03-22	תשלומים	8
17	2025-03-21	אשראי	19
18	2025-01-18	תשלומים	15
19	2025-03-17	אשראי	7
20	2025-01-01	שוטף +60	14
21	2025-01-14	שוטף +60	1
22	2025-02-21	שוטף +60	19
23	2025-03-30	שוטף +60	9
24	2025-01-03	מזומן	10
25	2025-02-24	מזומן	3
26	2025-01-05	שוטף +60	5
27	2025-01-25	שוטף +30	3
28	2025-02-11	מזומן	20
29	2025-01-14	תשלומים	20
30	2025-03-12	תשלומים	5
31	2025-03-31	אשראי	19
32	2025-01-10	שוטף +60	13
33	2025-01-29	שוטף +60	3
34	2025-03-10	אשראי	4
35	2025-01-28	אשראי	1
36	2025-02-11	תשלומים	3
37	2025-02-04	אשראי	3
38	2025-01-08	אשראי	20
39	2025-01-04	שוטף +60	8
40	2025-03-14	אשראי	11
41	2025-03-08	שוטף +30	2
42	2025-03-03	מזומן	1
43	2025-02-20	שוטף +30	7
44	2025-03-26	אשראי	10
45	2025-01-05	תשלומים	16
46	2025-03-10	תשלומים	2
47	2025-02-20	אשראי	3
48	2025-03-06	אשראי	10
49	2025-02-14	אשראי	4
50	2025-03-23	מזומן	7
51	2025-05-21	שוטף +60	1
52	2025-05-22	מזומן	3
53	2025-05-23	תשלומים	5
54	2025-05-24	אשראי	7
55	2025-05-25	שוטף +30	9
\.


--
-- TOC entry 3564 (class 0 OID 40976)
-- Dependencies: 223
-- Data for Name: process_equipment; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.process_equipment (equipmentid_, processid_) FROM stdin;
21	202
18	31
36	89
23	233
5	341
5	270
22	53
10	400
18	369
4	107
15	393
1	17
26	150
36	287
21	70
1	147
13	220
33	39
33	275
36	56
8	71
1	315
3	359
21	40
39	205
12	151
39	341
21	339
24	183
26	374
16	377
17	299
31	284
16	396
23	223
28	323
28	215
4	12
14	88
4	185
37	388
6	249
13	145
39	342
21	367
6	253
6	389
35	220
8	11
22	393
30	261
40	26
34	159
4	315
2	239
17	104
18	348
29	168
35	312
2	340
19	15
29	288
1	112
37	182
11	352
28	80
1	345
7	151
15	148
5	30
30	47
22	59
31	209
40	133
6	343
25	385
40	324
8	392
22	79
15	277
40	212
36	134
33	233
18	376
10	343
14	319
5	164
16	73
27	155
5	225
40	43
31	245
26	299
38	15
34	385
5	135
1	164
38	100
37	159
25	358
14	72
33	294
1	314
23	141
28	164
32	177
11	111
22	199
6	286
28	47
20	282
29	180
11	92
26	174
36	85
30	84
10	173
13	121
13	366
11	194
7	18
23	109
30	358
12	18
7	107
30	330
30	323
7	231
5	326
18	127
35	23
10	189
33	7
9	263
38	385
26	46
28	267
32	327
39	51
14	352
32	381
22	305
12	375
8	197
16	7
30	77
19	236
32	394
37	29
10	371
5	171
30	179
14	250
12	144
37	382
33	212
20	108
33	319
6	107
1	78
7	82
20	219
11	49
32	66
10	17
26	131
6	180
16	305
5	252
10	331
31	300
7	164
40	65
32	395
16	334
2	59
13	15
18	315
33	46
36	183
39	49
26	260
6	372
1	335
37	321
7	156
38	43
39	303
37	289
22	12
35	260
1	323
16	186
10	351
34	143
36	130
36	244
19	341
26	78
24	1
38	94
33	246
4	137
34	329
37	396
28	129
10	289
20	136
11	36
20	126
28	303
8	96
10	288
34	269
12	378
4	318
22	138
11	358
7	217
35	193
37	32
3	272
8	88
26	90
15	30
25	318
33	215
23	391
22	169
28	291
39	48
31	398
23	305
25	178
11	367
22	85
20	28
12	183
2	37
29	212
22	120
5	28
21	400
37	49
27	353
12	172
32	80
29	202
16	250
28	93
15	243
38	276
39	236
1	397
35	97
6	268
18	1
23	56
32	316
31	290
16	146
27	109
14	207
36	45
31	279
10	231
2	352
4	183
20	66
38	50
15	307
3	151
28	125
8	335
32	69
18	34
32	297
24	274
26	58
39	232
13	10
10	156
30	286
20	322
31	258
8	176
28	236
5	245
39	234
17	237
12	208
16	107
9	280
24	380
9	307
37	36
24	288
10	175
36	254
5	52
26	82
14	194
6	338
28	10
28	130
27	65
4	265
27	227
37	371
32	204
38	152
8	182
33	102
39	130
2	78
8	165
10	102
33	241
18	196
1	81
17	375
13	31
13	232
8	302
19	35
13	70
22	77
11	6
17	258
25	292
4	83
2	357
27	204
7	71
21	35
26	16
33	207
33	217
14	224
7	297
10	386
25	153
17	388
24	353
39	163
23	207
15	97
38	89
10	66
17	115
9	376
31	19
13	206
24	315
19	107
10	87
34	123
38	211
33	56
10	240
40	218
35	314
20	133
15	186
36	11
13	358
34	82
28	124
31	233
37	130
13	23
20	22
20	364
29	228
32	337
11	135
4	152
8	203
27	49
2	381
10	236
7	86
24	56
10	40
29	123
17	75
20	257
29	241
37	184
28	112
9	258
34	394
8	206
30	383
19	378
34	190
31	66
12	33
30	304
29	198
28	92
40	77
25	27
4	234
15	183
37	235
12	311
38	261
1	103
34	181
18	234
13	348
32	128
26	49
19	380
14	356
38	79
17	43
3	143
35	147
14	304
14	331
18	190
36	345
4	39
27	317
12	145
12	129
6	33
26	189
15	176
37	230
38	206
2	308
19	222
17	123
7	240
31	309
18	336
22	118
8	363
14	179
35	219
37	61
14	158
5	260
22	351
14	285
29	154
20	369
33	81
17	327
17	44
23	243
6	174
13	172
30	187
1	41
24	41
27	189
15	297
24	47
21	24
25	189
2	379
7	228
28	254
18	238
28	210
14	132
16	32
3	119
28	72
19	104
22	191
1	232
35	389
39	318
32	59
6	153
18	239
19	391
36	69
3	324
30	390
5	63
16	157
14	166
30	207
28	224
36	80
27	12
34	271
32	84
17	254
34	240
39	168
31	11
36	120
20	384
23	338
32	57
14	3
33	175
18	29
10	315
16	75
35	211
11	52
15	273
25	396
18	320
11	226
17	55
36	378
35	119
38	330
18	284
8	385
39	350
28	279
31	232
19	144
5	238
6	342
36	250
17	231
12	242
16	251
17	294
21	178
21	198
21	174
9	287
11	200
27	362
36	23
14	144
2	344
28	54
4	384
8	390
35	264
16	116
3	369
4	202
36	174
17	89
34	66
25	155
28	149
37	183
20	395
7	246
19	266
1	231
35	235
18	160
25	341
7	208
37	245
25	293
35	307
12	289
23	10
7	274
15	385
35	73
36	20
37	249
31	212
12	22
25	281
30	131
6	12
14	385
4	59
13	29
16	97
37	210
32	305
10	228
14	270
5	376
40	277
28	208
19	345
40	233
22	109
4	136
15	296
17	366
24	271
30	329
9	327
4	294
19	248
35	357
37	158
3	397
20	200
35	139
37	65
27	278
11	124
2	125
7	234
13	323
1	122
9	121
23	151
15	256
35	198
25	11
11	337
20	152
32	338
9	128
31	23
11	343
32	379
35	356
27	200
26	306
40	226
32	249
25	360
16	196
32	7
25	133
29	389
33	153
24	26
24	202
21	306
14	139
13	100
11	334
31	49
9	28
33	156
25	121
26	56
36	9
22	29
36	138
13	364
4	197
33	186
14	286
29	30
18	208
39	327
19	240
19	180
25	336
39	20
23	41
7	161
2	235
4	84
25	55
10	328
37	313
7	77
14	113
4	212
26	339
4	264
12	381
31	365
36	109
6	344
20	99
25	398
13	228
16	312
9	82
3	116
15	9
38	130
27	241
16	399
3	296
15	191
30	23
14	83
9	25
5	102
2	79
6	159
30	198
36	266
25	236
29	117
4	352
27	377
23	55
8	139
33	281
35	255
14	90
3	367
33	21
29	116
30	107
26	356
12	100
9	99
24	220
18	79
4	191
22	310
1	268
12	3
40	69
4	45
25	33
7	222
20	189
31	308
14	87
37	216
10	31
28	397
24	341
36	74
29	94
7	38
11	3
5	11
19	127
8	186
16	171
36	26
28	263
40	200
38	172
40	301
7	35
29	178
11	363
5	295
21	253
7	196
16	363
9	70
27	222
11	182
5	133
10	77
14	129
13	327
14	203
35	92
32	247
10	339
8	386
15	92
9	255
1	235
4	80
20	229
25	339
12	245
9	1
27	55
24	141
10	170
9	368
12	373
5	72
28	299
21	199
5	142
5	370
3	10
39	31
20	14
20	54
2	38
18	47
7	172
17	278
34	399
23	383
36	171
36	370
22	336
12	200
3	314
25	57
18	274
20	177
32	269
40	156
38	278
36	331
38	160
21	289
22	58
4	93
26	393
27	375
9	326
18	35
18	301
23	5
10	61
36	356
17	280
40	337
14	333
5	256
3	239
21	226
29	190
10	116
19	29
17	34
2	50
12	30
15	293
5	330
23	187
11	66
28	43
32	217
26	320
36	297
26	297
19	300
18	192
4	393
38	59
33	109
17	196
38	32
4	229
19	304
37	149
17	395
18	294
35	85
24	258
10	185
33	237
9	298
31	318
12	67
33	184
24	338
34	280
22	181
17	192
36	224
19	114
36	381
20	223
3	232
19	305
2	345
35	341
21	144
21	348
36	352
33	91
34	276
28	127
5	233
12	156
19	80
9	159
27	98
35	295
10	98
4	251
13	252
23	186
38	273
30	393
22	371
3	85
24	79
38	372
9	345
20	164
8	111
20	263
32	151
39	287
15	254
6	59
29	71
31	196
13	279
31	114
20	64
5	150
34	374
13	149
16	21
7	327
7	97
35	146
30	140
14	330
32	107
23	280
37	45
9	117
16	285
1	283
5	399
27	64
23	327
24	106
13	21
40	222
23	176
15	224
15	20
39	133
36	365
36	93
32	203
36	233
36	384
40	374
1	249
7	272
39	260
18	199
10	89
34	120
7	176
6	150
35	5
18	128
4	23
22	388
11	210
16	235
38	394
30	13
38	316
17	167
40	67
1	327
5	241
36	315
22	370
16	231
14	398
35	176
14	339
10	182
26	244
40	184
23	167
12	275
33	269
7	139
3	260
26	110
35	106
16	382
25	80
19	330
5	194
32	330
15	187
17	16
29	346
40	244
9	142
40	335
25	276
37	377
29	295
28	313
23	333
2	83
24	131
32	5
31	264
32	86
22	229
30	95
22	47
20	261
23	26
17	198
6	86
35	315
9	102
19	322
34	28
32	52
14	16
\.


--
-- TOC entry 3565 (class 0 OID 40979)
-- Dependencies: 224
-- Data for Name: process_materials; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.process_materials (usageamount, processid_, materialid_) FROM stdin;
77	226	2
75	368	9
34	171	4
15	235	6
26	295	3
7	10	5
91	53	6
43	361	10
12	188	6
14	342	5
56	145	5
20	167	9
85	92	6
83	396	10
50	159	7
85	353	2
30	149	4
44	99	5
31	151	5
59	137	2
61	174	9
59	102	8
53	192	10
34	239	3
31	288	10
21	181	9
98	348	3
75	346	7
50	109	7
22	303	3
6	352	1
89	261	9
28	292	2
97	44	3
56	280	1
20	242	2
9	3	9
79	288	4
35	204	6
93	166	10
38	290	5
4	116	9
50	166	4
19	246	4
82	190	9
46	156	1
92	331	1
45	39	1
18	259	5
74	360	10
23	379	9
41	218	8
25	307	6
88	180	1
58	97	7
15	41	1
14	301	9
21	370	3
2	121	1
27	301	7
36	289	10
71	26	3
100	28	2
67	79	10
25	180	7
15	33	9
56	235	5
66	62	9
31	30	3
22	388	6
47	165	7
7	149	6
99	308	5
19	32	9
66	45	6
29	143	9
84	332	8
81	62	7
41	329	2
66	160	4
54	284	2
28	249	9
96	170	7
18	390	10
37	210	3
86	283	1
50	83	6
57	156	10
12	215	7
88	393	3
41	61	3
9	254	5
3	373	6
30	30	2
73	9	5
4	67	7
67	230	10
52	82	4
37	398	5
21	269	6
93	231	7
75	324	10
100	269	8
61	380	5
54	353	8
61	339	4
28	174	3
100	194	3
100	96	1
58	374	8
80	25	1
23	207	2
79	173	1
35	148	1
63	342	4
71	277	10
28	52	3
45	42	4
29	383	9
12	113	6
14	256	8
76	371	2
31	199	1
9	276	8
75	73	2
37	391	10
70	374	6
90	334	6
77	367	10
80	343	3
69	74	5
53	242	6
64	168	2
38	304	5
47	298	7
1	297	9
59	217	2
72	321	4
77	6	4
26	158	9
33	232	5
52	213	8
1	144	7
67	386	3
54	95	1
57	191	3
45	85	3
2	6	3
97	290	4
26	344	7
31	137	6
17	260	6
8	210	6
84	238	8
37	336	4
96	224	8
58	395	8
74	46	10
91	339	5
35	21	10
15	339	8
96	196	10
5	34	8
16	25	7
64	318	2
64	293	6
99	193	3
98	122	6
63	108	10
83	215	9
62	95	10
79	60	5
5	228	2
38	172	7
84	262	5
78	314	2
20	41	2
47	39	10
98	233	5
39	144	8
11	182	5
60	253	5
74	165	4
45	268	2
86	294	3
22	271	2
92	368	1
73	235	10
19	302	6
50	255	8
57	167	7
6	141	4
95	231	6
10	297	1
78	285	10
60	367	5
32	211	8
71	339	9
83	203	8
38	61	7
38	268	6
18	281	3
44	272	6
18	328	9
51	239	8
93	33	3
45	305	7
50	61	4
52	362	8
38	341	5
90	317	8
58	140	10
97	102	5
50	37	7
25	294	4
91	37	6
82	280	8
38	239	6
66	253	8
76	85	4
21	307	10
29	126	7
9	262	10
36	33	5
30	377	10
66	141	6
10	338	9
4	127	3
41	120	4
2	292	7
4	221	6
98	212	9
30	11	10
33	152	1
92	7	9
87	143	7
63	383	7
5	242	5
38	226	5
82	29	10
93	32	1
18	262	4
33	154	5
24	391	5
28	31	2
80	44	4
83	259	8
76	375	3
72	151	9
44	232	1
5	290	9
85	397	10
68	129	5
95	81	5
95	366	5
100	336	2
87	223	9
64	16	10
38	287	7
96	354	1
45	257	2
39	66	8
21	324	3
74	207	7
34	147	10
10	223	7
100	260	3
68	274	10
82	3	8
15	255	1
39	140	5
56	326	4
33	37	9
49	278	2
16	322	5
49	26	4
30	351	5
59	379	5
51	295	10
9	257	5
81	172	3
92	203	9
96	166	5
100	111	4
85	254	2
73	279	10
93	284	8
28	250	1
79	86	6
36	296	8
79	147	3
69	266	10
19	146	2
76	130	9
99	165	8
2	240	8
8	330	9
51	107	1
84	29	1
32	328	6
57	65	3
86	13	7
13	106	9
53	123	10
53	172	6
1	386	8
11	233	7
38	219	10
14	127	7
89	304	4
14	324	7
25	212	5
98	231	5
1	327	9
22	157	10
48	40	5
49	393	9
19	130	6
73	217	4
50	257	10
99	163	3
17	104	10
37	84	5
60	155	6
2	260	5
71	262	6
62	128	5
4	137	10
73	139	7
29	233	3
19	55	1
52	230	9
26	381	4
54	171	8
40	226	8
60	154	8
88	55	7
10	303	8
45	133	3
41	254	3
11	236	9
42	25	2
35	376	9
91	264	7
72	183	10
1	356	5
59	304	3
39	174	1
54	115	6
94	314	4
15	37	3
33	161	2
68	54	5
64	277	9
47	162	4
61	158	1
53	288	2
41	287	10
54	125	2
37	183	6
6	342	2
77	91	10
57	256	5
1	78	7
33	328	10
18	295	1
1	139	5
66	359	1
87	301	1
65	341	8
28	298	4
15	400	3
17	366	6
72	218	9
18	214	10
66	112	4
5	116	5
44	75	9
47	239	9
56	224	3
70	367	3
43	115	9
73	347	1
79	127	6
38	283	8
16	118	10
15	222	1
95	372	1
98	52	8
12	357	1
1	187	1
7	75	4
82	370	8
56	43	6
80	372	5
2	318	5
34	345	10
80	224	4
95	311	5
77	340	7
\.


--
-- TOC entry 3566 (class 0 OID 40982)
-- Dependencies: 225
-- Data for Name: processcontainers; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.processcontainers (containerid_, processid_) FROM stdin;
370	215
226	302
176	5
137	370
52	287
323	316
399	200
378	211
340	251
290	343
389	219
218	2
366	314
124	125
82	373
51	332
246	298
12	146
104	140
136	369
117	272
93	130
253	141
377	190
141	212
103	215
339	88
306	349
394	63
105	392
54	334
135	20
90	296
252	329
2	83
249	391
122	243
254	17
139	234
322	220
245	233
351	301
130	379
95	223
158	218
317	120
341	363
310	392
58	50
39	69
382	41
325	148
97	341
208	255
399	150
278	368
99	352
37	84
6	30
93	239
32	123
210	58
257	142
338	4
203	327
174	147
41	68
66	158
317	194
88	76
300	352
191	67
265	265
68	112
274	277
347	269
84	379
320	164
306	285
386	50
52	118
259	73
127	135
54	358
380	262
282	311
351	275
161	110
382	171
317	95
296	4
351	315
336	340
229	7
398	143
382	132
171	267
281	207
236	143
95	258
161	302
342	198
394	230
147	164
65	337
396	46
72	162
109	219
35	212
205	36
394	366
136	76
118	348
237	311
376	336
18	116
52	1
175	14
66	21
342	352
164	135
269	15
241	378
62	47
198	15
267	287
352	115
358	160
209	239
240	223
42	162
397	47
251	48
211	125
146	18
89	138
86	301
94	393
96	128
127	361
121	63
294	212
96	151
392	67
15	34
279	35
334	249
316	174
315	2
337	345
385	7
1	214
97	228
67	76
6	77
279	179
369	40
333	375
139	132
310	150
132	360
149	324
147	330
228	345
155	304
113	268
364	31
390	276
396	71
203	246
79	329
219	36
300	111
275	324
394	155
61	176
261	82
304	364
348	80
107	96
316	239
18	155
17	106
278	108
365	289
188	311
180	378
342	26
157	268
131	228
398	343
361	53
116	225
178	31
274	157
254	220
250	76
129	204
2	96
353	335
398	248
26	12
222	226
182	116
65	237
21	226
387	393
296	72
108	157
167	272
191	7
389	340
299	23
118	242
393	110
48	148
46	304
11	311
313	209
70	261
43	124
184	260
394	8
100	308
279	315
107	128
53	97
164	341
342	51
387	198
252	354
266	48
363	209
166	358
363	85
263	169
54	260
209	341
36	110
293	378
270	49
54	185
257	277
85	102
36	19
114	150
277	152
180	215
89	256
375	32
44	31
392	293
388	273
183	342
263	188
10	375
355	300
334	1
302	297
262	283
388	379
136	261
363	283
271	277
26	54
317	112
389	368
52	262
322	21
159	344
273	211
133	74
381	299
237	138
207	389
370	222
69	203
76	111
263	92
299	387
211	47
330	147
279	369
265	212
20	312
212	1
372	384
157	108
46	254
185	229
76	237
345	322
336	209
161	291
382	381
219	93
121	142
92	346
36	279
68	20
185	305
139	84
57	179
105	100
264	145
185	221
37	171
50	316
61	229
83	167
396	299
130	74
285	75
321	183
60	132
396	368
285	230
17	309
397	334
22	375
313	85
95	86
109	168
369	81
96	62
103	359
157	284
105	183
240	129
148	19
325	157
380	64
270	297
320	254
346	154
347	182
68	274
305	250
323	293
112	394
167	260
320	81
138	35
67	101
204	363
312	309
316	58
312	28
7	326
163	98
183	202
192	245
242	320
109	138
129	189
188	306
108	97
245	226
358	257
317	60
386	395
191	287
169	371
222	338
7	2
306	135
399	191
324	339
268	53
255	355
139	144
85	235
232	193
163	268
240	292
93	139
268	306
17	165
348	216
51	160
237	123
238	277
146	292
364	25
32	144
189	252
303	271
160	226
175	188
367	234
103	263
324	155
363	357
142	372
212	162
71	315
182	280
274	175
266	342
190	247
213	62
112	373
89	357
111	94
200	171
288	195
122	349
377	250
384	388
137	106
305	116
167	56
126	241
310	390
192	382
388	165
38	281
391	247
308	190
297	221
117	349
202	22
140	56
287	254
95	72
62	29
86	74
31	94
45	147
19	10
376	14
112	332
348	146
81	153
378	214
249	96
399	236
149	136
126	133
342	217
305	47
325	91
285	266
132	269
38	280
12	240
251	157
168	374
63	315
221	59
184	245
49	283
169	298
396	292
400	112
288	119
246	95
346	317
163	205
50	42
22	82
232	258
114	175
341	375
241	382
250	40
280	208
180	229
315	388
29	230
157	223
270	241
68	109
43	22
228	195
241	165
351	283
30	103
328	379
265	365
244	44
50	359
98	324
3	296
194	45
8	291
23	72
144	132
192	147
311	109
274	358
368	284
143	34
377	109
197	217
286	36
59	232
317	90
270	308
167	25
67	149
208	252
112	167
58	78
230	72
54	112
260	48
276	235
288	40
58	345
274	325
271	84
326	398
328	100
273	43
301	146
373	163
195	26
130	352
377	360
267	283
309	389
137	278
212	98
3	345
158	213
281	102
75	212
292	67
101	195
331	329
247	179
297	400
391	176
206	87
48	398
317	365
174	6
2	232
363	163
346	126
96	60
354	162
231	282
46	225
380	353
238	190
379	314
317	122
270	178
352	306
16	347
114	76
205	4
75	116
228	123
16	94
295	379
286	248
248	131
354	261
373	7
375	7
75	361
143	304
119	331
330	293
49	314
388	107
19	58
150	308
196	94
334	120
168	340
55	22
70	338
195	334
62	27
191	334
119	173
277	56
8	107
224	1
272	209
301	215
38	220
316	247
189	398
129	90
55	247
309	67
200	154
333	107
312	120
223	292
85	117
244	400
160	180
295	339
272	251
2	177
274	118
255	375
391	140
314	394
307	318
153	168
2	28
52	294
197	92
274	375
396	64
322	261
353	320
43	107
80	398
321	389
275	142
161	340
214	326
262	330
257	338
308	131
366	159
164	1
52	48
153	359
257	221
347	259
21	302
362	14
54	264
19	60
17	162
36	147
22	351
208	311
368	227
192	360
177	28
113	165
388	80
92	328
108	306
33	26
55	86
53	50
221	54
158	245
92	116
274	197
264	272
107	149
189	234
377	245
129	125
318	300
119	306
4	38
232	326
130	12
320	104
331	276
72	56
286	158
151	31
36	390
127	395
152	69
378	52
297	169
340	365
97	385
70	314
34	282
311	171
121	12
77	177
115	200
76	235
23	125
334	303
128	155
259	81
115	239
66	42
175	334
265	216
110	117
283	76
170	19
345	152
288	203
49	171
356	349
15	189
6	316
377	396
187	270
192	185
246	301
257	349
276	289
97	231
348	259
332	351
68	166
328	145
170	307
228	233
67	254
150	42
252	1
195	99
207	47
176	368
81	384
215	305
249	286
311	228
391	203
334	221
243	338
321	196
285	88
334	273
268	109
82	217
156	371
125	311
295	130
17	47
316	331
215	329
190	123
162	29
50	170
396	314
110	217
306	346
391	54
306	128
265	273
91	316
1	10
164	294
337	64
373	56
66	367
342	355
326	123
171	228
269	13
334	149
20	54
268	154
184	391
301	114
393	54
7	360
322	250
41	21
258	299
133	285
312	264
283	361
102	130
259	283
178	360
4	114
296	66
22	80
194	165
188	229
362	377
223	128
193	178
1	113
215	72
356	231
290	258
22	10
223	258
205	382
196	313
6	283
248	331
74	77
270	173
321	216
393	194
79	60
217	286
202	163
58	391
287	318
61	216
126	22
390	107
98	71
217	257
226	69
253	185
390	48
325	133
249	297
398	370
319	26
295	211
155	50
261	243
181	63
66	252
165	386
175	283
286	153
200	132
379	337
157	137
84	192
35	361
62	114
62	111
130	48
324	307
50	120
294	22
345	133
237	115
237	13
96	50
344	136
270	63
97	315
384	160
15	192
32	17
183	132
370	197
63	266
119	278
143	257
41	130
71	261
207	260
95	253
85	29
213	110
398	32
45	394
288	194
6	251
132	153
93	223
310	144
289	116
121	56
272	113
202	11
366	166
74	302
207	19
1	300
107	106
144	7
232	188
365	326
176	21
276	226
223	84
216	24
196	205
390	270
266	39
354	269
39	279
277	4
44	6
107	269
271	238
44	107
114	331
397	161
329	318
279	19
132	172
225	15
15	168
346	140
82	197
62	362
151	390
264	91
400	263
126	158
227	210
365	78
378	119
249	162
16	248
144	190
259	334
289	335
3	163
103	109
394	305
255	231
331	50
286	362
78	166
44	222
15	375
234	79
194	96
110	320
20	305
177	151
269	100
52	29
28	352
15	99
81	140
332	47
349	314
240	354
31	227
27	271
234	263
200	352
166	200
1	292
267	50
227	259
156	216
345	397
58	170
384	156
103	365
397	298
218	3
211	129
369	189
218	292
101	379
206	7
158	327
164	259
374	173
277	143
172	1
51	29
162	3
21	340
299	261
329	306
386	294
118	259
279	174
273	167
201	320
385	372
64	231
369	128
21	338
119	119
299	205
2	123
90	298
11	163
305	137
45	61
219	318
340	391
205	179
170	390
254	12
281	297
368	216
82	285
143	288
337	37
176	123
385	356
277	304
386	202
110	125
148	62
241	359
326	29
77	231
285	308
31	61
354	176
122	38
191	187
363	154
134	84
342	236
305	8
106	276
\.


--
-- TOC entry 3573 (class 0 OID 65931)
-- Dependencies: 240
-- Data for Name: product_local; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.product_local (productid, productname, price, brand, stockquantity, last_updated) FROM stdin;
3	מאפה בצל	50.00	מאפיית ישן	27	\N
4	עוגה	15.00	אחוה	188	\N
5	שמנת חמוצה	18.00	אלטרנטיבה	70	\N
6	סלטים	30.00	אדום חם	79	\N
7	חומוס יבש	31.00	רמי לוי	199	\N
8	פיתות עיראקיות	41.00	דודו	111	\N
9	תפוחי אדמה	15.00	ביסי	100	\N
10	הדס	16.00	ההום	179	\N
11	פתיתים	6.00	גבעי	79	\N
12	קוטג דל שומן	32.00	יטבתה	14	\N
13	פול	22.00	קוסמו	193	\N
15	חלב	47.00	אלטרנטיבה	29	\N
18	קפיר	30.00	אביב	26	\N
19	חטיף שוקולד	35.00	חפלה	129	\N
21	לחם קרואסון	32.00	דודו	149	\N
22	מיץ אננס	24.00	פריגת	67	\N
23	מיץ תפוזים	42.00	קוקה	171	\N
24	עכסים	38.00	גבעי	36	\N
25	דיאט קולה	46.00	זוהר	46	\N
26	פופקורן	11.00	כרמית	170	\N
27	חלב בטעמים	41.00	יטבתה	114	\N
29	חטיף תירס	29.00	הדר	80	\N
30	מוצרלה	40.00	אלטרנטיבה	17	\N
31	אפונה	19.00	אדום חם	155	\N
32	ספרייט	50.00	נסטי	179	\N
33	במבה	36.00	רגליה	127	\N
34	צהובה	8.00	טרה	167	\N
35	מים טהורים	22.00	נקש	50	\N
37	פיתות עיראקיות	19.00	מאפיית תמר	194	\N
38	פלאפל	17.00	ההום	143	\N
39	יוגורט פרי	43.00	הכפר	17	\N
40	פלאפל	45.00	וילי	157	\N
41	מלפפונים	7.00	ההום	151	\N
42	קטניות חלב	28.00	שופרסל	112	\N
43	מיץ ענבים	11.00	קוקה	189	\N
44	לחם חלום	41.00	אחוה	16	\N
45	במבה קלאסי	45.00	אסם	58	\N
48	טורטית	10.00	רויאל	198	\N
53	מסקרפונה	13.00	נבלום	40	\N
55	יוגורט פירות	22.00	זוהר	156	\N
56	גריסים	10.00	שופרסל	184	\N
57	אפונה	14.00	דוש	180	\N
58	שעועית ירוקה	41.00	דוש	172	\N
60	שוקולד חלב	38.00	קונצרט	10	\N
61	מיץ לימון	7.00	נסטי	79	\N
62	כוסמת	37.00	המטוס	117	\N
63	פיתות סבתא	34.00	מאפיית ישן	117	\N
64	בירה לאלפיים	25.00	גבע	47	\N
67	מים טהורים	25.00	גבע	146	\N
68	מיץ קיווי	34.00	נענע	110	\N
69	חומוס	49.00	רמי לוי	30	\N
72	ספגטי	37.00	יכין	26	\N
73	פלאפל	45.00	סוגת	57	\N
74	פטריות	12.00	שופרסל	74	\N
75	לחם	31.00	פיתות רונן	35	\N
76	מיץ אננס	42.00	קוקה	36	\N
77	גבינה	20.00	אביב	59	\N
78	פטה	33.00	נבלום	39	\N
79	פיצה פריזאית	32.00	דודו	71	\N
80	מיץ אפרסק	16.00	נענע	111	\N
82	קינואה	46.00	רמי לוי	101	\N
83	תפוזים	8.00	נסטי	113	\N
84	עדשים	31.00	הגיבעתי	143	\N
85	חומוס טחינה	28.00	וילי	167	\N
86	פתיתים	48.00	סוגת	143	\N
87	בגט	36.00	מאפיית א.ר.	171	\N
88	חטיף חלווה	14.00	טווינקס	180	\N
89	פול חום	10.00	הגיבעתי	47	\N
90	סוכריות	37.00	טווינקס	53	\N
91	שיפון מלא	7.00	מאפיית א.ר.	184	\N
92	נסטי	26.00	זוהר	182	\N
93	קרמבו	43.00	רגליה	87	\N
94	מיץ קיווי	37.00	יפאורה	98	\N
95	גריסים	15.00	הגיבעתי	95	\N
97	רסק	5.00	ההום	122	\N
98	חלב בטעמים	12.00	גד	63	\N
100	מיץ תפוזים	42.00	ספרינג	196	\N
101	חטיף שוקולד	45.00	אסם	22	\N
103	יוגורט	49.00	תנובה	26	\N
104	פיצה פריזאית	29.00	מאפיית רפאל	70	\N
105	אורז בר	44.00	סוגת	92	\N
106	מים מוגזים	49.00	קימח	193	\N
107	בגט	41.00	לייזר	194	\N
108	ביסקוויטים	39.00	מטה	34	\N
109	שמנת מתוקה	20.00	אביב	97	\N
111	שמנת מתוקה	16.00	אלטרנטיבה	157	\N
1	מיץ גזר	39.00	גבע	28	2025-05-26 20:33:42.21475
112	ספרייט	11.00	נקש	49	\N
113	רסק אמצעי	18.00	רמי לוי	83	\N
114	יוגורט	47.00	יטבתה	199	\N
116	ספגטי	28.00	ההום	48	\N
118	תפוחים ירוקים	7.00	המטוס	35	\N
120	פיצוחים	20.00	קונצרט	188	\N
122	בורגול	29.00	גבעי	36	\N
123	ספגטי	50.00	דוש	193	\N
124	חלב שקדים	49.00	אלטרנטיבה	183	\N
126	חומוס יבש	39.00	קוסמו	62	\N
128	ביסקוויטים	7.00	עלית	134	\N
129	חטיף שוקולד	34.00	עלית	141	\N
132	במבה	46.00	טווינקס	126	\N
133	במבה קלאסי	48.00	קונצרט	121	\N
134	פסק זמן	17.00	קונצרט	124	\N
135	תירס	33.00	ביסי	147	\N
136	בורגול	10.00	ביסי	56	\N
137	סלטים	32.00	דוש	108	\N
141	מיץ תפוזים	12.00	נענע	132	\N
142	עוגה	13.00	מאפיית ישן	179	\N
143	הדס	17.00	וילי	178	\N
144	סוכריות גומי	46.00	רגליה	53	\N
145	פיתות זעתר	27.00	מאפיית דבורה	150	\N
146	מסקרפונה	33.00	אלטרנטיבה	82	\N
147	חלב עיזים	40.00	זוהר	186	\N
148	תפוחים ירוקים	16.00	עוקב	61	\N
150	שמנת	9.00	זוהר	64	\N
151	קוטג 5%	27.00	יטבתה	56	\N
152	קרמל מלוח	40.00	רגליה	181	\N
153	לחם אגוזים	30.00	מאפיית תמר	34	\N
155	קטניות חלב	40.00	רמי לוי	135	\N
156	חומוס טחינה	28.00	דוש	19	\N
158	מיני שוקולד	22.00	כרמית	182	\N
159	תירס	49.00	דוש	35	\N
160	לחם כוסמין	48.00	אנגל	94	\N
161	ממרח טחינה	23.00	אדום חם	49	\N
162	קרמל מלוח	32.00	אסם	16	\N
163	סרדינים	5.00	אדום חם	198	\N
165	פול	40.00	רמי לוי	60	\N
166	לחם גרעינים	37.00	מאפיית א.ר.	200	\N
167	מוצרלה	43.00	יטבתה	113	\N
168	שעועית ירוקה	27.00	רמי לוי	120	\N
169	מיץ תפוחים	9.00	נענע	112	\N
170	מיץ ענבים	27.00	פריגת	92	\N
171	יוגורט טבעי	21.00	תנובה	43	\N
172	לחם עם זיתים	6.00	אחוה	117	\N
173	פירות חתוכים	48.00	שופרסל	18	\N
174	מיץ דובדבן	12.00	זוהר	53	\N
175	רסק אמצעי	25.00	שירן	176	\N
176	תפוא מוקרמים	6.00	שופרסל	28	\N
177	במבה קלאסי	45.00	הדר	69	\N
178	פלאפל	39.00	דוש	89	\N
179	קפה קר	35.00	נסטי	80	\N
180	תפוחי אדמה	6.00	דוש	200	\N
181	קרמבו	8.00	מטה	136	\N
182	בורגול דק	17.00	המטוס	189	\N
184	שימורי פירות	35.00	יכין	28	\N
186	ביסלי	32.00	קונצרט	136	\N
187	פיצוחים	39.00	מטה	107	\N
188	זיתים	25.00	שופרסל	45	\N
189	שעועית	8.00	רמי לוי	165	\N
190	פסטה	15.00	שופרסל	139	\N
191	סודה	19.00	זוהר	137	\N
192	קוטג 5%	26.00	זוהר	182	\N
193	תירס	6.00	פריניב	51	\N
194	שמנת מתוקה	11.00	תנובה	164	\N
195	שמנת 38%	42.00	זוהר	180	\N
196	מיצים טבעיים	9.00	גבע	64	\N
197	כיף כף	25.00	רויאל	132	\N
198	לחמניות	44.00	מאפיית רפאל	21	\N
199	שימורי פירות	48.00	שירן	13	\N
201	פסטה אגוזית	8.00	רמי לוי	160	\N
202	מלפפונים	30.00	רמי לוי	18	\N
203	חטיף גרנולה	32.00	קונצרט	128	\N
204	תפוא מוקרמים	7.00	שירן	144	\N
205	פסטה פיקנטית	13.00	יכין	65	\N
206	לחם שומשום	46.00	מאפיית ישן	124	\N
207	קרמבו	30.00	כרמית	39	\N
208	כוסמת	47.00	עוקב	27	\N
209	תפוחי אדמה	10.00	סיוול	143	\N
210	מאפה בורשט	47.00	ברמן	51	\N
211	קוסקוס	44.00	סוגת	143	\N
212	פיתות זעתר	23.00	מאפיית ישן	50	\N
213	ספרייט	46.00	יפאורה	28	\N
215	מיץ רימונים	8.00	נקש	24	\N
216	משקה אנרגיה	21.00	גבע	170	\N
217	יוגורט טבעי	48.00	הכפר	136	\N
218	פיתות סבתא	48.00	אחוה	85	\N
220	חלב שקדים	6.00	הכפר	34	\N
221	קוטג דל שומן	50.00	גד	25	\N
223	שמנת 38%	35.00	שטראוס	100	\N
224	שעועית	23.00	אדום חם	76	\N
225	פירות חתוכים	40.00	אדום חם	155	\N
226	חלב	28.00	הכפר	106	\N
228	בגט	10.00	מאפיית ישן	54	\N
229	חלב בטעמים	28.00	טרה	65	\N
231	מיץ דובדבן	37.00	גבע	134	\N
232	אורז בר	31.00	קוסמו	38	\N
233	לחם מלא	30.00	מאפיית דבורה	44	\N
234	לחם עם זיתים	46.00	לייזר	128	\N
238	מיץ לימון	21.00	נקש	54	\N
239	פסטה אגוזית	15.00	קוסמו	122	\N
240	קוטג 5%	41.00	גד	175	\N
241	חטיף מלוח	15.00	קונצרט	128	\N
242	במבה קלאסי	26.00	חפלה	117	\N
243	מסקרפונה	42.00	שטראוס	189	\N
244	לחם קרואסון	26.00	מאפיית תמר	77	\N
245	מסקרפונה	8.00	גד	11	\N
246	חומוס	50.00	שופרסל	61	\N
247	שתייה מוגזת	17.00	פריגת	37	\N
249	סלט ירקות	31.00	ההום	78	\N
250	חמצוצים	29.00	הדר	131	\N
251	רסק	14.00	וילי	121	\N
252	קפה קר	31.00	גבע	139	\N
253	ספרייט	42.00	זוהר	98	\N
254	חלב סויה	18.00	יטבתה	83	\N
255	שיפון מלא	46.00	פיתות רונן	43	\N
256	קרואסון	42.00	אנגל	53	\N
257	חטיף תירס	12.00	קונצרט	196	\N
258	תירס	6.00	וילי	156	\N
259	קוסקוס מלא	34.00	הגיבעתי	22	\N
260	חטיף תירס	5.00	מטה	38	\N
261	קפה קר	6.00	קוקה	48	\N
262	ריוויון	22.00	יטבתה	71	\N
266	כיף כף	45.00	חפלה	197	\N
267	רסק עגבניות	20.00	שירן	102	\N
269	משקה אנרגיה	32.00	נסטי	165	\N
270	גריסים	15.00	סיוול	65	\N
271	טוסט	13.00	לייזר	199	\N
272	בורקס	35.00	מאפיית ישן	165	\N
273	פסק זמן	40.00	חפלה	178	\N
274	סלט ירקות	10.00	יכין	136	\N
275	לחם גרעינים	9.00	אחוה	68	\N
276	תפוא מוקרמים	26.00	אדום חם	60	\N
277	בורגול	35.00	שופרסל	156	\N
278	קפה קר	47.00	פריגת	66	\N
279	חומוס יבש	23.00	הגיבעתי	152	\N
280	יוגורט פירות	50.00	גד	19	\N
282	תירס מתוק	41.00	סוגת	119	\N
283	חלב שקדים	20.00	זוהר	28	\N
284	מיץ גזר	49.00	נסטי	68	\N
285	מסטיקים	48.00	הדר	177	\N
286	הדס	17.00	פריניב	86	\N
287	מיץ אננס	42.00	נענע	19	\N
288	יוגורט פירות	47.00	אביב	143	\N
289	ריוויון	29.00	שטראוס	168	\N
291	מסקרפונה	39.00	זוהר	195	\N
293	שתייה מוגזת	8.00	נסטי	81	\N
294	פול חום	41.00	קוסמו	75	\N
295	משקה אנרגיה	25.00	פריגת	59	\N
296	פיתות	20.00	מאפיית רפאל	147	\N
297	פיתות עיראקיות	23.00	לייזר	110	\N
298	פיצה פריזאית	49.00	אחוה	161	\N
299	לחם כוסמין	36.00	לייזר	159	\N
300	ניסקו	23.00	יפאורה	166	\N
301	שמנת שמנת	31.00	אלטרנטיבה	193	\N
302	יוגורט פירות	15.00	שטראוס	57	\N
303	מיץ תפוחים	37.00	זוהר	177	\N
304	לחם חלום	10.00	לייזר	70	\N
305	פיתה	27.00	מאפיית דבורה	69	\N
306	באגט מרוקאי	42.00	לייזר	16	\N
307	תפוחי אדמה	7.00	גבעי	81	\N
309	קוטג דל שומן	44.00	אלטרנטיבה	176	\N
310	פיתות	12.00	לייזר	196	\N
312	מיץ תפוזים	21.00	נסטי	195	\N
313	שמנת	48.00	אלטרנטיבה	113	\N
314	לחם שומשום	30.00	לייזר	185	\N
315	שמנת חמוצה	49.00	הכפר	84	\N
317	עכסים	40.00	הגיבעתי	92	\N
318	פופקורן	14.00	רויאל	85	\N
319	תירס	47.00	רמי לוי	31	\N
321	פיתה	10.00	מאפיית תמר	169	\N
322	עדשים	41.00	עוקב	92	\N
323	לחם שומשום	6.00	ברמן	90	\N
324	עוגיות	34.00	כרמית	50	\N
325	סוכריות	23.00	קונצרט	125	\N
326	עדשים	44.00	קוסמו	200	\N
327	יוגורט דל שומן	8.00	נבלום	179	\N
328	בורקס	42.00	אחוה	117	\N
329	פתיתים	46.00	ביסי	71	\N
332	חמאה	48.00	זוהר	68	\N
334	חטיף חמאה	50.00	טווינקס	28	\N
335	פלאפל	27.00	אדום חם	22	\N
336	שמנת שמנת	39.00	שטראוס	33	\N
337	רסק אמצעי	10.00	ההום	43	\N
338	חטיף גרנולה	26.00	אסם	101	\N
339	פירות חתוכים	45.00	רמי לוי	154	\N
340	יוגורט פרי	23.00	תנובה	63	\N
341	זיתים	48.00	אדום חם	120	\N
342	סוכריות	44.00	כרמית	13	\N
343	לחם עם זיתים	10.00	דודו	181	\N
344	סלט ירקות	18.00	רמי לוי	71	\N
345	קרואסון	16.00	ברמן	193	\N
346	ניסקו	17.00	ספרינג	57	\N
350	טונה	8.00	ההום	101	\N
351	קולה	18.00	נקש	89	\N
352	חומוס טחינה	31.00	סוגת	112	\N
353	ניסקו	46.00	קימח	61	\N
354	מיץ ענבים	40.00	זוהר	79	\N
355	ניסקו	47.00	פריגת	170	\N
357	מיץ תפוזים	41.00	נקש	28	\N
358	קוטג 5%	30.00	תנובה	100	\N
359	לחמניות	46.00	אנגל	29	\N
361	לחם עם זיתים	40.00	מאפיית ישן	49	\N
362	במבה	32.00	חפלה	137	\N
363	יוגורט	19.00	אביב	48	\N
364	חטיף סויה	14.00	חפלה	60	\N
367	בורקס	42.00	דודו	32	\N
368	חלב	5.00	נבלום	126	\N
369	פיתות עיראקיות	18.00	פיתות רונן	179	\N
370	קוסקוס מלא	5.00	המטוס	130	\N
371	מאפה בורשט	38.00	פיתות רונן	30	\N
372	מיץ מנגו	46.00	פריגת	139	\N
373	מסטיקים	6.00	מטה	25	\N
374	חומוס	40.00	פריניב	155	\N
375	מאפה קינמון	16.00	מאפיית דבורה	53	\N
376	אורז	18.00	רמי לוי	59	\N
378	מיצים טבעיים	29.00	נקש	199	\N
379	מיץ תפוחים	6.00	פריגת	24	\N
380	מלפפונים	24.00	פריניב	196	\N
381	מיץ מנגו	27.00	קימח	140	\N
382	פסק זמן	35.00	רגליה	80	\N
383	עדשים	27.00	סוגת	126	\N
384	פיתה	48.00	דודו	90	\N
385	שמנת חמוצה	32.00	נבלום	118	\N
387	פיתות זעתר	25.00	אנגל	92	\N
388	לחם שומשום	8.00	מאפיית תמר	65	\N
389	חלב בטעמים	28.00	שטראוס	148	\N
391	פול חום	5.00	שופרסל	125	\N
392	חלב	17.00	אביב	57	\N
393	פטריות טריות	22.00	אדום חם	102	\N
395	עדשים	43.00	ביסי	141	\N
398	לחם כוסמין	40.00	אחוה	43	\N
399	חלב סויה	7.00	הכפר	63	\N
400	לחם שיפון	6.00	לייזר	124	\N
401	Barbera	32.50	Modernet	100	\N
402	Dolcetto	28.00	Modernet	120	\N
403	Gamay	29.90	Modernet	90	\N
404	Malbec	33.00	Modernet	110	\N
405	Merlot	31.00	Modernet	80	\N
406	Pinot Noir	35.50	Modernet	95	\N
407	Riesling	30.00	Modernet	105	\N
408	Syrah	34.00	Modernet	115	\N
14	שיפון מלא	27.82	מאפיית תמר	172	\N
200	כוסמת	34.24	גבעי	54	\N
102	לחם	21.40	דודו	94	\N
119	פלאפל	42.80	שירן	43	\N
47	עוגה	43.87	פיתות רונן	70	\N
219	עוגיות	9.63	מטה	125	\N
236	קפיר	52.43	גד	107	\N
183	קוטג 5%	53.50	הכפר	45	\N
59	גריסים	31.03	סוגת	112	\N
46	לחם	14.98	מאפיית רפאל	135	\N
264	בירה לאלפיים	42.80	ספרינג	19	\N
52	תפוחי אדמה	27.82	סוגת	92	\N
131	יוגורט טבעי	5.35	גד	106	\N
17	טוסט	11.77	מאפיית ישן	130	\N
281	קפה קר	19.26	יפאורה	67	\N
154	במבה קלאסי	28.89	רויאל	30	\N
386	לחם עם זיתים	49.22	מאפיית תמר	60	\N
214	לחם מלא	27.82	לייזר	108	\N
308	פול	24.61	שופרסל	31	\N
227	חטיף חלווה	5.35	קונצרט	92	\N
140	יוגורט פירות	7.49	טרה	71	\N
51	מיץ לימון	48.15	קוקה	141	\N
222	עוגיות	11.77	קונצרט	95	\N
320	חומוס יבש	23.54	עוקב	83	\N
117	לחם חלום	49.23	מאפיית רפאל	112	\N
333	תירס מתוק	28.89	קוסמו	75	\N
235	לחמניות	6.42	מאפיית א.ר.	73	\N
164	עכסים	37.45	המטוס	177	\N
316	פיתות עיראקיות	35.31	אחוה	46	\N
311	במבה	51.36	עלית	18	\N
331	מיץ לימון	37.45	נענע	113	\N
230	רסק עגבניות	24.61	יכין	123	\N
248	מיץ אבטיח	11.45	קוקה	43	\N
185	פתיתים	20.33	הגיבעתי	53	\N
81	צהובה	52.43	יטבתה	197	\N
290	לחם	21.40	מאפיית דבורה	166	\N
397	תירס מתוק	8.56	גבעי	34	\N
356	שוקולד	47.08	קונצרט	113	\N
36	סוכריות	26.75	הדר	91	\N
157	פטריות	20.33	שירן	19	\N
127	תירס	44.94	סיוול	32	\N
125	פירות חתוכים	16.05	שירן	156	\N
263	קמח תפוּח	18.19	המטוס	85	\N
28	קפיר	11.77	נבלום	59	\N
330	פיתה	23.54	ברמן	151	\N
70	טונה	16.05	דוש	58	\N
2	צהובה	35.31	זוהר	62	\N
377	משקה אנרגיה	7.49	זוהר	60	\N
121	חומוס טחינה	9.63	שופרסל	49	\N
99	בורגול	44.94	רמי לוי	56	\N
390	תירס	18.37	גבעי	154	\N
71	שיפון מלא	48.15	אנגל	134	\N
130	חטיף תירס	36.38	אסם	125	\N
149	תירס	42.80	קוסמו	152	\N
20	חטיף תירס	6.42	חפלה	137	\N
139	שעועית ירוקה	34.24	סוגת	65	\N
50	פיתות זעתר	20.33	ברמן	174	\N
49	פטריות	48.15	אדום חם	156	\N
138	חטיף חמאה	14.98	חפלה	135	\N
396	סוכריות	11.45	אסם	165	\N
360	פול חום	20.61	המטוס	186	\N
16	לחם אגוזים	10.70	אחוה	27	\N
110	קוסקוס מלא	14.98	קוסמו	197	\N
66	הדס	11.77	יכין	179	\N
394	חטיף גרנולה	33.20	הדר	196	\N
237	מאפה בורשט	23.54	מאפיית רפאל	173	\N
349	פטריות טריות	26.75	דוש	185	\N
347	חטיף סויה	8.56	מטה	43	\N
268	מים	50.29	ספרינג	96	\N
348	שיפון מלא	50.29	מאפיית ישן	26	\N
96	לחם שומשום	46.01	פיתות רונן	105	\N
265	רבע לשבע	17.17	הדר	40	\N
54	טורטית	52.67	הדר	112	\N
115	מיץ לימון	34.24	זוהר	158	\N
366	בורקס	17.12	מאפיית רפאל	70	\N
292	מסקרפונה	47.08	הכפר	24	\N
65	קרמבו	34.24	קונצרט	121	\N
365	פול חום	49.22	סוגת	74	\N
\.


--
-- TOC entry 3567 (class 0 OID 40985)
-- Dependencies: 226
-- Data for Name: productionequipment_; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.productionequipment_ (equipmentid_, type_, status_) FROM stdin;
1	Stirrer   	repair
2	Filter    	repair
3	Hose      	retired
4	Tank      	active
5	Conveyor  	retired
6	Barrel    	retired
7	Stirrer   	active
8	Pump      	repair
9	Crusher   	repair
10	Washer    	repair
11	Barrel    	active
12	Filter    	retired
13	Tank      	active
14	Filter    	active
15	Pump      	repair
16	Hose      	active
17	Tank      	retired
18	Crusher   	retired
19	Stirrer   	retired
20	Hose      	repair
21	Pump      	repair
22	Tank      	active
23	Hose      	retired
24	Stirrer   	repair
25	Pump      	repair
26	Crusher   	repair
27	Washer    	retired
28	Conveyor  	retired
29	Stirrer   	repair
30	Barrel    	retired
31	Crusher   	retired
32	Barrel    	repair
33	Crusher   	repair
34	Fermenter 	active
35	Filter    	repair
36	Tank      	repair
37	Filter    	active
38	Filter    	repair
39	Pump      	active
40	Filter    	repair
\.


--
-- TOC entry 3568 (class 0 OID 40988)
-- Dependencies: 227
-- Data for Name: productionprocess_; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.productionprocess_ (processid_, type_, startdate_, enddate_, seqnumber, grapeid, employeeid, batchnumber_) FROM stdin;
2	2	2024-02-07	2024-02-09	2	9	16	228
3	3	2024-02-12	2024-02-14	3	1	22	228
4	4	2024-02-17	2024-02-20	4	1	41	228
5	1	2024-02-15	2024-02-18	1	8	46	289
6	2	2024-02-20	2024-02-23	2	3	12	289
7	3	2024-02-25	2024-02-28	3	2	10	289
8	4	2024-03-01	2024-03-03	4	1	39	289
9	1	2024-02-12	2024-02-13	1	10	38	202
10	2	2024-02-17	2024-02-19	2	2	18	202
11	3	2024-02-22	2024-02-25	3	7	3	202
12	4	2024-02-27	2024-03-01	4	9	23	202
13	1	2024-01-31	2024-02-02	1	8	1	226
14	2	2024-02-05	2024-02-07	2	7	17	226
15	3	2024-02-10	2024-02-13	3	7	17	226
16	4	2024-02-15	2024-02-17	4	3	33	226
17	1	2024-01-02	2024-01-03	1	8	24	399
18	2	2024-01-07	2024-01-09	2	7	1	399
19	3	2024-01-12	2024-01-14	3	1	13	399
20	4	2024-01-17	2024-01-19	4	8	14	399
21	1	2024-03-14	2024-03-17	1	5	16	68
22	2	2024-03-19	2024-03-22	2	8	37	68
23	3	2024-03-24	2024-03-25	3	8	34	68
24	4	2024-03-29	2024-03-30	4	5	3	68
25	1	2024-01-29	2024-01-31	1	1	20	15
26	2	2024-02-03	2024-02-04	2	1	6	15
27	3	2024-02-08	2024-02-09	3	2	33	15
28	4	2024-02-13	2024-02-16	4	6	28	15
29	1	2024-01-29	2024-01-31	1	8	44	221
30	2	2024-02-03	2024-02-04	2	7	3	221
31	3	2024-02-08	2024-02-09	3	10	45	221
32	4	2024-02-13	2024-02-15	4	4	10	221
33	1	2024-03-14	2024-03-17	1	10	6	50
34	2	2024-03-19	2024-03-22	2	7	7	50
35	3	2024-03-24	2024-03-25	3	10	38	50
36	4	2024-03-29	2024-03-30	4	9	42	50
37	1	2024-03-02	2024-03-05	1	7	10	206
38	2	2024-03-07	2024-03-10	2	5	9	206
39	3	2024-03-12	2024-03-14	3	10	18	206
40	4	2024-03-17	2024-03-18	4	9	49	206
41	1	2024-03-10	2024-03-11	1	2	49	146
42	2	2024-03-15	2024-03-16	2	3	44	146
43	3	2024-03-20	2024-03-21	3	3	42	146
44	4	2024-03-25	2024-03-28	4	9	28	146
45	1	2024-04-06	2024-04-07	1	6	41	260
46	2	2024-04-11	2024-04-14	2	6	35	260
47	3	2024-04-16	2024-04-17	3	10	22	260
48	4	2024-04-21	2024-04-24	4	2	37	260
49	1	2024-03-28	2024-03-31	1	10	11	88
50	2	2024-04-02	2024-04-05	2	9	36	88
51	3	2024-04-07	2024-04-10	3	4	5	88
52	4	2024-04-12	2024-04-13	4	10	14	88
53	1	2024-02-27	2024-02-28	1	10	3	126
54	2	2024-03-03	2024-03-04	2	9	50	126
55	3	2024-03-08	2024-03-09	3	10	19	126
56	4	2024-03-13	2024-03-14	4	7	33	126
57	1	2024-02-03	2024-02-04	1	1	7	20
58	2	2024-02-08	2024-02-09	2	8	45	20
59	3	2024-02-13	2024-02-15	3	6	21	20
60	4	2024-02-18	2024-02-20	4	3	35	20
61	1	2024-02-22	2024-02-23	1	5	9	207
62	2	2024-02-27	2024-02-28	2	3	41	207
63	3	2024-03-03	2024-03-05	3	8	50	207
64	4	2024-03-08	2024-03-10	4	9	28	207
65	1	2024-01-31	2024-02-02	1	10	46	296
66	2	2024-02-05	2024-02-06	2	10	14	296
67	3	2024-02-10	2024-02-12	3	7	16	296
68	4	2024-02-15	2024-02-18	4	7	39	296
69	1	2024-03-14	2024-03-16	1	5	34	53
70	2	2024-03-19	2024-03-20	2	10	2	53
71	3	2024-03-24	2024-03-27	3	1	50	53
72	4	2024-03-29	2024-04-01	4	2	37	53
73	1	2024-03-22	2024-03-24	1	3	20	132
74	2	2024-03-27	2024-03-28	2	2	2	132
75	3	2024-04-01	2024-04-04	3	8	37	132
76	4	2024-04-06	2024-04-09	4	5	2	132
77	1	2024-01-14	2024-01-16	1	6	16	254
78	2	2024-01-19	2024-01-21	2	1	29	254
79	3	2024-01-24	2024-01-27	3	2	3	254
80	4	2024-01-29	2024-01-31	4	5	32	254
81	1	2024-03-28	2024-03-31	1	9	24	397
82	2	2024-04-02	2024-04-03	2	4	19	397
83	3	2024-04-07	2024-04-08	3	4	43	397
84	4	2024-04-12	2024-04-15	4	5	38	397
85	1	2024-02-26	2024-02-27	1	5	3	234
86	2	2024-03-02	2024-03-05	2	9	20	234
87	3	2024-03-07	2024-03-08	3	7	49	234
88	4	2024-03-12	2024-03-13	4	5	19	234
89	1	2024-01-29	2024-01-31	1	7	7	374
90	2	2024-02-03	2024-02-06	2	1	35	374
91	3	2024-02-08	2024-02-10	3	3	14	374
92	4	2024-02-13	2024-02-14	4	10	22	374
93	1	2024-01-20	2024-01-22	1	4	3	86
94	2	2024-01-25	2024-01-27	2	6	27	86
95	3	2024-01-30	2024-02-02	3	4	42	86
96	4	2024-02-04	2024-02-06	4	9	18	86
97	1	2024-03-15	2024-03-18	1	8	17	140
98	2	2024-03-20	2024-03-21	2	6	45	140
99	3	2024-03-25	2024-03-27	3	2	20	140
100	4	2024-03-30	2024-03-31	4	5	28	140
101	1	2024-02-04	2024-02-07	1	4	31	63
102	2	2024-02-09	2024-02-10	2	9	25	63
103	3	2024-02-14	2024-02-15	3	2	7	63
104	4	2024-02-19	2024-02-22	4	10	30	63
105	1	2024-02-05	2024-02-06	1	4	41	202
106	2	2024-02-10	2024-02-12	2	10	11	202
107	3	2024-02-15	2024-02-18	3	6	40	202
108	4	2024-02-20	2024-02-21	4	8	33	202
109	1	2024-02-22	2024-02-25	1	1	34	181
110	2	2024-02-27	2024-02-29	2	3	38	181
111	3	2024-03-03	2024-03-05	3	8	19	181
112	4	2024-03-08	2024-03-11	4	7	7	181
113	1	2024-03-20	2024-03-23	1	7	12	21
114	2	2024-03-25	2024-03-28	2	10	6	21
115	3	2024-03-30	2024-04-01	3	7	3	21
116	4	2024-04-04	2024-04-05	4	7	20	21
117	1	2024-03-23	2024-03-25	1	7	15	85
118	2	2024-03-28	2024-03-29	2	4	5	85
119	3	2024-04-02	2024-04-05	3	10	5	85
120	4	2024-04-07	2024-04-10	4	2	1	85
121	1	2024-03-11	2024-03-14	1	8	4	317
122	2	2024-03-16	2024-03-19	2	10	7	317
123	3	2024-03-21	2024-03-22	3	6	41	317
124	4	2024-03-26	2024-03-27	4	1	14	317
125	1	2024-03-28	2024-03-29	1	3	2	242
126	2	2024-04-02	2024-04-03	2	8	13	242
127	3	2024-04-07	2024-04-09	3	3	41	242
128	4	2024-04-12	2024-04-14	4	4	43	242
129	1	2024-04-09	2024-04-10	1	1	15	67
130	2	2024-04-14	2024-04-17	2	2	1	67
131	3	2024-04-19	2024-04-20	3	4	43	67
132	4	2024-04-24	2024-04-26	4	7	43	67
133	1	2024-01-27	2024-01-30	1	5	42	260
134	2	2024-02-01	2024-02-03	2	6	13	260
135	3	2024-02-06	2024-02-09	3	7	44	260
136	4	2024-02-11	2024-02-12	4	4	22	260
137	1	2024-04-04	2024-04-05	1	10	1	158
138	2	2024-04-09	2024-04-10	2	1	50	158
139	3	2024-04-14	2024-04-15	3	1	13	158
140	4	2024-04-19	2024-04-21	4	1	15	158
141	1	2024-01-16	2024-01-17	1	2	19	390
142	2	2024-01-21	2024-01-22	2	6	10	390
143	3	2024-01-26	2024-01-29	3	6	29	390
144	4	2024-01-31	2024-02-02	4	5	10	390
145	1	2024-01-06	2024-01-08	1	4	33	345
146	2	2024-01-11	2024-01-13	2	3	46	345
147	3	2024-01-16	2024-01-18	3	10	32	345
148	4	2024-01-21	2024-01-22	4	5	8	345
149	1	2024-03-28	2024-03-31	1	8	38	103
150	2	2024-04-02	2024-04-03	2	5	32	103
151	3	2024-04-07	2024-04-08	3	5	21	103
152	4	2024-04-12	2024-04-14	4	6	14	103
153	1	2024-03-31	2024-04-01	1	9	6	366
154	2	2024-04-05	2024-04-07	2	9	17	366
155	3	2024-04-10	2024-04-13	3	6	22	366
156	4	2024-04-15	2024-04-17	4	8	16	366
157	1	2024-03-05	2024-03-06	1	2	44	383
158	2	2024-03-10	2024-03-13	2	8	50	383
159	3	2024-03-15	2024-03-16	3	8	41	383
160	4	2024-03-20	2024-03-23	4	6	34	383
161	1	2024-04-10	2024-04-12	1	9	50	85
162	2	2024-04-15	2024-04-16	2	5	7	85
163	3	2024-04-20	2024-04-22	3	4	15	85
164	4	2024-04-25	2024-04-27	4	1	27	85
165	1	2024-02-06	2024-02-08	1	2	42	267
166	2	2024-02-11	2024-02-12	2	1	48	267
167	3	2024-02-16	2024-02-18	3	1	4	267
168	4	2024-02-21	2024-02-24	4	4	25	267
169	1	2024-03-18	2024-03-21	1	4	36	215
170	2	2024-03-23	2024-03-24	2	8	16	215
171	3	2024-03-28	2024-03-30	3	4	14	215
172	4	2024-04-02	2024-04-05	4	10	11	215
173	1	2024-01-06	2024-01-07	1	7	49	270
174	2	2024-01-11	2024-01-13	2	7	28	270
175	3	2024-01-16	2024-01-17	3	1	46	270
176	4	2024-01-21	2024-01-23	4	7	6	270
177	1	2024-04-07	2024-04-09	1	1	19	319
178	2	2024-04-12	2024-04-14	2	1	28	319
179	3	2024-04-17	2024-04-19	3	9	22	319
180	4	2024-04-22	2024-04-24	4	9	29	319
181	1	2024-01-06	2024-01-08	1	10	45	325
182	2	2024-01-11	2024-01-12	2	2	25	325
183	3	2024-01-16	2024-01-18	3	8	10	325
184	4	2024-01-21	2024-01-23	4	7	28	325
185	1	2024-04-05	2024-04-07	1	10	41	363
186	2	2024-04-10	2024-04-11	2	5	50	363
187	3	2024-04-15	2024-04-16	3	8	16	363
188	4	2024-04-20	2024-04-23	4	8	25	363
189	1	2024-03-03	2024-03-06	1	3	22	342
190	2	2024-03-08	2024-03-11	2	2	13	342
191	3	2024-03-13	2024-03-14	3	10	46	342
192	4	2024-03-18	2024-03-20	4	9	31	342
193	1	2024-02-13	2024-02-15	1	10	14	373
194	2	2024-02-18	2024-02-21	2	7	42	373
195	3	2024-02-23	2024-02-24	3	9	50	373
196	4	2024-02-28	2024-02-29	4	4	34	373
197	1	2024-02-09	2024-02-12	1	10	44	202
198	2	2024-02-14	2024-02-16	2	4	44	202
199	3	2024-02-19	2024-02-21	3	10	6	202
200	4	2024-02-24	2024-02-25	4	8	11	202
201	1	2024-02-01	2024-02-03	1	3	28	190
202	2	2024-02-06	2024-02-07	2	1	36	190
203	3	2024-02-11	2024-02-14	3	4	7	190
204	4	2024-02-16	2024-02-18	4	2	13	190
205	1	2024-03-10	2024-03-11	1	2	34	381
206	2	2024-03-15	2024-03-16	2	5	45	381
207	3	2024-03-20	2024-03-23	3	3	16	381
208	4	2024-03-25	2024-03-27	4	5	31	381
209	1	2024-01-31	2024-02-01	1	8	5	100
210	2	2024-02-05	2024-02-08	2	8	32	100
211	3	2024-02-10	2024-02-13	3	10	1	100
212	4	2024-02-15	2024-02-17	4	5	28	100
213	1	2024-03-10	2024-03-12	1	9	42	230
214	2	2024-03-15	2024-03-17	2	8	39	230
215	3	2024-03-20	2024-03-23	3	1	17	230
216	4	2024-03-25	2024-03-27	4	9	48	230
217	1	2024-03-12	2024-03-15	1	4	38	163
218	2	2024-03-17	2024-03-19	2	9	21	163
219	3	2024-03-22	2024-03-23	3	5	25	163
220	4	2024-03-27	2024-03-30	4	5	7	163
221	1	2024-02-17	2024-02-20	1	1	47	89
222	2	2024-02-22	2024-02-25	2	6	47	89
223	3	2024-02-27	2024-02-29	3	3	39	89
224	4	2024-03-03	2024-03-04	4	8	11	89
225	1	2024-01-24	2024-01-25	1	4	5	206
226	2	2024-01-29	2024-02-01	2	8	13	206
227	3	2024-02-03	2024-02-04	3	2	2	206
228	4	2024-02-08	2024-02-09	4	3	50	206
229	1	2024-03-01	2024-03-03	1	3	28	172
230	2	2024-03-06	2024-03-09	2	9	30	172
231	3	2024-03-11	2024-03-14	3	5	8	172
232	4	2024-03-16	2024-03-19	4	4	41	172
233	1	2024-01-29	2024-02-01	1	3	13	220
234	2	2024-02-03	2024-02-04	2	1	18	220
235	3	2024-02-08	2024-02-10	3	7	47	220
236	4	2024-02-13	2024-02-16	4	2	10	220
237	1	2024-01-02	2024-01-04	1	4	38	99
238	2	2024-01-07	2024-01-08	2	6	32	99
239	3	2024-01-12	2024-01-13	3	7	26	99
240	4	2024-01-17	2024-01-19	4	9	36	99
241	1	2024-02-19	2024-02-22	1	8	41	249
242	2	2024-02-24	2024-02-25	2	1	14	249
243	3	2024-02-29	2024-03-03	3	4	9	249
244	4	2024-03-05	2024-03-06	4	8	18	249
245	1	2024-02-27	2024-02-29	1	6	17	277
246	2	2024-03-03	2024-03-04	2	6	15	277
247	3	2024-03-08	2024-03-09	3	3	17	277
248	4	2024-03-13	2024-03-14	4	3	11	277
249	1	2024-02-18	2024-02-21	1	4	42	239
250	2	2024-02-23	2024-02-26	2	6	33	239
251	3	2024-02-28	2024-03-02	3	3	28	239
252	4	2024-03-04	2024-03-07	4	5	42	239
253	1	2024-03-05	2024-03-08	1	5	3	124
254	2	2024-03-10	2024-03-13	2	1	19	124
255	3	2024-03-15	2024-03-16	3	10	19	124
256	4	2024-03-20	2024-03-21	4	6	6	124
257	1	2024-01-04	2024-01-06	1	3	28	126
258	2	2024-01-09	2024-01-10	2	10	33	126
259	3	2024-01-14	2024-01-15	3	1	36	126
260	4	2024-01-19	2024-01-22	4	2	33	126
261	1	2024-01-03	2024-01-04	1	2	4	328
262	2	2024-01-08	2024-01-11	2	4	13	328
263	3	2024-01-13	2024-01-14	3	6	30	328
264	4	2024-01-18	2024-01-20	4	6	5	328
265	1	2024-02-03	2024-02-04	1	8	41	221
266	2	2024-02-08	2024-02-09	2	3	37	221
267	3	2024-02-13	2024-02-14	3	2	39	221
268	4	2024-02-18	2024-02-20	4	7	8	221
269	1	2024-03-09	2024-03-11	1	8	37	242
270	2	2024-03-14	2024-03-16	2	9	37	242
271	3	2024-03-19	2024-03-20	3	1	24	242
272	4	2024-03-24	2024-03-25	4	6	21	242
273	1	2024-01-08	2024-01-11	1	5	33	186
274	2	2024-01-13	2024-01-16	2	2	44	186
275	3	2024-01-18	2024-01-20	3	5	43	186
276	4	2024-01-23	2024-01-24	4	10	6	186
277	1	2024-01-13	2024-01-16	1	10	1	205
278	2	2024-01-18	2024-01-19	2	2	48	205
279	3	2024-01-23	2024-01-25	3	2	42	205
280	4	2024-01-28	2024-01-31	4	6	10	205
281	1	2024-01-12	2024-01-13	1	3	40	400
282	2	2024-01-17	2024-01-18	2	1	44	400
283	3	2024-01-22	2024-01-25	3	7	26	400
284	4	2024-01-27	2024-01-29	4	3	29	400
285	1	2024-02-24	2024-02-26	1	1	6	13
286	2	2024-02-29	2024-03-03	2	2	25	13
287	3	2024-03-05	2024-03-07	3	7	35	13
288	4	2024-03-10	2024-03-13	4	10	3	13
289	1	2024-04-03	2024-04-06	1	8	49	84
290	2	2024-04-08	2024-04-09	2	6	50	84
291	3	2024-04-13	2024-04-16	3	1	47	84
292	4	2024-04-18	2024-04-19	4	7	47	84
293	1	2024-03-28	2024-03-29	1	5	47	233
294	2	2024-04-02	2024-04-05	2	3	48	233
295	3	2024-04-07	2024-04-08	3	9	2	233
296	4	2024-04-12	2024-04-14	4	7	25	233
297	1	2024-01-08	2024-01-09	1	2	35	331
298	2	2024-01-13	2024-01-16	2	5	43	331
299	3	2024-01-18	2024-01-21	3	4	28	331
300	4	2024-01-23	2024-01-25	4	3	25	331
301	1	2024-04-04	2024-04-05	1	1	17	89
302	2	2024-04-09	2024-04-12	2	1	15	89
303	3	2024-04-14	2024-04-17	3	6	34	89
304	4	2024-04-19	2024-04-21	4	4	49	89
305	1	2024-01-11	2024-01-12	1	4	30	111
306	2	2024-01-16	2024-01-19	2	3	46	111
307	3	2024-01-21	2024-01-23	3	9	6	111
308	4	2024-01-26	2024-01-29	4	6	41	111
309	1	2024-02-23	2024-02-25	1	3	36	33
310	2	2024-02-28	2024-03-02	2	3	34	33
311	3	2024-03-04	2024-03-07	3	9	31	33
312	4	2024-03-09	2024-03-12	4	8	36	33
313	1	2024-02-26	2024-02-28	1	8	13	22
314	2	2024-03-02	2024-03-04	2	10	12	22
315	3	2024-03-07	2024-03-08	3	1	4	22
316	4	2024-03-12	2024-03-15	4	2	44	22
317	1	2024-01-30	2024-02-01	1	4	25	90
318	2	2024-02-04	2024-02-07	2	8	25	90
319	3	2024-02-09	2024-02-12	3	5	33	90
320	4	2024-02-14	2024-02-15	4	9	50	90
321	1	2024-03-01	2024-03-04	1	9	24	383
322	2	2024-03-06	2024-03-09	2	1	26	383
323	3	2024-03-11	2024-03-14	3	8	32	383
324	4	2024-03-16	2024-03-18	4	9	24	383
325	1	2024-02-24	2024-02-25	1	10	30	397
326	2	2024-02-29	2024-03-03	2	6	31	397
327	3	2024-03-05	2024-03-06	3	4	29	397
328	4	2024-03-10	2024-03-13	4	9	8	397
329	1	2024-01-06	2024-01-09	1	10	6	8
330	2	2024-01-11	2024-01-14	2	3	45	8
331	3	2024-01-16	2024-01-17	3	1	41	8
332	4	2024-01-21	2024-01-24	4	9	40	8
333	1	2024-01-24	2024-01-27	1	10	6	280
334	2	2024-01-29	2024-01-30	2	10	27	280
335	3	2024-02-03	2024-02-04	3	10	26	280
336	4	2024-02-08	2024-02-09	4	6	23	280
337	1	2024-03-30	2024-04-02	1	2	43	287
338	2	2024-04-04	2024-04-07	2	5	26	287
339	3	2024-04-09	2024-04-11	3	6	42	287
340	4	2024-04-14	2024-04-17	4	6	14	287
341	1	2024-01-25	2024-01-26	1	8	26	219
342	2	2024-01-30	2024-02-02	2	7	30	219
343	3	2024-02-04	2024-02-07	3	8	4	219
344	4	2024-02-09	2024-02-12	4	9	25	219
345	1	2024-01-01	2024-01-02	1	1	32	366
346	2	2024-01-06	2024-01-07	2	6	4	366
347	3	2024-01-11	2024-01-13	3	8	35	366
348	4	2024-01-16	2024-01-18	4	2	39	366
349	1	2024-02-05	2024-02-08	1	9	4	162
350	2	2024-02-10	2024-02-11	2	5	20	162
351	3	2024-02-15	2024-02-18	3	8	9	162
352	4	2024-02-20	2024-02-22	4	9	2	162
353	1	2024-03-26	2024-03-28	1	5	9	301
354	2	2024-03-31	2024-04-02	2	10	5	301
355	3	2024-04-05	2024-04-06	3	1	48	301
356	4	2024-04-10	2024-04-13	4	6	31	301
357	1	2024-01-09	2024-01-12	1	3	28	44
358	2	2024-01-14	2024-01-16	2	8	2	44
359	3	2024-01-19	2024-01-22	3	9	20	44
360	4	2024-01-24	2024-01-25	4	1	1	44
361	1	2024-01-01	2024-01-03	1	4	24	236
362	2	2024-01-06	2024-01-09	2	7	40	236
363	3	2024-01-11	2024-01-14	3	5	16	236
364	4	2024-01-16	2024-01-18	4	9	40	236
365	1	2024-04-03	2024-04-04	1	3	2	235
366	2	2024-04-08	2024-04-09	2	9	26	235
367	3	2024-04-13	2024-04-15	3	1	26	235
368	4	2024-04-18	2024-04-21	4	1	12	235
369	1	2024-03-09	2024-03-11	1	4	17	30
370	2	2024-03-14	2024-03-15	2	5	24	30
371	3	2024-03-19	2024-03-22	3	4	1	30
372	4	2024-03-24	2024-03-27	4	7	42	30
373	1	2024-02-16	2024-02-17	1	6	32	140
374	2	2024-02-21	2024-02-23	2	9	5	140
375	3	2024-02-26	2024-02-27	3	10	29	140
376	4	2024-03-02	2024-03-03	4	6	49	140
377	1	2024-04-06	2024-04-08	1	10	5	70
378	2	2024-04-11	2024-04-13	2	7	6	70
379	3	2024-04-16	2024-04-19	3	1	19	70
380	4	2024-04-21	2024-04-24	4	10	29	70
381	1	2024-02-12	2024-02-13	1	1	36	389
382	2	2024-02-17	2024-02-18	2	5	28	389
383	3	2024-02-22	2024-02-24	3	4	27	389
384	4	2024-02-27	2024-02-28	4	6	14	389
385	1	2024-03-19	2024-03-21	1	2	27	266
386	2	2024-03-24	2024-03-27	2	6	9	266
387	3	2024-03-29	2024-03-30	3	5	36	266
388	4	2024-04-03	2024-04-05	4	5	30	266
389	1	2024-03-03	2024-03-05	1	6	17	326
390	2	2024-03-08	2024-03-11	2	5	13	326
391	3	2024-03-13	2024-03-15	3	4	29	326
392	4	2024-03-18	2024-03-20	4	10	43	326
393	1	2024-04-10	2024-04-12	1	10	18	360
394	2	2024-04-15	2024-04-18	2	7	23	360
395	3	2024-04-20	2024-04-23	3	8	41	360
396	4	2024-04-25	2024-04-28	4	8	9	360
397	1	2024-02-27	2024-02-28	1	10	5	86
398	2	2024-03-03	2024-03-04	2	4	17	86
399	3	2024-03-08	2024-03-10	3	2	4	86
400	4	2024-03-13	2024-03-14	4	8	45	86
1	1	2024-02-02	2024-02-04	1	3	39	228
1001	1	2025-04-01	2025-04-02	1	777	1	777
1002	2	2025-04-03	2025-04-04	2	777	1	777
1003	3	2025-04-05	2025-04-06	3	777	1	777
1004	4	2025-04-07	2025-04-08	4	777	1	777
9001	1	2025-05-01	2025-05-05	1	10	1	888
9002	2	2025-05-02	2025-05-05	2	10	1	888
9003	3	2025-05-03	2025-05-05	3	10	1	888
9004	4	2025-05-04	2025-05-05	4	10	1	888
555	1	2025-02-02	2025-03-03	4	3	16	222
556	2	2025-03-01	2025-03-02	\N	3	16	222
557	3	2025-03-03	2025-03-04	\N	3	16	222
558	4	2025-03-05	2025-03-06	\N	3	16	222
\.


--
-- TOC entry 3576 (class 0 OID 65944)
-- Dependencies: 243
-- Data for Name: purchase_local; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.purchase_local (purchaseid, purchasedate, paymentmethod, employeeid) FROM stdin;
1	2025-03-27	מזומן	4
2	2025-03-13	ביט	1
3	2025-03-15	ביט	5
4	2025-02-20	אשראי	3
5	2025-02-25	ביט	5
6	2025-01-08	ביט	5
7	2025-03-10	ביט	4
8	2025-01-18	ביט	2
9	2025-02-24	מזומן	1
10	2025-03-29	ביט	1
11	2025-01-11	ביט	4
12	2025-01-24	מזומן	4
13	2025-03-30	אשראי	5
14	2025-02-09	מזומן	1
15	2025-02-03	מזומן	2
16	2025-03-15	ביט	2
17	2025-01-09	מזומן	4
18	2025-03-31	מזומן	3
19	2025-03-28	אשראי	4
20	2025-01-23	אשראי	5
21	2025-03-25	ביט	3
22	2025-01-18	מזומן	5
23	2025-01-07	מזומן	3
24	2025-02-22	ביט	2
25	2025-02-03	מזומן	4
26	2025-02-24	ביט	3
27	2025-01-30	ביט	1
28	2025-01-25	אשראי	1
29	2025-03-30	אשראי	4
30	2025-02-04	ביט	3
31	2025-02-24	אשראי	2
32	2025-03-20	אשראי	2
33	2025-03-09	אשראי	4
34	2025-02-26	מזומן	3
35	2025-03-08	מזומן	4
36	2025-03-25	מזומן	4
37	2025-01-19	מזומן	5
38	2025-01-18	אשראי	5
39	2025-01-03	אשראי	2
40	2025-01-19	מזומן	5
41	2025-02-23	ביט	3
42	2025-03-26	מזומן	5
43	2025-03-20	אשראי	1
44	2025-01-26	ביט	3
45	2025-03-15	ביט	3
46	2025-01-06	מזומן	5
47	2025-03-22	ביט	4
48	2025-03-18	ביט	1
49	2025-03-05	מזומן	1
50	2025-01-22	מזומן	2
51	2025-02-10	אשראי	1
52	2025-01-18	אשראי	4
53	2025-01-29	ביט	3
54	2025-01-28	מזומן	4
55	2025-01-22	מזומן	3
56	2025-02-26	ביט	5
57	2025-01-17	אשראי	5
58	2025-03-06	מזומן	5
59	2025-01-28	אשראי	5
60	2025-03-01	ביט	2
61	2025-03-15	אשראי	5
62	2025-02-07	אשראי	3
63	2025-02-08	מזומן	5
64	2025-03-29	מזומן	3
65	2025-02-16	ביט	2
66	2025-01-31	ביט	4
67	2025-02-04	אשראי	2
68	2025-02-12	ביט	5
69	2025-01-22	מזומן	2
70	2025-03-17	מזומן	5
71	2025-03-19	אשראי	5
72	2025-03-28	מזומן	5
73	2025-01-07	ביט	4
74	2025-01-06	ביט	2
75	2025-03-13	אשראי	1
76	2025-03-25	אשראי	4
77	2025-02-18	ביט	1
78	2025-01-16	אשראי	3
79	2025-01-03	מזומן	4
80	2025-01-13	מזומן	4
81	2025-03-31	ביט	4
82	2025-02-06	ביט	4
83	2025-03-31	אשראי	2
84	2025-03-23	אשראי	3
85	2025-01-20	ביט	2
86	2025-02-19	ביט	1
87	2025-01-21	מזומן	1
88	2025-03-18	ביט	5
89	2025-01-27	מזומן	2
90	2025-01-08	ביט	2
91	2025-02-15	אשראי	3
92	2025-01-16	אשראי	3
93	2025-02-02	ביט	3
94	2025-03-01	מזומן	3
95	2025-03-06	אשראי	2
96	2025-02-01	אשראי	4
97	2025-01-05	ביט	3
98	2025-01-01	ביט	4
99	2025-02-04	מזומן	2
100	2025-03-23	אשראי	3
101	2025-03-30	ביט	3
102	2025-02-08	מזומן	1
103	2025-02-09	אשראי	4
104	2025-03-20	מזומן	5
105	2025-01-30	ביט	4
106	2025-02-01	מזומן	4
107	2025-01-01	אשראי	4
108	2025-03-23	מזומן	2
109	2025-03-09	ביט	1
110	2025-03-15	אשראי	5
111	2025-01-27	מזומן	4
112	2025-02-15	ביט	1
113	2025-02-21	מזומן	4
114	2025-01-16	מזומן	3
115	2025-03-31	ביט	1
116	2025-02-03	אשראי	1
117	2025-03-25	מזומן	5
118	2025-03-10	מזומן	5
119	2025-02-16	מזומן	5
120	2025-03-06	ביט	3
121	2025-01-02	ביט	4
122	2025-03-10	מזומן	2
123	2025-02-28	ביט	1
124	2025-03-26	מזומן	4
125	2025-02-01	מזומן	4
126	2025-01-18	אשראי	1
127	2025-01-11	אשראי	2
128	2025-03-27	מזומן	3
129	2025-03-28	מזומן	5
130	2025-03-14	מזומן	1
131	2025-03-18	אשראי	1
132	2025-01-11	מזומן	4
133	2025-02-26	ביט	1
134	2025-02-10	אשראי	3
135	2025-02-13	אשראי	4
136	2025-02-06	ביט	4
137	2025-01-09	מזומן	5
138	2025-03-28	ביט	4
139	2025-01-03	מזומן	4
140	2025-01-21	ביט	2
141	2025-03-05	מזומן	1
142	2025-03-18	מזומן	2
143	2025-01-15	אשראי	2
144	2025-02-23	מזומן	5
145	2025-01-22	מזומן	1
146	2025-03-18	אשראי	1
147	2025-01-31	אשראי	2
148	2025-03-08	ביט	1
149	2025-03-06	ביט	5
150	2025-03-24	מזומן	1
151	2025-02-08	אשראי	3
152	2025-02-13	ביט	4
153	2025-02-04	ביט	1
154	2025-03-10	ביט	1
155	2025-02-08	ביט	3
156	2025-02-27	ביט	3
157	2025-03-12	אשראי	2
158	2025-03-17	מזומן	1
159	2025-02-22	ביט	2
160	2025-01-01	אשראי	3
161	2025-02-20	אשראי	2
162	2025-02-03	מזומן	5
163	2025-02-03	מזומן	1
164	2025-01-19	מזומן	1
165	2025-02-05	אשראי	4
166	2025-03-06	אשראי	4
167	2025-01-15	ביט	1
168	2025-02-24	מזומן	4
169	2025-01-10	מזומן	3
170	2025-03-14	ביט	5
171	2025-03-15	מזומן	4
172	2025-03-06	ביט	3
173	2025-03-09	מזומן	5
174	2025-01-09	אשראי	2
175	2025-01-25	מזומן	5
176	2025-03-02	ביט	1
177	2025-02-16	מזומן	2
178	2025-03-24	מזומן	5
179	2025-01-01	ביט	3
180	2025-02-11	מזומן	1
181	2025-03-19	ביט	3
182	2025-01-08	אשראי	4
183	2025-03-08	מזומן	1
184	2025-03-10	ביט	3
185	2025-01-29	מזומן	5
186	2025-02-09	אשראי	1
187	2025-03-31	אשראי	3
188	2025-02-09	אשראי	2
189	2025-03-06	מזומן	4
190	2025-01-25	אשראי	3
191	2025-01-16	מזומן	3
192	2025-03-04	ביט	1
193	2025-03-22	מזומן	2
194	2025-03-10	ביט	3
195	2025-03-13	ביט	5
196	2025-01-18	אשראי	2
197	2025-01-14	אשראי	4
198	2025-01-08	מזומן	4
199	2025-03-23	מזומן	3
200	2025-01-08	ביט	2
201	2025-01-04	אשראי	4
202	2025-03-13	מזומן	4
203	2025-02-10	אשראי	4
204	2025-02-04	ביט	4
205	2025-01-11	ביט	3
206	2025-02-19	מזומן	4
207	2025-02-07	אשראי	5
208	2025-02-22	ביט	5
209	2025-01-09	ביט	3
210	2025-03-25	ביט	3
211	2025-03-10	מזומן	5
212	2025-03-10	מזומן	3
213	2025-01-26	אשראי	1
214	2025-01-16	ביט	1
215	2025-01-01	אשראי	3
216	2025-02-21	מזומן	1
217	2025-02-10	מזומן	2
218	2025-01-09	מזומן	3
219	2025-01-31	מזומן	1
220	2025-01-13	מזומן	2
221	2025-02-22	אשראי	3
222	2025-01-30	מזומן	3
223	2025-01-24	ביט	2
224	2025-01-03	אשראי	5
225	2025-01-25	אשראי	5
226	2025-03-30	ביט	5
227	2025-01-15	ביט	3
228	2025-02-26	ביט	1
229	2025-02-08	אשראי	4
230	2025-03-18	ביט	1
231	2025-01-09	מזומן	2
232	2025-01-27	ביט	1
233	2025-03-23	אשראי	2
234	2025-02-09	ביט	4
235	2025-03-09	מזומן	5
236	2025-01-01	ביט	4
237	2025-01-01	מזומן	5
238	2025-02-15	ביט	5
239	2025-01-10	ביט	2
240	2025-01-23	אשראי	3
241	2025-03-23	מזומן	3
242	2025-03-20	מזומן	4
243	2025-01-23	ביט	1
244	2025-02-04	ביט	5
245	2025-01-08	אשראי	1
246	2025-02-07	מזומן	2
247	2025-03-20	ביט	3
248	2025-02-24	אשראי	2
249	2025-03-26	אשראי	3
250	2025-02-16	ביט	4
251	2025-03-26	מזומן	4
252	2025-01-18	אשראי	5
253	2025-03-25	מזומן	5
254	2025-02-06	ביט	4
255	2025-03-11	אשראי	2
256	2025-02-07	ביט	3
257	2025-03-25	ביט	1
258	2025-02-26	מזומן	1
259	2025-02-27	מזומן	3
260	2025-03-10	אשראי	3
261	2025-01-12	מזומן	4
262	2025-01-30	מזומן	1
263	2025-01-29	אשראי	3
264	2025-03-25	ביט	1
265	2025-02-28	אשראי	4
266	2025-01-12	מזומן	1
267	2025-03-26	אשראי	4
268	2025-01-05	אשראי	4
269	2025-01-10	מזומן	1
270	2025-03-03	ביט	4
271	2025-01-11	אשראי	2
272	2025-01-28	אשראי	5
273	2025-01-12	מזומן	2
274	2025-03-01	אשראי	4
275	2025-02-14	מזומן	1
276	2025-01-29	מזומן	1
277	2025-03-31	אשראי	2
278	2025-01-10	אשראי	5
279	2025-02-21	ביט	5
280	2025-01-31	מזומן	2
281	2025-02-21	מזומן	4
282	2025-03-20	אשראי	3
283	2025-03-04	ביט	5
284	2025-02-04	אשראי	4
285	2025-02-13	ביט	5
286	2025-03-27	אשראי	3
287	2025-03-18	ביט	3
288	2025-02-02	ביט	3
289	2025-02-10	ביט	1
290	2025-03-01	ביט	1
291	2025-03-02	ביט	3
292	2025-03-28	מזומן	5
293	2025-02-19	אשראי	1
294	2025-01-05	אשראי	1
295	2025-03-16	מזומן	1
296	2025-01-19	אשראי	5
297	2025-02-10	אשראי	1
298	2025-01-06	ביט	4
299	2025-01-27	אשראי	4
300	2025-02-05	ביט	1
301	2025-03-12	אשראי	1
302	2025-02-26	מזומן	4
303	2025-02-22	אשראי	4
304	2025-01-14	אשראי	5
305	2025-03-25	אשראי	2
306	2025-01-15	אשראי	1
307	2025-03-18	ביט	4
308	2025-02-28	ביט	1
309	2025-01-26	מזומן	1
310	2025-03-07	ביט	5
311	2025-03-16	מזומן	4
312	2025-01-22	ביט	2
313	2025-01-04	אשראי	5
314	2025-02-18	ביט	5
315	2025-01-31	אשראי	5
316	2025-01-06	אשראי	2
317	2025-03-26	ביט	1
318	2025-03-23	אשראי	3
319	2025-01-13	אשראי	4
320	2025-02-15	אשראי	5
321	2025-02-22	מזומן	2
322	2025-02-03	ביט	1
323	2025-01-19	ביט	4
324	2025-01-08	אשראי	3
325	2025-01-21	ביט	1
326	2025-01-12	מזומן	2
327	2025-03-20	מזומן	2
328	2025-01-21	מזומן	1
329	2025-03-05	ביט	3
330	2025-01-06	אשראי	3
331	2025-03-31	ביט	1
332	2025-02-16	ביט	3
333	2025-02-25	ביט	5
334	2025-03-15	ביט	2
335	2025-03-20	מזומן	3
336	2025-01-22	אשראי	4
337	2025-01-15	ביט	3
338	2025-03-23	מזומן	2
339	2025-03-20	ביט	4
340	2025-01-15	ביט	3
341	2025-02-12	ביט	4
342	2025-02-26	ביט	1
343	2025-01-20	ביט	3
344	2025-02-26	ביט	1
345	2025-01-08	ביט	3
346	2025-02-20	אשראי	2
347	2025-02-07	מזומן	4
348	2025-03-14	ביט	2
349	2025-03-01	אשראי	5
350	2025-03-01	מזומן	5
351	2025-03-03	ביט	4
352	2025-03-04	ביט	2
353	2025-03-24	אשראי	4
354	2025-03-08	ביט	4
355	2025-03-04	אשראי	1
356	2025-02-03	ביט	5
357	2025-02-01	אשראי	2
358	2025-01-06	ביט	3
359	2025-01-14	ביט	4
360	2025-03-25	מזומן	3
361	2025-02-14	ביט	5
362	2025-01-07	מזומן	3
363	2025-01-04	מזומן	5
364	2025-01-13	מזומן	4
365	2025-03-08	אשראי	2
366	2025-03-09	ביט	3
367	2025-03-19	מזומן	5
368	2025-01-01	אשראי	3
369	2025-03-21	ביט	4
370	2025-03-03	אשראי	2
371	2025-01-17	ביט	3
372	2025-01-14	ביט	1
373	2025-03-27	ביט	1
374	2025-03-29	ביט	1
375	2025-02-05	מזומן	4
376	2025-03-21	אשראי	2
377	2025-01-24	מזומן	1
378	2025-03-12	אשראי	2
379	2025-02-03	ביט	4
380	2025-03-11	מזומן	3
381	2025-01-20	ביט	5
382	2025-02-10	אשראי	3
383	2025-03-22	אשראי	2
384	2025-01-06	מזומן	1
385	2025-03-15	אשראי	5
386	2025-03-01	מזומן	3
387	2025-01-17	מזומן	3
388	2025-03-24	ביט	1
389	2025-02-19	אשראי	2
390	2025-03-28	מזומן	3
391	2025-03-31	אשראי	2
392	2025-01-05	ביט	4
393	2025-02-24	ביט	5
394	2025-02-02	מזומן	4
395	2025-03-16	ביט	4
396	2025-01-24	אשראי	5
397	2025-02-10	אשראי	2
398	2025-03-06	ביט	4
399	2025-03-05	אשראי	4
400	2025-02-22	אשראי	4
\.


--
-- TOC entry 3577 (class 0 OID 65949)
-- Dependencies: 244
-- Data for Name: purchaseitems_local; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.purchaseitems_local (purchaseid, productid, quantity) FROM stdin;
1	207	5
1	74	9
1	307	8
1	139	8
1	12	3
1	278	2
1	270	1
1	46	1
1	78	8
1	369	1
1	92	3
1	318	8
2	241	10
2	19	4
2	377	9
3	76	2
3	61	9
3	362	2
3	70	1
3	128	8
3	237	5
3	134	10
3	33	9
3	261	10
3	247	1
3	139	4
3	106	1
4	131	2
4	148	6
4	20	3
4	237	7
4	180	8
5	68	3
5	6	6
5	82	6
5	301	3
5	331	3
5	272	10
5	372	1
5	264	2
5	24	6
5	267	10
5	85	7
5	160	7
5	177	1
5	192	7
5	393	7
6	218	7
7	203	5
7	373	10
8	215	6
8	330	1
8	108	8
8	211	7
8	366	4
8	186	2
8	64	2
8	209	7
8	206	9
8	92	5
8	218	4
8	292	10
8	31	3
8	167	2
8	32	2
8	354	4
8	375	7
8	122	7
9	7	8
9	313	7
9	62	4
9	164	3
9	197	5
9	34	1
9	83	1
9	9	2
9	6	1
9	334	2
9	223	9
9	4	10
9	255	6
9	161	10
9	288	6
10	69	9
10	212	9
10	380	1
10	247	6
10	229	3
10	355	8
10	78	7
10	123	3
10	376	9
10	299	9
10	165	6
10	351	8
10	188	4
10	57	4
10	317	1
10	392	6
10	28	2
11	27	9
11	153	4
11	382	5
11	121	10
11	35	7
11	23	8
11	77	8
11	310	7
12	206	10
12	210	2
12	23	7
12	372	1
12	96	7
12	11	8
12	192	5
12	245	4
12	340	1
12	329	8
12	257	8
12	148	9
12	168	4
12	39	7
12	317	6
12	388	1
12	239	5
12	273	3
13	94	5
13	104	5
13	187	6
13	178	2
13	101	2
13	11	10
13	30	3
13	137	7
13	256	2
13	234	3
13	294	6
13	12	9
14	249	10
14	282	4
14	7	6
14	197	2
14	278	6
14	36	3
14	390	9
14	396	1
14	333	9
14	84	10
14	242	3
14	149	5
15	228	5
15	287	2
15	105	10
15	161	1
15	249	6
16	253	4
16	107	1
16	346	5
16	400	9
16	361	7
16	158	1
16	214	10
16	14	10
16	92	3
16	20	3
16	171	9
16	67	7
16	172	4
16	291	7
16	106	1
16	256	7
17	381	1
17	265	9
17	26	10
17	251	1
17	207	7
17	114	8
17	400	10
17	379	9
17	362	2
17	151	9
17	263	7
17	277	9
18	155	2
18	203	1
18	193	4
18	103	10
18	365	7
18	55	4
18	167	8
18	66	5
18	192	5
18	175	7
18	123	1
18	397	9
18	246	4
18	323	3
18	229	4
18	308	5
19	36	9
19	282	5
19	312	7
19	388	2
19	212	6
20	390	6
20	339	7
20	166	7
20	234	6
20	302	4
20	69	5
20	250	1
20	171	9
21	398	5
21	350	8
21	151	9
21	219	6
21	319	3
21	132	2
22	66	3
22	113	2
22	167	9
22	266	3
23	196	9
23	123	2
23	50	10
23	37	4
23	11	10
23	303	2
24	164	6
24	293	7
24	331	10
25	105	10
25	266	8
25	56	4
25	264	7
25	102	5
25	29	7
25	109	7
25	347	8
25	285	8
25	367	3
25	9	4
25	34	3
25	211	7
25	235	3
26	158	6
26	361	7
26	130	1
26	99	1
26	143	1
26	213	7
26	145	9
26	74	4
26	111	10
27	84	10
27	69	4
27	202	7
27	113	10
27	244	7
27	318	9
27	35	4
27	282	1
27	374	10
27	192	3
27	243	9
27	82	5
27	246	6
27	329	2
27	58	10
27	76	7
27	89	5
27	356	3
27	160	1
28	214	3
28	252	2
28	93	10
28	120	2
28	74	3
28	174	5
29	161	5
29	2	3
29	35	3
29	325	9
29	48	5
29	337	2
29	281	9
29	367	9
29	76	8
30	36	2
30	242	5
30	205	1
30	172	4
30	369	7
30	197	3
30	302	4
30	32	9
30	210	8
30	338	10
31	59	7
31	353	8
31	144	9
31	61	3
31	267	3
31	289	9
31	172	6
31	147	1
31	312	8
31	286	5
31	212	2
31	154	1
31	275	9
31	201	3
31	220	10
31	90	9
31	315	10
32	229	5
32	189	3
32	217	3
32	382	7
32	398	9
32	260	4
32	384	5
32	379	6
32	27	7
33	368	2
33	351	8
33	242	7
33	198	10
33	184	5
33	295	3
33	15	6
33	183	1
33	296	8
33	118	2
33	1	3
33	157	1
33	259	2
33	93	8
33	62	3
33	237	4
33	283	4
33	388	8
33	393	9
33	344	5
34	91	2
34	345	3
34	263	3
34	262	3
34	98	4
34	221	5
34	177	5
34	386	3
34	347	9
34	106	3
34	265	6
34	88	4
34	217	10
35	259	2
35	82	9
35	367	4
35	168	7
35	348	6
35	388	10
35	196	9
35	14	6
35	48	1
35	134	6
35	281	8
35	113	2
35	360	8
35	400	5
35	109	10
35	384	5
36	181	9
36	341	7
37	99	5
37	12	7
37	164	3
37	135	8
37	317	5
37	251	10
37	318	5
37	340	6
37	140	10
37	8	3
37	339	4
37	94	6
37	293	7
37	264	8
37	60	9
37	106	7
37	369	4
37	274	3
37	298	6
38	45	2
38	254	6
38	380	1
38	195	4
38	42	1
38	9	2
38	331	1
38	200	1
38	164	9
38	313	8
38	104	3
39	163	2
39	229	5
39	310	4
39	324	7
39	153	7
39	216	5
39	393	7
39	20	10
39	25	5
39	63	3
39	107	10
39	399	6
39	196	1
40	390	9
40	334	5
40	388	8
40	298	9
40	186	10
40	51	1
40	376	3
40	126	10
40	218	7
40	54	3
41	90	5
41	212	3
42	74	1
42	178	5
42	77	2
42	92	9
42	349	5
42	217	7
42	308	4
42	186	10
42	329	9
42	340	4
42	96	5
42	381	2
43	67	7
43	34	4
44	327	9
44	62	10
44	21	3
44	128	10
44	105	1
44	251	8
44	258	4
44	179	7
44	135	9
44	253	1
44	157	5
44	2	2
44	184	7
44	293	7
44	96	9
44	302	7
44	198	4
44	205	1
44	160	10
45	380	10
45	202	5
45	17	9
45	248	8
45	151	5
45	263	5
45	145	2
46	304	1
46	393	10
46	324	1
46	68	3
46	54	4
46	199	5
46	285	1
46	139	3
46	209	3
46	337	1
46	113	7
46	9	7
46	69	10
46	133	8
46	97	10
46	257	2
46	252	6
46	19	1
47	29	9
47	277	1
47	82	10
47	1	9
47	147	1
47	61	7
47	83	8
47	198	6
47	295	9
47	174	9
47	256	5
47	69	7
47	190	1
47	388	8
47	131	8
47	132	3
47	350	2
47	169	2
47	109	5
48	214	9
48	245	8
48	41	7
48	333	9
48	138	2
48	269	7
48	97	3
48	384	9
48	3	9
48	172	2
48	191	9
48	123	9
48	397	7
48	243	10
49	178	2
49	371	2
49	186	3
49	187	2
49	269	3
49	253	3
49	179	3
49	69	1
49	131	1
49	85	3
49	261	8
50	192	8
50	125	3
50	220	1
50	177	5
50	321	2
50	258	4
50	2	2
50	213	5
50	191	2
50	120	8
50	364	10
50	357	5
50	65	7
50	222	9
50	81	7
50	189	8
50	241	10
50	391	5
51	122	6
51	23	7
51	249	3
51	61	2
51	70	2
51	145	9
51	106	9
51	128	9
51	248	3
51	148	4
52	268	9
52	313	6
52	2	8
52	360	2
52	77	4
52	301	4
53	245	2
53	265	8
53	374	5
54	362	2
54	400	9
54	37	8
54	347	4
54	69	1
54	390	4
55	159	9
55	92	7
55	50	9
55	54	10
55	108	8
55	137	3
55	64	6
55	341	8
55	259	9
55	384	3
55	350	10
55	178	4
55	90	9
55	193	4
55	238	5
55	264	3
55	287	1
55	210	1
55	365	10
56	291	8
56	316	4
56	105	2
56	148	7
56	15	2
56	11	8
56	296	4
56	200	6
56	246	7
56	130	10
56	261	5
56	18	2
56	311	2
56	185	1
56	270	4
56	236	4
56	256	10
56	221	5
56	170	7
57	200	1
57	371	10
57	390	2
57	273	4
57	365	8
57	126	5
57	85	2
58	206	7
58	143	6
58	175	1
58	195	5
58	168	2
58	69	9
58	112	7
58	299	6
58	399	8
58	148	8
58	43	8
58	118	8
58	364	2
58	96	4
58	228	1
58	31	3
58	261	3
58	160	1
58	127	4
58	276	6
59	29	5
59	14	4
59	366	1
59	163	6
59	341	6
59	151	10
59	173	6
59	26	4
59	235	8
59	254	6
59	220	5
59	154	9
59	258	10
59	252	5
60	42	10
60	327	9
60	259	8
60	358	6
60	123	10
60	6	7
60	400	7
60	74	1
60	342	4
60	88	1
60	254	5
61	69	1
61	372	10
61	240	1
62	315	8
62	204	4
62	13	6
62	136	3
62	347	2
62	148	6
63	79	8
63	84	3
63	168	10
63	41	4
63	55	8
63	219	8
63	57	1
63	236	5
63	145	1
63	206	7
63	134	7
63	210	3
63	380	2
64	24	3
64	135	7
64	41	10
64	252	6
64	146	2
64	108	5
64	199	6
64	270	3
64	2	7
64	321	9
64	96	9
64	259	7
64	376	6
64	365	9
64	111	3
64	92	2
64	84	7
65	268	10
65	127	1
65	98	5
65	391	9
65	80	7
65	399	2
65	342	10
65	378	6
65	210	9
65	320	5
65	379	6
65	52	5
65	282	9
65	383	1
65	73	8
66	212	8
66	155	7
66	136	6
66	4	5
66	250	10
66	270	6
66	314	3
66	67	4
66	331	5
67	174	8
67	123	5
67	175	10
67	99	5
67	348	8
67	293	9
68	123	5
68	315	9
68	152	10
68	92	8
69	117	8
69	72	3
69	197	7
69	386	9
69	113	2
69	43	3
69	265	5
69	102	10
69	138	3
69	101	9
69	236	9
69	200	6
69	185	4
69	223	6
69	8	7
70	389	6
70	153	5
70	245	3
70	353	9
70	188	9
70	75	8
70	284	4
70	301	1
70	227	1
70	278	7
70	260	3
70	147	6
70	132	5
71	223	9
71	53	7
71	178	4
71	28	7
71	146	9
71	190	5
71	258	7
71	358	7
71	224	5
71	153	1
71	13	9
71	211	6
72	122	7
72	172	1
72	256	6
72	374	4
72	247	3
72	275	6
72	315	9
72	81	1
72	38	3
72	378	1
72	329	8
72	339	9
72	50	2
72	293	4
72	186	1
72	182	1
72	244	1
73	109	10
73	335	10
73	101	5
73	384	3
74	269	10
74	104	4
74	183	1
74	56	1
74	205	9
74	138	1
74	119	7
74	86	5
74	89	5
74	234	10
74	9	6
74	313	2
75	299	10
75	67	5
75	68	6
75	288	6
75	104	4
75	298	6
75	142	2
75	125	10
75	289	5
75	54	8
75	173	9
75	129	9
75	277	10
75	366	2
75	305	1
75	14	8
75	123	10
75	45	6
76	373	4
76	228	7
76	189	1
76	388	10
76	73	5
76	334	10
76	54	6
76	116	8
76	283	6
76	234	9
77	191	5
77	280	6
77	7	3
77	42	10
77	4	10
77	67	8
78	4	3
78	71	7
78	135	8
78	239	5
78	252	5
78	184	9
78	215	6
79	180	3
80	43	4
80	144	8
80	25	3
80	10	7
80	32	4
80	183	2
80	44	1
80	386	9
81	163	7
81	316	10
81	42	5
82	342	9
82	349	6
82	91	9
82	83	6
82	359	8
82	300	2
82	340	1
82	97	5
82	385	6
82	68	9
82	200	5
82	134	2
82	16	2
82	383	2
82	118	1
82	223	9
82	157	3
83	396	2
83	242	2
84	361	5
84	231	1
84	268	3
84	168	3
85	119	6
86	295	2
86	35	7
86	181	7
86	190	5
87	230	9
87	290	5
87	245	6
88	241	3
88	399	7
88	44	10
88	276	7
88	325	9
88	395	4
88	136	5
88	337	4
88	28	2
88	37	1
88	187	10
88	85	5
88	244	7
88	353	1
88	257	4
89	322	2
89	170	8
89	234	7
89	47	10
89	78	4
89	83	3
89	316	2
89	187	9
89	180	5
90	149	8
90	227	7
90	391	3
90	308	5
90	345	8
90	160	5
90	37	3
90	81	6
90	107	1
90	20	7
90	290	5
90	24	2
90	70	5
90	131	1
90	240	9
90	251	2
90	316	5
91	194	4
91	359	2
91	5	10
91	200	7
91	88	4
91	137	8
91	400	5
91	184	3
91	50	6
91	110	3
91	147	9
91	256	9
91	115	5
91	135	10
91	86	4
91	72	2
91	347	6
91	244	2
91	283	8
92	367	5
92	65	1
92	379	3
92	280	4
92	109	2
92	126	4
92	285	7
92	18	4
92	247	3
92	239	8
93	221	5
93	98	4
93	135	9
93	259	5
93	154	2
93	157	2
93	22	5
93	99	10
93	50	10
94	217	10
94	122	9
94	65	6
94	192	3
94	168	2
94	23	5
94	16	3
94	150	3
94	147	6
94	369	4
94	388	5
94	254	6
95	75	5
95	32	3
95	105	8
95	216	7
95	59	7
95	367	7
95	369	10
95	210	8
95	102	4
95	188	1
95	142	3
95	198	4
95	16	2
95	100	8
95	221	1
95	103	4
95	309	3
95	223	10
95	320	3
95	238	1
96	61	6
96	379	2
96	362	6
96	381	1
96	290	6
96	324	3
96	264	7
96	360	3
96	179	7
96	184	5
96	133	1
96	391	6
96	245	10
97	216	7
97	378	4
98	334	9
98	137	8
98	208	5
98	136	6
98	107	8
98	132	3
98	16	6
98	383	9
98	253	8
98	370	9
98	339	2
99	247	8
99	41	2
99	94	4
99	141	4
99	69	3
99	197	2
99	375	2
99	212	3
100	153	4
100	312	8
100	285	1
100	19	1
100	72	1
100	297	4
100	154	1
100	87	7
100	201	3
100	117	8
100	180	2
100	192	2
100	296	3
100	207	1
100	22	8
100	293	10
100	354	6
100	187	9
101	64	1
102	187	6
102	143	1
102	302	1
102	352	4
102	69	8
102	103	10
102	320	5
103	326	6
103	231	6
103	313	2
103	333	9
103	213	8
103	108	8
103	346	10
103	159	1
103	154	8
103	103	6
104	99	2
104	1	1
104	219	6
104	11	2
104	361	1
104	330	1
104	390	5
104	254	1
104	359	2
104	360	8
104	262	8
105	281	1
105	302	5
105	343	9
105	306	9
105	303	1
105	136	8
105	143	6
105	200	6
105	314	2
105	218	1
105	274	5
105	224	8
105	197	8
106	310	2
106	309	8
106	267	5
106	361	9
106	351	1
106	128	10
106	108	6
106	345	7
106	3	8
106	8	1
106	147	6
106	392	6
106	38	5
107	310	4
107	104	7
107	148	5
107	241	2
107	103	10
107	295	10
107	69	2
107	351	1
107	97	1
107	186	8
107	313	1
107	133	2
107	211	1
107	24	2
107	302	7
107	144	5
107	225	3
107	378	5
108	258	8
108	318	2
108	328	8
108	99	3
108	101	7
108	167	10
108	62	5
108	77	9
108	246	6
108	306	4
108	138	3
108	298	5
108	37	5
109	207	8
109	188	3
109	235	7
109	229	7
109	158	1
109	76	5
109	44	3
109	307	5
109	70	4
109	91	9
110	61	7
110	215	2
110	175	4
110	147	6
110	225	4
110	131	2
110	276	4
110	59	10
110	128	7
110	188	5
110	207	1
110	298	1
110	42	1
110	210	6
110	116	7
110	218	2
110	58	4
111	102	8
111	354	10
111	214	9
111	191	4
111	160	4
111	258	1
111	238	4
111	211	3
111	297	8
111	5	9
111	99	6
111	81	3
111	222	8
111	172	9
112	14	9
112	61	5
113	276	10
113	371	6
113	113	6
113	171	9
113	9	9
113	188	7
113	174	9
113	5	3
113	246	6
113	194	2
113	68	5
113	41	8
113	333	1
113	181	5
113	325	8
113	148	5
113	349	8
113	177	3
113	375	3
113	308	7
114	63	8
114	89	4
114	140	3
114	47	5
114	185	6
114	364	2
114	198	4
114	75	5
115	115	7
115	52	3
115	44	5
116	303	1
116	240	5
116	110	6
116	72	5
116	362	6
116	366	10
116	138	9
116	59	3
116	217	6
116	211	3
116	173	10
116	94	5
116	308	2
117	94	6
117	63	4
118	369	2
118	288	1
118	149	6
118	140	9
118	241	5
118	227	7
118	107	10
118	3	6
118	284	9
118	266	3
118	367	7
118	324	5
118	336	10
118	57	9
118	313	5
119	43	7
119	92	3
119	120	1
119	396	5
119	151	4
119	82	6
119	282	5
119	2	2
120	399	10
120	133	8
120	306	8
120	330	8
120	109	6
120	239	10
120	312	5
120	38	1
120	262	1
120	193	7
120	296	2
120	226	1
120	318	8
120	324	2
120	48	10
120	255	8
120	149	4
120	314	10
120	76	1
120	157	3
121	76	7
121	115	1
121	385	6
121	284	6
121	213	1
121	368	9
121	26	2
121	164	2
121	197	6
121	181	2
122	179	6
122	334	10
122	313	10
122	170	1
122	329	1
122	98	7
122	240	2
122	267	10
122	234	7
122	90	3
122	136	1
122	231	10
122	282	9
122	149	10
122	210	5
123	116	5
123	112	1
123	203	2
123	343	6
123	181	10
123	28	2
123	261	7
123	88	6
123	130	1
123	84	9
123	325	2
123	293	9
123	153	5
123	186	4
123	232	5
123	318	6
123	62	6
123	85	4
124	234	7
124	226	2
124	219	3
124	369	6
124	11	1
124	181	5
124	308	1
124	285	2
124	196	5
124	138	10
124	207	3
124	31	3
124	213	8
124	293	5
124	36	5
125	217	6
125	53	9
125	78	9
125	393	6
125	75	10
125	148	10
125	281	1
125	362	4
125	61	2
125	248	8
125	111	7
125	213	1
125	257	8
125	360	9
126	192	1
126	247	8
126	325	3
126	339	3
126	371	1
126	204	9
126	168	8
126	376	9
126	108	10
126	210	5
126	331	8
126	289	5
126	197	2
126	218	3
126	236	7
126	342	4
126	85	4
126	28	9
126	287	5
127	6	6
127	393	7
127	17	7
127	90	4
127	371	9
128	347	2
128	209	6
128	184	1
128	66	10
128	20	5
128	147	6
128	78	10
128	193	3
128	71	9
128	400	9
128	329	9
128	97	4
128	67	8
128	19	10
129	200	3
129	239	4
129	236	4
129	349	9
129	23	10
129	182	6
129	62	9
129	101	5
129	227	7
129	109	3
129	213	8
129	346	9
129	354	5
129	365	5
129	329	1
129	15	2
129	186	8
129	357	7
129	187	4
130	76	9
130	380	10
130	124	7
130	247	6
130	78	1
130	373	5
130	34	7
130	300	10
130	252	3
131	305	3
131	101	6
131	135	5
131	95	6
131	36	4
131	185	1
131	31	4
131	172	1
131	298	6
131	66	9
131	170	2
131	287	2
131	120	2
131	113	5
131	306	6
131	278	8
131	93	6
131	195	5
131	72	1
131	338	8
132	233	4
132	27	4
132	5	8
132	336	6
132	127	1
132	370	1
132	274	3
132	75	10
132	155	1
132	303	2
133	123	6
133	76	3
133	159	9
133	227	5
133	225	6
133	395	10
133	356	1
133	244	6
133	179	3
133	190	5
134	133	3
134	211	6
134	180	1
134	113	5
134	303	9
134	314	5
134	136	5
134	216	8
134	41	8
134	341	1
134	122	6
134	310	1
134	146	10
134	285	10
135	174	9
135	117	5
135	349	10
135	100	4
135	33	8
135	382	6
135	41	8
135	51	5
135	71	10
135	17	3
135	67	7
135	191	4
135	292	2
136	236	7
136	258	9
136	392	8
136	199	7
136	207	9
136	66	4
136	315	1
136	9	4
137	110	4
137	277	6
137	156	10
137	166	9
137	222	2
137	358	5
137	213	9
137	63	5
137	38	3
137	252	1
137	319	2
137	381	8
137	265	10
137	353	5
137	220	4
138	7	9
138	217	4
138	318	2
138	172	1
138	315	8
138	173	5
138	132	8
138	28	6
138	282	6
138	161	1
138	356	10
138	135	3
138	399	9
138	231	8
139	115	8
139	249	4
139	102	5
139	119	5
139	74	2
140	308	3
140	324	9
140	286	6
140	224	4
140	27	6
140	118	8
140	55	10
140	165	2
140	313	1
140	73	10
140	345	9
140	239	1
140	319	2
141	286	2
141	157	3
141	225	8
141	303	3
141	155	8
141	209	4
141	99	7
141	193	8
141	285	1
141	308	1
141	350	1
141	11	7
141	212	7
141	215	3
141	315	6
141	139	2
141	233	1
141	1	5
141	101	6
142	40	5
142	129	1
142	348	1
142	64	5
142	319	9
142	207	5
142	75	3
142	196	1
142	31	4
142	117	10
142	192	1
143	290	6
143	372	1
144	324	10
144	362	6
145	285	9
145	341	9
145	147	2
145	258	2
145	241	7
145	109	2
145	356	6
145	102	6
145	250	3
145	44	2
145	280	3
145	62	4
145	55	9
146	112	8
146	330	10
146	282	9
146	123	5
146	270	10
146	11	8
146	209	8
146	294	10
147	346	8
147	353	4
147	6	9
147	197	9
147	374	9
147	379	2
147	250	4
147	95	6
147	102	8
148	155	2
149	9	7
149	338	4
149	113	8
149	52	8
149	252	8
149	342	5
149	36	1
149	58	3
149	343	4
149	38	3
149	293	1
149	183	3
149	115	7
150	284	9
150	48	6
150	361	3
150	255	8
150	382	2
150	47	10
150	336	7
150	381	4
150	290	8
150	129	10
150	204	6
150	268	2
150	57	9
150	31	2
150	293	2
150	305	1
151	233	5
151	290	2
151	100	6
151	90	10
151	297	4
151	12	3
151	279	8
151	28	3
151	193	9
152	197	5
152	383	10
152	199	2
152	129	4
152	283	9
152	360	2
153	308	9
153	87	1
153	150	5
153	80	2
153	301	2
153	42	1
153	64	9
153	357	7
153	193	1
153	310	1
153	396	9
153	59	2
153	300	1
153	51	4
153	57	5
153	347	5
153	354	5
154	323	1
154	58	10
154	279	5
154	242	7
154	339	5
155	52	6
155	398	1
155	168	10
155	265	7
155	235	10
155	142	2
155	155	9
156	360	10
156	142	1
156	280	2
156	45	7
156	98	8
156	80	7
157	93	7
157	73	8
157	395	3
157	119	2
157	62	1
157	300	7
157	77	2
157	72	4
157	243	1
157	69	5
157	100	9
157	111	1
157	206	4
157	358	2
157	64	7
157	286	8
158	107	8
158	225	10
158	182	6
158	340	8
158	232	2
159	385	10
159	5	8
159	220	5
159	400	7
159	249	6
159	288	10
159	145	1
159	274	6
159	381	9
159	164	2
159	69	10
159	187	6
159	304	5
159	259	4
159	341	3
159	117	9
159	256	1
159	324	1
160	20	2
161	136	8
161	217	6
161	78	7
161	311	9
161	331	4
161	208	2
161	367	9
161	323	3
161	94	5
161	70	10
161	152	6
161	313	1
161	386	5
161	188	3
161	206	7
161	211	5
161	160	3
161	339	5
162	259	5
162	111	3
162	135	4
162	319	10
162	153	7
162	97	2
162	238	2
162	220	6
162	295	10
162	384	1
162	236	3
162	188	6
162	89	5
162	50	10
162	32	1
162	199	9
162	313	6
162	211	8
162	346	7
163	340	7
163	33	10
163	43	7
163	60	2
163	185	1
163	218	9
163	41	7
163	79	5
163	235	9
164	285	8
164	29	7
164	268	6
164	35	3
164	221	9
164	1	5
164	203	3
164	226	8
164	360	8
164	384	8
164	283	8
164	372	5
164	166	6
165	180	8
165	222	10
165	172	8
165	146	9
165	88	2
165	282	2
165	315	6
165	75	10
165	223	7
165	323	6
165	330	9
165	189	8
166	217	3
166	178	7
166	306	6
166	262	10
166	48	5
166	159	1
166	92	3
166	79	9
166	71	8
166	308	3
166	86	10
166	220	2
166	172	4
167	49	6
167	270	4
167	185	4
167	365	3
167	218	6
167	261	7
167	174	9
167	91	1
167	208	2
167	173	2
167	85	10
167	287	1
167	400	9
167	210	6
167	254	8
168	36	10
168	292	3
168	399	4
168	56	7
168	23	5
168	34	9
168	19	2
168	324	3
169	131	3
169	111	5
169	307	8
169	80	3
169	12	9
169	37	4
169	270	1
169	49	9
170	256	4
170	311	4
170	9	4
170	197	7
170	386	2
170	398	2
170	22	2
170	334	2
170	234	9
170	139	1
170	364	1
170	372	10
170	105	3
170	242	5
170	52	9
170	59	4
170	221	3
170	47	4
170	203	8
171	60	10
172	191	9
172	281	6
172	120	3
172	207	8
172	274	1
172	298	1
172	95	8
172	196	3
172	215	1
172	312	8
172	53	8
172	9	1
172	15	2
172	267	1
172	275	7
172	160	3
172	399	1
172	143	5
173	236	4
173	57	4
173	146	8
173	299	9
173	326	2
174	391	9
174	109	7
174	107	2
174	31	10
174	123	8
175	280	8
175	196	6
175	389	10
175	233	1
175	358	10
175	398	7
175	137	2
175	96	7
175	241	3
175	276	10
175	360	9
175	341	3
175	88	9
175	123	10
175	332	2
176	342	2
176	241	8
176	343	2
176	390	9
176	299	9
176	216	4
176	357	1
176	39	1
176	331	5
176	289	4
176	89	10
176	177	6
176	181	4
177	61	3
177	266	6
177	254	2
177	181	3
177	11	6
177	1	6
177	182	9
177	151	5
177	142	8
177	29	7
177	18	2
177	184	8
177	333	6
178	314	5
178	86	6
178	136	5
178	2	10
178	343	5
178	142	5
178	231	3
178	23	7
178	80	9
178	161	9
178	295	3
178	321	5
178	325	4
178	275	9
178	88	8
178	215	1
178	351	6
178	26	2
178	143	6
178	359	1
179	66	9
180	311	4
180	214	3
181	91	8
181	289	1
181	31	2
181	153	7
181	142	5
181	191	4
181	266	10
181	159	2
181	67	7
181	215	2
181	383	9
181	51	1
182	343	4
182	160	5
182	150	9
182	350	10
182	74	10
182	20	8
182	334	10
182	165	2
182	124	2
182	85	9
182	354	3
182	230	9
182	281	3
182	33	3
183	258	5
183	261	6
183	303	10
183	9	1
183	230	8
183	212	7
183	147	5
183	216	1
183	93	2
183	254	9
183	335	2
183	160	2
183	188	8
184	61	10
184	184	6
184	202	2
184	277	10
184	244	6
184	81	7
184	128	7
185	349	2
185	74	1
186	138	2
186	139	10
186	303	8
186	25	5
187	274	5
187	73	5
187	255	7
187	167	5
187	7	10
187	59	2
187	282	5
187	163	2
187	259	1
187	231	6
187	99	6
187	207	3
188	308	10
188	281	10
188	182	6
188	312	8
188	237	7
189	278	5
189	247	1
189	78	2
189	326	8
189	150	8
189	109	8
189	92	6
189	65	5
189	49	10
189	128	6
189	52	6
189	244	1
189	187	4
189	221	4
189	129	2
189	23	10
189	355	6
189	155	1
190	27	4
190	46	1
190	172	7
190	344	10
190	254	10
190	14	2
190	290	6
190	259	5
190	368	3
190	60	6
190	127	5
190	31	1
190	80	8
191	267	4
192	183	6
192	159	10
193	190	3
193	130	1
193	399	3
193	57	5
193	53	6
193	58	8
193	388	3
193	398	4
193	192	2
194	204	10
194	280	10
194	87	10
194	98	2
194	187	2
194	377	4
194	29	3
194	19	9
194	395	3
194	320	5
194	168	6
194	57	5
194	348	3
194	371	5
194	160	5
194	278	1
195	67	10
195	263	8
195	66	10
195	301	10
196	257	7
196	98	8
196	40	8
196	9	10
196	19	9
196	95	5
196	233	7
196	294	4
196	100	4
196	381	1
196	134	4
196	311	6
196	250	5
196	364	3
196	44	7
196	209	7
196	26	2
196	270	6
197	135	3
197	255	1
197	221	9
197	331	1
197	233	3
197	77	5
197	181	2
197	339	10
197	367	6
197	117	1
197	54	6
198	276	8
198	150	1
198	327	7
198	287	7
198	295	1
198	366	6
199	126	4
199	347	3
199	132	3
199	268	6
199	42	7
199	279	4
199	13	7
199	380	7
199	143	3
199	184	3
199	346	3
199	255	2
199	286	2
200	373	6
200	62	9
201	215	7
201	291	4
201	11	9
201	356	1
201	346	1
201	28	4
201	156	5
201	59	8
201	361	8
201	314	10
201	337	5
201	160	2
201	57	1
202	141	10
202	100	7
202	101	4
202	325	10
202	209	3
202	52	9
202	39	6
202	51	9
202	302	10
202	148	6
202	255	9
202	112	4
202	128	3
202	324	6
202	133	4
203	284	5
203	291	5
203	173	6
203	281	4
203	17	9
203	278	8
203	103	2
203	233	7
203	260	2
203	62	3
203	343	5
203	82	5
203	273	3
203	60	4
203	353	7
203	253	1
203	206	10
203	348	10
203	157	2
203	169	3
204	69	9
204	237	3
204	341	9
204	25	1
204	57	6
205	273	10
205	283	4
205	4	8
205	171	4
205	17	5
205	204	6
205	49	9
205	114	4
205	295	4
205	386	4
205	303	4
205	236	7
205	88	1
205	383	4
205	7	7
206	152	10
206	15	9
206	77	3
206	171	8
206	375	3
206	40	2
206	291	2
206	236	8
207	321	6
208	322	3
208	215	9
208	67	7
208	30	7
208	253	9
208	192	7
208	15	10
208	12	4
208	204	10
208	291	4
208	182	3
208	364	9
208	347	7
208	360	2
209	260	8
209	16	7
209	280	7
209	222	2
209	67	10
209	51	3
209	102	8
209	227	6
209	316	6
209	122	4
209	286	4
210	302	6
210	184	2
210	61	2
211	218	4
211	388	4
211	79	6
211	223	6
211	21	9
211	26	9
211	101	9
211	194	8
211	193	7
211	172	2
211	190	2
211	106	2
212	67	9
212	69	1
212	351	8
212	2	8
212	240	5
212	161	9
212	58	1
212	30	8
212	346	1
212	243	2
212	289	3
212	140	3
212	203	4
212	229	1
212	74	8
212	71	8
212	155	10
213	384	10
213	40	3
213	280	9
213	355	10
213	266	2
213	283	6
213	183	5
213	112	8
213	282	7
213	34	2
213	89	1
213	86	3
213	236	7
213	95	9
213	325	9
213	219	5
213	161	10
213	92	2
214	5	1
215	348	7
215	170	7
215	90	6
215	362	4
215	8	1
215	228	8
215	301	9
215	44	9
215	47	6
215	396	3
215	266	7
215	137	7
215	277	10
215	310	1
215	92	8
215	336	2
215	370	5
215	230	9
215	253	2
216	50	7
216	138	5
216	76	9
216	184	5
216	10	10
216	30	4
216	115	7
216	191	2
216	297	9
216	57	1
217	195	6
217	211	7
217	336	3
217	172	5
217	114	1
217	243	5
217	366	8
217	379	10
217	367	1
217	188	9
217	207	8
217	58	8
217	330	9
217	18	2
218	40	2
218	75	4
218	71	2
218	362	9
218	371	8
218	27	4
218	3	2
218	338	5
218	23	4
218	374	4
218	247	8
218	100	10
218	256	9
218	10	4
218	329	4
218	292	6
218	158	4
218	126	1
218	59	4
219	360	6
219	306	6
219	351	10
219	188	8
219	201	2
219	7	2
220	270	2
220	232	5
220	278	2
220	102	7
220	205	7
220	331	2
220	241	8
221	315	6
221	43	3
221	297	1
221	272	6
221	289	5
221	14	3
222	212	8
222	215	1
222	252	3
222	221	9
222	89	7
222	55	10
222	265	1
222	230	6
222	151	10
222	46	10
223	211	5
224	381	7
224	221	9
224	251	3
224	399	6
224	227	5
224	9	7
224	310	3
224	393	7
225	52	1
225	54	8
225	219	2
225	69	1
225	263	4
225	71	1
225	384	4
225	190	9
225	56	4
225	157	9
225	325	10
225	322	4
225	68	3
225	299	2
225	360	2
225	180	1
225	166	7
226	324	2
226	23	3
226	332	6
226	306	3
226	144	5
226	229	10
226	390	10
226	192	2
226	303	3
226	143	10
227	355	8
227	186	6
227	120	8
227	279	7
227	365	8
227	280	3
227	214	8
227	393	9
227	75	4
228	301	1
228	225	6
228	206	10
228	80	1
229	76	1
229	1	8
229	139	2
229	18	2
229	10	10
229	40	3
229	196	4
229	202	3
229	197	8
229	276	8
229	100	7
229	305	1
229	4	2
229	22	9
229	205	7
229	70	6
230	164	3
230	210	7
230	212	10
230	71	5
230	317	3
230	211	2
230	267	5
230	254	9
230	181	6
230	38	9
230	356	4
230	357	8
230	51	1
231	197	8
231	54	1
231	164	1
231	151	9
231	292	3
231	261	1
231	116	7
231	218	8
231	207	2
231	83	1
231	331	7
231	172	1
231	342	7
232	161	7
232	40	7
232	376	7
232	16	6
232	140	7
232	111	4
232	102	8
232	54	7
232	385	6
232	126	3
232	86	7
232	41	4
232	21	4
232	249	2
232	379	1
232	178	4
232	336	5
233	242	3
233	305	4
233	351	5
233	97	6
233	382	7
233	357	2
233	290	2
233	216	9
233	217	7
233	294	9
233	110	4
233	372	4
233	1	3
233	346	5
233	358	6
233	145	1
233	380	2
233	160	6
233	152	8
233	233	8
234	46	6
234	236	8
234	194	5
234	29	1
234	5	4
234	78	2
234	132	2
234	134	2
234	45	10
234	76	5
234	64	7
234	285	7
234	88	3
234	372	9
234	289	10
234	340	4
234	279	10
234	47	4
234	254	9
234	339	8
235	166	7
235	9	3
235	206	7
235	256	9
235	316	10
235	68	3
235	116	3
235	260	1
235	27	10
235	369	9
236	311	3
237	316	9
237	217	3
237	299	3
237	296	10
237	206	5
237	5	3
238	264	8
238	340	2
238	160	6
238	106	8
238	236	3
238	71	6
238	68	4
238	54	1
238	33	1
238	292	8
238	178	9
238	89	9
238	174	6
238	189	4
238	321	4
238	295	7
238	302	10
239	148	2
239	225	8
239	175	1
239	389	8
239	160	10
239	30	1
239	396	1
239	182	8
239	178	10
239	335	5
239	9	1
239	52	6
239	72	6
239	319	5
239	313	10
239	376	3
239	70	10
240	281	9
240	214	5
240	110	10
240	186	4
240	167	9
240	204	6
240	249	7
240	3	7
240	236	9
240	159	5
240	367	10
240	345	5
240	320	9
240	251	2
240	265	3
240	117	3
241	190	7
241	396	8
241	97	7
241	84	4
241	89	2
241	328	6
241	265	6
241	305	10
241	187	3
241	288	3
241	233	6
242	35	5
242	160	4
242	182	3
242	256	6
242	152	4
242	104	4
242	26	5
242	140	10
242	135	3
242	390	1
242	292	1
242	171	8
242	91	7
242	197	1
242	112	4
242	200	3
242	108	8
242	216	5
242	254	5
243	111	2
243	141	3
243	235	9
243	181	4
243	130	8
243	26	2
243	101	3
243	72	5
243	268	3
243	133	9
243	106	9
243	198	4
243	323	4
243	90	7
243	119	7
243	360	7
244	337	2
244	113	4
244	270	3
244	238	5
244	327	9
244	257	2
244	70	8
244	83	6
244	371	4
244	369	4
245	3	9
245	225	9
245	303	5
245	289	4
245	52	5
245	260	3
245	223	3
245	63	8
245	236	1
246	375	7
246	309	2
246	296	2
246	373	9
246	260	6
247	145	1
247	245	7
247	319	9
247	156	10
247	174	4
248	222	8
248	1	10
248	108	2
248	329	2
248	312	1
248	261	9
248	235	9
248	226	8
248	191	6
248	24	4
248	103	3
248	19	6
248	140	3
248	76	10
248	156	4
248	397	6
248	210	4
249	286	6
249	81	7
249	207	9
249	307	10
249	82	6
250	129	2
251	90	6
251	155	5
251	3	2
251	135	10
251	206	3
252	74	7
252	235	6
252	181	7
252	290	1
252	110	5
252	295	9
252	329	7
252	58	3
252	121	1
252	163	5
252	245	3
252	334	8
252	291	8
252	120	8
252	206	9
252	298	6
253	219	3
253	349	2
253	158	10
253	235	8
253	251	7
253	152	5
253	298	9
253	300	10
253	331	3
254	264	4
254	265	1
254	141	2
254	301	4
254	131	2
255	316	9
255	169	6
255	212	6
255	353	8
255	152	5
255	334	9
255	204	6
255	148	10
255	367	9
255	352	4
255	400	4
255	98	8
255	88	1
256	107	1
257	393	7
257	178	7
257	261	8
257	288	10
257	287	8
257	318	4
257	360	3
257	319	1
257	2	7
257	153	1
257	112	4
258	16	8
258	273	1
258	133	8
258	12	9
258	384	1
258	246	6
258	362	7
258	326	8
258	337	7
258	80	1
258	45	8
258	267	8
258	236	5
258	378	1
258	249	5
258	250	7
259	204	3
259	293	9
259	354	4
259	26	10
259	74	1
259	54	1
259	92	6
259	160	1
259	374	5
259	143	5
259	47	1
259	152	4
259	61	3
259	177	7
259	217	10
259	59	7
259	66	5
260	228	5
260	348	10
260	44	4
260	131	2
260	27	4
260	41	10
260	265	7
260	59	9
261	351	4
261	246	7
261	144	8
261	260	1
261	42	5
261	275	1
262	1	5
262	374	8
262	180	6
262	269	4
262	197	6
262	311	3
262	285	8
262	66	9
262	399	4
262	98	1
262	213	7
262	317	10
263	81	5
263	169	7
263	269	3
263	311	7
263	25	8
263	63	1
263	247	7
263	177	3
263	299	6
263	20	4
264	400	2
264	306	6
264	274	8
264	165	5
264	280	8
264	217	3
264	75	10
264	319	7
264	315	3
264	346	5
264	18	3
264	48	9
264	88	2
264	211	8
264	178	7
264	312	1
264	115	6
265	156	9
265	25	4
265	211	6
266	137	7
266	120	8
266	136	9
266	118	1
266	131	1
266	249	8
267	86	6
267	83	1
267	72	10
267	4	4
267	314	1
267	50	4
267	306	2
267	80	4
268	137	10
268	23	6
268	178	6
268	389	10
268	347	8
268	318	7
268	106	1
268	160	5
268	293	1
268	87	5
268	70	7
268	42	5
268	86	1
268	308	1
269	120	4
270	100	1
270	273	10
270	357	4
270	90	10
270	396	6
270	294	2
270	195	8
270	182	5
270	291	10
270	149	4
270	178	3
270	275	5
271	250	8
271	170	1
271	232	4
271	383	7
271	295	3
271	298	3
271	365	3
271	231	8
271	204	6
271	321	2
271	196	4
271	246	3
271	331	1
271	47	6
271	207	2
272	139	6
272	376	3
272	290	6
272	241	9
272	68	4
272	113	4
272	264	6
273	296	6
273	267	9
273	174	3
273	101	4
273	64	8
273	217	10
273	57	8
273	92	10
274	370	2
274	259	4
275	110	3
275	168	4
275	315	1
275	322	7
275	333	3
275	26	9
275	330	5
275	205	7
275	125	5
275	114	4
275	61	1
275	295	9
275	356	10
275	290	1
275	138	9
275	163	9
275	135	9
275	203	5
276	47	2
276	197	7
276	366	5
276	307	9
276	42	9
276	84	1
276	358	9
276	115	10
276	6	10
276	348	1
276	357	9
276	384	6
276	221	8
276	236	3
276	173	2
276	224	3
276	72	5
276	325	5
277	36	2
277	196	4
277	103	2
277	312	10
277	145	2
278	135	1
278	224	10
278	87	1
278	275	5
278	30	9
278	388	5
278	5	5
278	305	7
278	97	3
278	255	7
278	85	10
278	84	2
278	157	8
278	366	4
278	215	3
278	96	9
278	220	5
279	400	4
279	240	1
279	129	9
279	195	8
279	203	2
279	72	2
279	182	1
279	134	1
279	316	10
279	314	10
279	236	3
279	230	3
279	233	4
279	335	2
280	11	8
280	334	10
280	67	4
280	257	4
280	86	7
280	205	7
280	18	5
280	33	1
280	233	2
280	266	4
281	85	6
281	239	1
281	367	10
281	323	6
281	38	1
281	161	6
281	258	2
281	213	10
281	219	9
281	142	3
282	9	4
282	328	9
282	113	2
282	258	5
282	382	2
282	284	5
282	206	10
283	185	6
283	6	9
284	267	9
284	6	4
284	89	9
284	312	9
284	189	9
284	144	2
284	286	10
284	208	3
284	382	7
284	156	7
284	19	5
284	315	3
284	350	3
284	204	9
285	84	3
285	203	9
285	222	3
285	105	7
285	391	8
286	205	10
286	108	7
286	26	3
286	124	3
286	329	6
286	172	5
286	67	2
286	166	1
287	55	3
287	125	4
287	142	4
287	193	10
287	344	6
287	29	6
287	100	8
287	64	2
287	372	9
287	167	2
288	61	6
288	380	2
288	32	5
289	42	4
289	21	6
289	114	5
289	267	4
289	231	2
289	286	10
289	156	3
289	145	10
289	269	4
290	294	3
290	152	3
290	159	1
290	80	6
290	43	1
290	6	7
290	215	1
290	273	4
290	49	8
291	242	7
291	11	1
291	134	2
291	46	5
291	108	10
291	27	4
291	348	4
291	132	6
292	81	2
292	368	6
292	344	2
293	295	5
294	251	1
294	153	4
294	148	2
295	290	7
295	299	6
295	101	10
295	210	1
295	206	8
295	359	7
295	209	2
295	172	5
295	187	10
296	240	4
296	61	3
296	115	9
296	242	10
297	168	2
297	306	7
297	2	6
297	45	1
297	86	1
297	321	2
297	205	9
297	41	9
297	143	6
297	207	8
297	61	8
297	294	2
297	88	6
297	96	9
298	28	6
298	72	8
298	24	1
298	188	9
298	16	2
298	52	6
298	251	7
298	45	3
298	150	5
298	91	8
298	118	1
299	365	4
299	183	5
299	146	3
299	167	4
299	188	9
299	381	1
299	76	2
300	384	3
300	395	10
300	373	8
300	93	9
300	389	4
300	295	5
300	90	1
300	187	9
300	92	7
301	264	1
301	318	3
301	91	7
301	82	9
301	268	1
302	283	7
302	116	3
302	159	2
302	53	9
302	118	1
302	304	2
302	358	8
303	174	10
303	240	6
303	357	9
303	396	9
303	221	9
303	276	5
303	224	1
303	389	7
303	270	4
304	287	10
304	208	8
304	273	10
304	122	8
304	48	5
304	259	10
304	245	6
304	348	3
304	269	1
304	311	5
304	331	7
304	384	6
304	166	7
305	276	7
305	33	3
305	190	2
305	148	8
305	339	4
305	233	2
305	143	5
305	364	8
305	347	9
306	327	1
306	379	4
306	38	6
306	15	4
306	149	10
307	166	6
307	397	10
307	200	10
307	147	10
307	156	10
307	140	7
307	12	8
307	123	10
307	172	5
307	54	3
307	295	9
307	99	6
307	198	4
307	372	10
307	28	8
308	391	1
308	128	6
308	348	8
308	47	4
308	170	7
308	36	6
308	337	1
308	354	7
309	262	3
310	207	8
310	388	5
310	251	6
310	173	7
310	174	7
310	368	9
310	83	2
310	43	10
310	95	10
310	1	1
310	166	8
310	188	6
310	124	8
310	103	9
310	292	3
310	55	8
310	364	5
310	131	1
310	206	8
311	171	5
311	72	8
311	373	1
311	36	1
311	245	4
311	124	3
311	284	10
311	317	8
311	20	9
311	105	3
311	356	3
311	187	8
311	62	4
311	100	4
311	126	6
311	121	8
311	303	5
311	45	10
312	159	7
312	283	10
312	342	10
312	111	7
312	117	6
312	378	8
312	32	8
312	263	3
312	89	7
312	155	4
313	241	7
313	269	9
313	273	3
313	8	7
313	290	7
313	108	8
313	395	4
313	245	1
313	390	3
313	107	9
313	122	10
313	54	10
313	253	9
313	214	1
313	197	9
313	185	10
314	99	2
314	332	6
314	141	8
314	243	7
314	49	6
314	44	3
314	32	5
314	156	6
315	9	6
315	192	9
315	277	5
315	274	7
315	169	2
315	150	10
315	267	2
315	219	9
315	214	9
315	355	5
315	300	9
315	364	9
315	289	10
315	23	8
316	295	6
316	279	3
316	296	8
316	221	2
316	384	10
316	118	2
316	350	1
316	55	6
316	109	10
317	256	2
317	204	2
317	50	1
317	108	10
317	111	6
317	361	5
317	36	5
317	6	6
317	148	8
317	102	10
317	66	9
317	200	6
317	120	4
317	383	5
318	114	10
318	182	1
318	381	10
319	155	7
319	110	4
319	53	3
319	12	1
319	223	5
319	278	3
319	247	3
319	47	1
319	203	8
319	327	8
319	184	9
319	295	4
319	337	4
320	317	1
320	246	9
320	272	9
320	158	9
320	362	10
320	169	10
320	69	1
320	28	10
320	213	2
320	244	1
320	57	8
321	359	6
321	376	9
321	385	4
321	218	3
321	71	2
321	115	2
321	166	8
321	389	5
321	76	2
321	173	6
321	353	9
321	232	10
321	217	10
321	119	6
321	283	5
321	220	2
322	80	8
322	300	7
322	340	9
322	304	9
322	102	2
322	152	9
322	214	8
322	377	1
322	190	10
323	51	3
323	230	2
323	231	3
323	146	1
323	275	9
323	333	5
323	219	4
323	182	2
323	16	7
323	52	4
323	396	1
323	220	6
323	314	4
323	57	1
323	370	4
323	110	2
324	272	7
324	322	6
324	249	3
324	208	5
324	107	5
324	313	1
324	17	9
324	399	3
324	307	6
324	41	9
324	8	4
324	294	6
325	102	8
325	320	10
325	13	4
325	265	7
325	35	5
325	352	6
325	6	1
325	131	3
325	40	7
326	252	10
326	184	9
326	289	2
326	258	9
326	319	3
326	206	5
326	241	1
326	311	6
326	165	6
326	219	8
326	276	3
326	132	2
326	191	8
326	296	5
326	20	8
326	389	6
326	164	2
326	171	6
326	159	9
326	210	7
327	78	5
327	337	3
327	321	2
327	26	10
327	7	9
327	215	6
327	155	7
327	213	1
328	393	2
329	274	5
329	272	4
329	215	9
329	83	8
329	165	4
329	35	10
329	260	6
329	60	2
329	314	3
329	256	3
329	233	9
330	68	8
330	42	2
330	164	10
330	195	1
331	298	7
331	320	4
331	180	2
331	178	4
331	268	9
331	146	3
331	395	8
331	159	1
331	352	10
331	39	3
331	76	9
331	299	2
332	141	4
333	164	7
333	140	8
333	95	6
333	10	8
333	364	2
333	395	8
333	96	2
333	64	5
333	143	10
333	129	3
334	120	4
334	344	1
334	202	8
334	27	3
334	248	1
334	100	2
334	390	3
334	216	2
334	395	8
334	289	4
334	58	10
334	222	3
334	278	3
334	364	10
334	8	5
334	70	8
334	68	9
334	132	3
334	196	3
334	59	3
335	281	4
335	382	5
335	358	6
335	108	7
335	116	1
335	106	7
335	302	2
335	70	3
335	93	10
336	280	5
336	288	5
336	329	9
336	307	8
336	217	8
336	386	3
336	55	4
336	64	2
336	47	10
336	49	6
336	82	10
336	240	7
337	43	1
337	381	4
337	138	4
337	204	8
337	160	4
337	231	10
337	56	6
337	338	6
337	47	1
337	59	8
337	125	3
337	308	10
337	336	8
337	172	9
337	103	3
337	366	4
338	102	3
338	256	3
338	198	7
338	124	8
339	391	7
339	307	9
339	386	2
339	199	6
339	207	3
339	270	6
339	39	10
339	274	3
339	237	6
339	244	7
340	352	7
340	34	8
340	169	3
340	164	10
340	368	6
340	90	2
340	189	2
340	219	7
340	82	2
340	266	8
341	244	9
341	28	3
341	291	1
341	189	4
341	171	8
341	340	2
341	400	9
341	234	1
341	302	5
341	320	5
341	65	5
341	58	7
341	152	8
341	338	7
341	138	9
341	222	9
341	39	4
341	31	3
341	80	8
341	145	3
342	179	8
342	276	8
342	168	2
342	40	6
343	39	1
343	342	4
343	193	6
343	313	2
343	321	8
343	96	7
343	347	4
343	307	3
343	369	8
343	190	7
343	225	10
343	326	8
343	218	7
343	181	9
343	59	6
343	21	8
343	258	9
343	188	3
343	116	9
344	65	4
344	219	8
344	37	9
344	299	7
344	352	9
344	16	1
344	163	7
344	210	5
344	96	6
344	13	5
344	103	9
344	209	5
344	216	6
344	377	4
344	168	4
344	149	10
344	152	3
344	126	8
344	82	3
344	42	8
345	52	10
345	347	8
345	203	9
345	13	1
345	109	2
345	240	7
345	318	9
345	182	10
345	126	9
345	148	1
345	88	1
345	102	4
345	33	3
345	95	1
345	395	10
345	370	10
346	296	10
346	93	9
346	377	9
346	254	8
346	384	6
347	331	9
347	240	5
348	165	2
348	259	1
349	355	4
350	134	10
350	128	3
350	208	7
350	121	6
350	228	4
350	398	9
350	326	4
350	371	1
350	147	10
350	100	1
350	175	8
350	38	6
350	234	3
350	378	2
350	302	10
350	346	2
350	292	6
350	75	3
350	23	7
350	294	9
351	230	9
351	347	4
351	312	4
351	261	7
351	57	5
351	35	3
351	385	3
351	247	7
351	65	1
351	333	7
351	356	2
351	154	8
351	149	3
351	28	10
352	178	10
352	389	4
352	281	8
352	357	8
352	308	10
352	395	10
352	105	6
352	323	9
352	136	4
352	338	10
352	257	5
352	277	9
352	300	8
352	361	4
352	290	6
352	101	10
352	79	6
352	77	7
352	380	5
353	350	4
353	218	9
353	85	9
353	149	3
353	169	1
353	190	6
353	224	8
354	123	4
354	173	7
354	20	3
354	344	2
354	57	5
355	220	4
355	17	1
355	75	7
355	160	4
355	3	7
355	378	7
355	192	8
356	189	7
356	280	5
356	212	9
356	6	5
356	113	3
356	378	1
356	337	4
356	62	1
356	70	8
356	16	8
356	335	8
356	54	1
356	179	2
356	289	8
356	208	4
356	112	7
356	284	2
357	225	3
357	376	7
357	100	4
358	92	7
358	62	4
358	252	5
358	119	4
358	371	9
358	118	2
358	157	3
358	125	7
358	99	10
358	123	9
358	140	9
358	169	4
358	267	8
358	329	5
359	365	7
359	225	3
359	24	5
359	160	6
359	49	2
359	143	1
359	198	9
359	228	7
359	125	7
359	312	8
359	255	10
359	398	4
359	326	4
359	381	9
359	38	1
359	190	4
359	56	5
359	237	4
359	268	2
359	74	2
360	57	6
360	340	9
360	60	7
360	386	6
360	184	8
360	354	5
360	347	6
360	166	5
360	391	8
360	144	5
360	32	10
360	63	4
361	349	4
362	221	5
362	392	3
362	152	4
362	235	8
362	278	3
362	344	9
362	281	1
362	376	6
362	197	5
362	80	4
363	207	6
363	26	7
363	87	5
363	220	5
363	309	4
363	135	3
363	15	7
363	389	6
363	303	5
363	336	9
363	211	7
363	66	7
363	269	1
363	173	1
363	261	3
363	188	4
363	43	5
364	104	5
364	325	8
364	129	2
364	365	8
364	134	6
364	214	6
364	229	3
364	256	2
364	64	2
364	289	4
365	166	7
366	293	7
366	10	5
366	12	1
366	354	10
366	252	8
366	181	5
366	23	9
366	359	4
366	79	5
366	221	10
366	158	3
366	205	6
366	37	9
367	172	5
367	30	7
367	356	7
367	250	7
367	57	6
367	124	6
367	18	5
367	65	2
367	343	8
367	388	3
367	45	9
367	15	8
367	366	5
367	132	4
367	384	3
367	107	9
368	148	6
369	46	4
369	132	2
369	83	5
369	395	8
369	230	4
369	318	5
369	10	4
370	105	5
370	379	2
370	99	4
370	313	8
371	258	5
371	362	3
371	254	1
371	46	10
372	190	10
372	36	1
372	314	2
372	137	3
372	341	1
372	213	4
372	159	6
372	54	1
372	366	5
372	334	5
372	246	9
372	229	10
372	124	6
372	383	10
373	32	8
373	155	5
373	224	3
373	134	4
373	318	4
373	372	1
373	359	1
374	353	9
374	158	10
374	131	10
374	62	2
374	157	7
374	273	6
374	362	8
374	287	2
374	125	1
375	24	4
375	367	8
375	151	10
375	262	3
375	306	2
375	391	9
375	400	8
375	152	2
375	359	8
375	378	10
376	112	9
376	232	5
376	288	5
376	31	1
376	188	1
376	147	8
376	157	4
377	112	4
377	398	6
377	12	8
377	287	4
377	205	8
377	134	2
377	75	7
377	373	5
377	360	10
378	325	7
378	199	7
378	119	8
378	70	9
378	151	8
378	269	10
378	230	6
378	278	3
378	195	8
378	87	7
378	223	4
378	18	1
378	231	5
379	104	4
380	67	4
381	113	2
382	73	6
382	392	5
383	279	5
383	352	5
383	299	4
383	268	1
383	369	10
383	181	2
383	382	9
383	233	7
384	41	3
384	232	5
384	325	5
384	342	5
384	247	5
384	140	7
384	103	3
384	286	6
384	82	7
384	190	3
384	251	3
384	201	7
384	367	9
384	339	1
384	346	5
384	170	9
385	86	10
385	15	6
385	213	10
386	279	5
386	53	9
386	169	10
386	140	10
386	286	3
386	89	1
386	328	7
386	11	8
386	206	9
386	203	6
386	43	7
386	297	4
386	84	2
386	74	2
386	92	5
386	288	4
387	375	4
387	140	5
387	165	9
387	62	2
387	19	10
387	226	8
387	347	9
387	194	5
387	25	4
387	139	8
388	121	4
388	93	8
388	375	2
389	116	4
389	59	5
389	310	6
389	361	10
389	238	8
390	205	8
390	188	10
390	77	2
391	88	1
391	16	7
391	181	7
391	312	1
391	43	7
391	85	1
391	70	4
391	3	8
391	208	1
391	258	1
392	244	3
392	236	1
393	313	3
393	364	5
393	218	8
393	37	5
393	292	4
393	233	10
393	38	7
393	303	7
393	297	3
393	163	2
393	134	5
393	5	2
393	256	10
393	172	5
393	50	8
393	258	10
393	64	9
394	372	1
394	169	2
395	303	10
395	189	8
395	257	10
395	135	5
395	374	5
395	227	8
395	325	6
395	294	2
395	9	4
396	123	7
396	196	3
396	197	2
396	229	6
396	28	5
396	288	2
396	23	6
396	212	7
396	383	5
396	292	8
396	182	3
396	104	10
396	201	9
396	139	8
396	16	10
396	259	10
396	371	2
397	12	3
398	108	6
398	204	6
398	345	4
398	106	7
398	362	4
399	398	6
399	148	5
399	51	1
399	131	2
399	22	6
399	205	1
399	171	1
399	181	1
400	19	9
400	276	6
400	117	3
400	386	4
\.


--
-- TOC entry 3570 (class 0 OID 65916)
-- Dependencies: 237
-- Data for Name: role_local; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.role_local (roleid, rolename, hourlywage) FROM stdin;
1	קופאי	30.00
2	סדרן מדפים	30.00
3	מנהל משמרת	40.00
4	משלוחן	40.00
5	עוזר למחסן	35.00
8	ראש צוות ייצור	42.00
9	טכנאי תחזוקה	35.00
10	מנהל שלב התססה	40.00
11	בקר איכות	38.00
13	טכנאי ציוד	36.00
14	עובד פס ייצור	32.00
6	עובד ניקיון	45.00
7	כימאי מעבדה	36.00
\.


--
-- TOC entry 3572 (class 0 OID 65926)
-- Dependencies: 239
-- Data for Name: supplier_local; Type: TABLE DATA; Schema: public; Owner: riki
--

COPY public.supplier_local (supplierid, suppliername, phone) FROM stdin;
1	דינמיקה טק	03-1234567
2	א.ת. מיכון	03-2345678
3	אביב טכנולוגי	03-3456789
4	משאבים לוג	03-4567890
5	אריה טכנולוג	03-5678901
6	אוריון שיווק	03-6789012
7	מטרו מערכות	03-7890123
8	תמר בע"מ	03-8901234
9	אספקה מרכז	03-9012345
10	קשרי תעשייה	03-0123456
11	נתיב פתרונות	02-1230987
12	שירותי פוקס	02-2345679
13	תפנית טכנולוג	02-3456780
14	אורח חיים	02-4567891
15	גבעול טכנולוג	02-5678902
16	טכנולוגיה מת	02-6789013
17	פיניקס ייבוא	02-7890124
18	לוגיסטיקת ש	02-8901235
19	פוקניק טק	02-9012346
20	אוראל שיווק	02-0123457
\.


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 245
-- Name: employee_merge_employeeid_seq; Type: SEQUENCE SET; Schema: public; Owner: riki
--

SELECT pg_catalog.setval('public.employee_merge_employeeid_seq', 1, false);


--
-- TOC entry 3348 (class 2606 OID 40992)
-- Name: containers_ containers__pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.containers_
    ADD CONSTRAINT containers__pkey PRIMARY KEY (containerid_);


--
-- TOC entry 3374 (class 2606 OID 65925)
-- Name: employee_local employee_local_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.employee_local
    ADD CONSTRAINT employee_local_pkey PRIMARY KEY (employeeid);


--
-- TOC entry 3384 (class 2606 OID 66023)
-- Name: employee_merge employee_merge_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.employee_merge
    ADD CONSTRAINT employee_merge_pkey PRIMARY KEY (employeeid);


--
-- TOC entry 3350 (class 2606 OID 40994)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employeeid);


--
-- TOC entry 3352 (class 2606 OID 40996)
-- Name: finalproduct_ finalproduct__pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.finalproduct_
    ADD CONSTRAINT finalproduct__pkey PRIMARY KEY (batchnumber_);


--
-- TOC entry 3354 (class 2606 OID 74056)
-- Name: finalproduct_ finalproduct_productid_unique; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.finalproduct_
    ADD CONSTRAINT finalproduct_productid_unique UNIQUE (productid);


--
-- TOC entry 3370 (class 2606 OID 41058)
-- Name: grape_varieties grape_varieties_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.grape_varieties
    ADD CONSTRAINT grape_varieties_pkey PRIMARY KEY (id);


--
-- TOC entry 3356 (class 2606 OID 40998)
-- Name: grapes grapes_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.grapes
    ADD CONSTRAINT grapes_pkey PRIMARY KEY (grapeid);


--
-- TOC entry 3358 (class 2606 OID 41000)
-- Name: materials_ materials__pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.materials_
    ADD CONSTRAINT materials__pkey PRIMARY KEY (materialid_);


--
-- TOC entry 3386 (class 2606 OID 74076)
-- Name: ordermaterials ordermaterials_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.ordermaterials
    ADD CONSTRAINT ordermaterials_pkey PRIMARY KEY (orderid, materialid);


--
-- TOC entry 3380 (class 2606 OID 65940)
-- Name: orders_local orders_local_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.orders_local
    ADD CONSTRAINT orders_local_pkey PRIMARY KEY (orderid);


--
-- TOC entry 3360 (class 2606 OID 41002)
-- Name: process_equipment process_equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.process_equipment
    ADD CONSTRAINT process_equipment_pkey PRIMARY KEY (equipmentid_, processid_);


--
-- TOC entry 3362 (class 2606 OID 41004)
-- Name: process_materials process_materials_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.process_materials
    ADD CONSTRAINT process_materials_pkey PRIMARY KEY (processid_, materialid_);


--
-- TOC entry 3364 (class 2606 OID 41006)
-- Name: processcontainers processcontainers_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.processcontainers
    ADD CONSTRAINT processcontainers_pkey PRIMARY KEY (containerid_, processid_);


--
-- TOC entry 3378 (class 2606 OID 65935)
-- Name: product_local product_local_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.product_local
    ADD CONSTRAINT product_local_pkey PRIMARY KEY (productid);


--
-- TOC entry 3366 (class 2606 OID 41008)
-- Name: productionequipment_ productionequipment__pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.productionequipment_
    ADD CONSTRAINT productionequipment__pkey PRIMARY KEY (equipmentid_);


--
-- TOC entry 3368 (class 2606 OID 41010)
-- Name: productionprocess_ productionprocess__pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__pkey PRIMARY KEY (processid_);


--
-- TOC entry 3382 (class 2606 OID 65948)
-- Name: purchase_local purchase_local_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.purchase_local
    ADD CONSTRAINT purchase_local_pkey PRIMARY KEY (purchaseid);


--
-- TOC entry 3372 (class 2606 OID 65920)
-- Name: role_local role_local_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.role_local
    ADD CONSTRAINT role_local_pkey PRIMARY KEY (roleid);


--
-- TOC entry 3376 (class 2606 OID 65930)
-- Name: supplier_local supplier_local_pkey; Type: CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.supplier_local
    ADD CONSTRAINT supplier_local_pkey PRIMARY KEY (supplierid);


--
-- TOC entry 3410 (class 2620 OID 90431)
-- Name: productionprocess_ trg_complete_batch_bottling; Type: TRIGGER; Schema: public; Owner: riki
--

CREATE TRIGGER trg_complete_batch_bottling AFTER INSERT ON public.productionprocess_ FOR EACH ROW EXECUTE FUNCTION public.update_bottling_date_if_completed();


--
-- TOC entry 3411 (class 2620 OID 90425)
-- Name: product_local trg_update_last_updated; Type: TRIGGER; Schema: public; Owner: riki
--

CREATE TRIGGER trg_update_last_updated BEFORE UPDATE OF price ON public.product_local FOR EACH ROW EXECUTE FUNCTION public.update_last_updated();


--
-- TOC entry 3409 (class 2620 OID 90427)
-- Name: materials_ trg_validate_material_insert; Type: TRIGGER; Schema: public; Owner: riki
--

CREATE TRIGGER trg_validate_material_insert BEFORE INSERT ON public.materials_ FOR EACH ROW EXECUTE FUNCTION public.validate_material_quantity();


--
-- TOC entry 3406 (class 2606 OID 66024)
-- Name: employee_merge employee_merge_roleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.employee_merge
    ADD CONSTRAINT employee_merge_roleid_fkey FOREIGN KEY (roleid) REFERENCES public.role_local(roleid);


--
-- TOC entry 3394 (class 2606 OID 41060)
-- Name: productionprocess_ fk_employee; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT fk_employee FOREIGN KEY (employeeid) REFERENCES public.employee(employeeid);


--
-- TOC entry 3398 (class 2606 OID 65952)
-- Name: employee_local fk_employee_role; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.employee_local
    ADD CONSTRAINT fk_employee_role FOREIGN KEY (roleid) REFERENCES public.role_local(roleid);


--
-- TOC entry 3387 (class 2606 OID 74057)
-- Name: finalproduct_ fk_finalproduct_productid; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.finalproduct_
    ADD CONSTRAINT fk_finalproduct_productid FOREIGN KEY (productid) REFERENCES public.product_local(productid);


--
-- TOC entry 3400 (class 2606 OID 65962)
-- Name: orderitems_local fk_orderitems_order; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.orderitems_local
    ADD CONSTRAINT fk_orderitems_order FOREIGN KEY (orderid) REFERENCES public.orders_local(orderid);


--
-- TOC entry 3401 (class 2606 OID 65967)
-- Name: orderitems_local fk_orderitems_product; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.orderitems_local
    ADD CONSTRAINT fk_orderitems_product FOREIGN KEY (productid) REFERENCES public.product_local(productid);


--
-- TOC entry 3399 (class 2606 OID 65957)
-- Name: orders_local fk_orders_supplier; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.orders_local
    ADD CONSTRAINT fk_orders_supplier FOREIGN KEY (supplierid) REFERENCES public.supplier_local(supplierid);


--
-- TOC entry 3402 (class 2606 OID 74036)
-- Name: purchase_local fk_purchase_employee; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.purchase_local
    ADD CONSTRAINT fk_purchase_employee FOREIGN KEY (employeeid) REFERENCES public.employee_local(employeeid);


--
-- TOC entry 3404 (class 2606 OID 65982)
-- Name: purchaseitems_local fk_purchaseitems_product; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.purchaseitems_local
    ADD CONSTRAINT fk_purchaseitems_product FOREIGN KEY (productid) REFERENCES public.product_local(productid);


--
-- TOC entry 3405 (class 2606 OID 65977)
-- Name: purchaseitems_local fk_purchaseitems_purchase; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.purchaseitems_local
    ADD CONSTRAINT fk_purchaseitems_purchase FOREIGN KEY (purchaseid) REFERENCES public.purchase_local(purchaseid);


--
-- TOC entry 3407 (class 2606 OID 74082)
-- Name: ordermaterials ordermaterials_materialid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.ordermaterials
    ADD CONSTRAINT ordermaterials_materialid_fkey FOREIGN KEY (materialid) REFERENCES public.materials_(materialid_);


--
-- TOC entry 3408 (class 2606 OID 74077)
-- Name: ordermaterials ordermaterials_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.ordermaterials
    ADD CONSTRAINT ordermaterials_orderid_fkey FOREIGN KEY (orderid) REFERENCES public.orders_local(orderid);


--
-- TOC entry 3388 (class 2606 OID 41011)
-- Name: process_equipment process_equipment_equipmentid__fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.process_equipment
    ADD CONSTRAINT process_equipment_equipmentid__fkey FOREIGN KEY (equipmentid_) REFERENCES public.productionequipment_(equipmentid_);


--
-- TOC entry 3389 (class 2606 OID 41016)
-- Name: process_equipment process_equipment_processid__fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.process_equipment
    ADD CONSTRAINT process_equipment_processid__fkey FOREIGN KEY (processid_) REFERENCES public.productionprocess_(processid_);


--
-- TOC entry 3390 (class 2606 OID 41021)
-- Name: process_materials process_materials_materialid__fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.process_materials
    ADD CONSTRAINT process_materials_materialid__fkey FOREIGN KEY (materialid_) REFERENCES public.materials_(materialid_);


--
-- TOC entry 3391 (class 2606 OID 41026)
-- Name: process_materials process_materials_processid__fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.process_materials
    ADD CONSTRAINT process_materials_processid__fkey FOREIGN KEY (processid_) REFERENCES public.productionprocess_(processid_);


--
-- TOC entry 3392 (class 2606 OID 41031)
-- Name: processcontainers processcontainers_containerid__fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.processcontainers
    ADD CONSTRAINT processcontainers_containerid__fkey FOREIGN KEY (containerid_) REFERENCES public.containers_(containerid_);


--
-- TOC entry 3393 (class 2606 OID 41036)
-- Name: processcontainers processcontainers_processid__fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.processcontainers
    ADD CONSTRAINT processcontainers_processid__fkey FOREIGN KEY (processid_) REFERENCES public.productionprocess_(processid_);


--
-- TOC entry 3395 (class 2606 OID 41041)
-- Name: productionprocess_ productionprocess__batchnumber__fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__batchnumber__fkey FOREIGN KEY (batchnumber_) REFERENCES public.finalproduct_(batchnumber_);


--
-- TOC entry 3396 (class 2606 OID 74050)
-- Name: productionprocess_ productionprocess__employeeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__employeeid_fkey FOREIGN KEY (employeeid) REFERENCES public.employee_merge(employeeid);


--
-- TOC entry 3397 (class 2606 OID 41046)
-- Name: productionprocess_ productionprocess__grapeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__grapeid_fkey FOREIGN KEY (grapeid) REFERENCES public.grapes(grapeid);


--
-- TOC entry 3403 (class 2606 OID 74045)
-- Name: purchase_local purchase_local_employeeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: riki
--

ALTER TABLE ONLY public.purchase_local
    ADD CONSTRAINT purchase_local_employeeid_fkey FOREIGN KEY (employeeid) REFERENCES public.employee_merge(employeeid);


-- Completed on 2025-05-27 10:35:26

--
-- PostgreSQL database dump complete
--

