PGDMP  ,    &                }        
   mydatabase    17.4 (Debian 17.4-1.pgdg120+2)    17.2 ~    	           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            
           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false                       1262    16384 
   mydatabase    DATABASE     u   CREATE DATABASE mydatabase WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';
    DROP DATABASE mydatabase;
                     riki    false                        3079    57619    postgres_fdw 	   EXTENSION     @   CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;
    DROP EXTENSION postgres_fdw;
                        false                       0    0    EXTENSION postgres_fdw    COMMENT     [   COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';
                             false    2                       1255    90423 Q   add_material_if_not_exists(integer, character varying, double precision, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.add_material_if_not_exists(IN mat_id integer, IN mat_name character varying, IN quantity double precision, IN supplier_id integer)
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
 �   DROP PROCEDURE public.add_material_if_not_exists(IN mat_id integer, IN mat_name character varying, IN quantity double precision, IN supplier_id integer);
       public               riki    false                       1255    90448    check_stouck(integer, integer)    FUNCTION       CREATE FUNCTION public.check_stouck(orderid integer, productid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
 stock_req INTEGER;
 quan_is INTEGER;
BEGIN
  SELECT p.stockquantity INTO stock_req
  FROM product_local p
  WHERE p.productId= productID;

  SELECT quantity INTO quan_is
  FROM orderitems o
  WHERE o.orderid= orderid;

IF stock_req IS NULL OR quan_is IS NULL 
THEN
 RAISE NOTICE 'DATA MISSING';
  RETURN FALSE;
  END IF;

IF stock_req >= quan_is
THEN
RETURN TRUE;
ELSE
 RETURN TRUE;
END IF;

END;
$$;
 G   DROP FUNCTION public.check_stouck(orderid integer, productid integer);
       public               riki    false                       1255    90449    check_stouck1(integer, integer)    FUNCTION       CREATE FUNCTION public.check_stouck1(orderid integer, proid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
 stock_req INTEGER;
 quan_is INTEGER;
BEGIN
  SELECT p.stockquantity INTO stock_req
  FROM product_local p
  WHERE p.productId= proID;

  SELECT quantity INTO quan_is
  FROM orderitems_local o
  WHERE o.orderid= orderid;

IF stock_req IS NULL OR quan_is IS NULL 
THEN
 RAISE NOTICE 'DATA MISSING';
  RETURN FALSE;
  END IF;

IF stock_req >= quan_is
THEN
RETURN TRUE;
ELSE
 RETURN TRUE;
END IF;

END;
$$;
 D   DROP FUNCTION public.check_stouck1(orderid integer, proid integer);
       public               riki    false                       1255    90450    check_stouck2(integer, integer)    FUNCTION       CREATE FUNCTION public.check_stouck2(ordid integer, proid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
 stock_req INTEGER;
 quan_is INTEGER;
BEGIN
  SELECT p.stockquantity INTO stock_req
  FROM product_local p
  WHERE p.productId= proID;

  SELECT quantity INTO quan_is
  FROM orderitems_local o
  WHERE o.orderid= ordid;

IF stock_req IS NULL OR quan_is IS NULL 
THEN
 RAISE NOTICE 'DATA MISSING';
  RETURN FALSE;
  END IF;

IF stock_req >= quan_is
THEN
RETURN TRUE;
ELSE
 RETURN TRUE;
END IF;

END;
$$;
 B   DROP FUNCTION public.check_stouck2(ordid integer, proid integer);
       public               riki    false                       1255    90457    check_stouck3(integer)    FUNCTION     �  CREATE FUNCTION public.check_stouck3(ordid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
 stock_req INTEGER;
item RECORD;
BEGIN

FOR item IN
    SELECT productId 
    FROM orderitems_local oi
    WHERE oi.orderid=ordid

LOOP  
  SELECT p.stockquantity INTO stock_req
  FROM product_local p
  WHERE p.productId= proID;

IF stock_req IS NULL OR stock_req < item.quantity THEN
 RAISE NOTICE 'Error in function: ';
 RETURN FALSE;
END IF;

END LOOP;

 RETURN TRUE;
END;
$$;
 3   DROP FUNCTION public.check_stouck3(ordid integer);
       public               riki    false                       1255    90458    check_stouck4(integer)    FUNCTION     �  CREATE FUNCTION public.check_stouck4(ordid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
 stock_req INTEGER;
item RECORD;
BEGIN

FOR item IN
    SELECT productId,quantity
    FROM orderitems_local oi
    WHERE oi.orderid=ordid

LOOP  
  SELECT p.stockquantity INTO stock_req
  FROM product_local p
  WHERE p.productId= item.productId;

IF stock_req IS NULL OR stock_req < item.quantity THEN
 RAISE NOTICE 'Error in function: ';
 RETURN FALSE;
END IF;

END LOOP;

 RETURN TRUE;
END;
$$;
 3   DROP FUNCTION public.check_stouck4(ordid integer);
       public               riki    false                       1255    90420 +   get_bottle_count_by_type(character varying)    FUNCTION     �  CREATE FUNCTION public.get_bottle_count_by_type(winetype_input character varying) RETURNS integer
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
 Q   DROP FUNCTION public.get_bottle_count_by_type(winetype_input character varying);
       public               riki    false                       1255    90421 )   get_orders_by_supplier(character varying)    FUNCTION     �  CREATE FUNCTION public.get_orders_by_supplier(supplier_name_input character varying) RETURNS refcursor
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
 T   DROP FUNCTION public.get_orders_by_supplier(supplier_name_input character varying);
       public               riki    false                       1255    90422 7   increase_prices_by_supplier(character varying, numeric) 	   PROCEDURE       CREATE PROCEDURE public.increase_prices_by_supplier(IN supplier_name_input character varying, IN percent_increase numeric)
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
 z   DROP PROCEDURE public.increase_prices_by_supplier(IN supplier_name_input character varying, IN percent_increase numeric);
       public               riki    false                       1255    90429 #   update_bottling_date_if_completed()    FUNCTION     �  CREATE FUNCTION public.update_bottling_date_if_completed() RETURNS trigger
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
 :   DROP FUNCTION public.update_bottling_date_if_completed();
       public               riki    false                       1255    90424    update_last_updated()    FUNCTION     �   CREATE FUNCTION public.update_last_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.last_updated := NOW();
  RETURN NEW;
END;
$$;
 ,   DROP FUNCTION public.update_last_updated();
       public               riki    false                       1255    90426    validate_material_quantity()    FUNCTION     �   CREATE FUNCTION public.validate_material_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.quantityavailable_ < 0 THEN
    RAISE EXCEPTION 'Cannot insert material with negative quantity';
  END IF;

  RETURN NEW;
END;
$$;
 3   DROP FUNCTION public.validate_material_quantity();
       public               riki    false            �           1417    57626    satge3_server    SERVER     �   CREATE SERVER satge3_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'satge3',
    host 'localhost',
    port '5432'
);
    DROP SERVER satge3_server;
                     riki    false    2    2    2                       0    0 &   USER MAPPING riki SERVER satge3_server    USER MAPPING     f   CREATE USER MAPPING FOR riki SERVER satge3_server OPTIONS (
    password '1234',
    "user" 'riki'
);
 1   DROP USER MAPPING FOR riki SERVER satge3_server;
                     riki    false            �            1259    40961    containers_    TABLE     {   CREATE TABLE public.containers_ (
    containerid_ integer NOT NULL,
    type_ integer,
    capacityl_ double precision
);
    DROP TABLE public.containers_;
       public         heap r       riki    false            �            1259    40964    employee    TABLE     �   CREATE TABLE public.employee (
    employeeid integer NOT NULL,
    role character varying(6),
    name character varying(10) NOT NULL
);
    DROP TABLE public.employee;
       public         heap r       riki    false            �            1259    65921    employee_local    TABLE     �   CREATE TABLE public.employee_local (
    employeeid numeric(5,0) NOT NULL,
    employeename character varying(15),
    hiredate date,
    roleid numeric(3,0)
);
 "   DROP TABLE public.employee_local;
       public         heap r       riki    false            �            1259    66016    employee_merge    TABLE     �   CREATE TABLE public.employee_merge (
    employeeid integer NOT NULL,
    employeename text NOT NULL,
    hiredate date,
    roleid integer
);
 "   DROP TABLE public.employee_merge;
       public         heap r       riki    false            �            1259    66015    employee_merge_employeeid_seq    SEQUENCE     �   CREATE SEQUENCE public.employee_merge_employeeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.employee_merge_employeeid_seq;
       public               riki    false    246                       0    0    employee_merge_employeeid_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.employee_merge_employeeid_seq OWNED BY public.employee_merge.employeeid;
          public               riki    false    245            �            1259    90460    employee_merge_employeeid_seq1    SEQUENCE     �   ALTER TABLE public.employee_merge ALTER COLUMN employeeid ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.employee_merge_employeeid_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               riki    false    246            �            1259    57660    employee_stage3    FOREIGN TABLE     �   CREATE FOREIGN TABLE public.employee_stage3 (
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
 +   DROP FOREIGN TABLE public.employee_stage3;
       public       f       riki    false    2186            �            1259    40967    finalproduct_    TABLE     #  CREATE TABLE public.finalproduct_ (
    quntityofbottle double precision,
    batchnumber_ integer NOT NULL,
    winetype_ character varying(30),
    bottlingdate_ date,
    numbottls integer NOT NULL,
    productid integer,
    CONSTRAINT check_positive_bottles CHECK ((numbottls >= 0))
);
 !   DROP TABLE public.finalproduct_;
       public         heap r       riki    false            �            1259    90462    finalproduct__batchnumber__seq    SEQUENCE     �   ALTER TABLE public.finalproduct_ ALTER COLUMN batchnumber_ ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.finalproduct__batchnumber__seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               riki    false    220            �            1259    41052    grape_varieties    TABLE     Y   CREATE TABLE public.grape_varieties (
    id integer NOT NULL,
    name text NOT NULL
);
 #   DROP TABLE public.grape_varieties;
       public         heap r       riki    false            �            1259    40970    grapes    TABLE     i   CREATE TABLE public.grapes (
    grapeid integer NOT NULL,
    variety integer,
    harvestdate_ date
);
    DROP TABLE public.grapes;
       public         heap r       riki    false            �            1259    40973 
   materials_    TABLE     �   CREATE TABLE public.materials_ (
    materialid_ integer NOT NULL,
    name_ character varying(10),
    supplierid_ integer,
    quantityavailable_ double precision
);
    DROP TABLE public.materials_;
       public         heap r       riki    false            �            1259    65941    orderitems_local    TABLE     �   CREATE TABLE public.orderitems_local (
    orderid numeric(5,0),
    productid numeric(5,0),
    quantity numeric(5,0),
    supplierprice numeric(5,2)
);
 $   DROP TABLE public.orderitems_local;
       public         heap r       riki    false            �            1259    57649    orderitems_stage3    FOREIGN TABLE     �   CREATE FOREIGN TABLE public.orderitems_stage3 (
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
 -   DROP FOREIGN TABLE public.orderitems_stage3;
       public       f       riki    false    2186            �            1259    74072    ordermaterials    TABLE     �   CREATE TABLE public.ordermaterials (
    orderid integer NOT NULL,
    materialid integer NOT NULL,
    quantity integer NOT NULL,
    supplierprice numeric(10,2) NOT NULL
);
 "   DROP TABLE public.ordermaterials;
       public         heap r       riki    false            �            1259    65936    orders_local    TABLE     �   CREATE TABLE public.orders_local (
    orderid numeric(5,0) NOT NULL,
    orderdate date,
    paymentterms character varying(15),
    supplierid numeric(5,0)
);
     DROP TABLE public.orders_local;
       public         heap r       riki    false            �            1259    57646    orders_stage3    FOREIGN TABLE     �   CREATE FOREIGN TABLE public.orders_stage3 (
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
 )   DROP FOREIGN TABLE public.orders_stage3;
       public       f       riki    false    2186            �            1259    40976    process_equipment    TABLE     n   CREATE TABLE public.process_equipment (
    equipmentid_ integer NOT NULL,
    processid_ integer NOT NULL
);
 %   DROP TABLE public.process_equipment;
       public         heap r       riki    false            �            1259    40979    process_materials    TABLE     �   CREATE TABLE public.process_materials (
    usageamount integer,
    processid_ integer NOT NULL,
    materialid_ integer NOT NULL
);
 %   DROP TABLE public.process_materials;
       public         heap r       riki    false            �            1259    40982    processcontainers    TABLE     n   CREATE TABLE public.processcontainers (
    containerid_ integer NOT NULL,
    processid_ integer NOT NULL
);
 %   DROP TABLE public.processcontainers;
       public         heap r       riki    false            �            1259    65931    product_local    TABLE     �   CREATE TABLE public.product_local (
    productid numeric(5,0) NOT NULL,
    productname character varying(15),
    price numeric(5,2),
    brand character varying(15),
    stockquantity numeric(5,0),
    last_updated timestamp without time zone
);
 !   DROP TABLE public.product_local;
       public         heap r       riki    false            �            1259    57628    product_stage3    FOREIGN TABLE       CREATE FOREIGN TABLE public.product_stage3 (
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
 *   DROP FOREIGN TABLE public.product_stage3;
       public       f       riki    false    2186            �            1259    40985    productionequipment_    TABLE     �   CREATE TABLE public.productionequipment_ (
    equipmentid_ integer NOT NULL,
    type_ character(10),
    status_ character varying(10)
);
 (   DROP TABLE public.productionequipment_;
       public         heap r       riki    false            �            1259    40988    productionprocess_    TABLE     �   CREATE TABLE public.productionprocess_ (
    processid_ integer NOT NULL,
    type_ integer,
    startdate_ date,
    enddate_ date,
    seqnumber integer,
    grapeid integer,
    employeeid integer,
    batchnumber_ integer
);
 &   DROP TABLE public.productionprocess_;
       public         heap r       riki    false            �            1259    90463 !   productionprocess__processid__seq    SEQUENCE     �   ALTER TABLE public.productionprocess_ ALTER COLUMN processid_ ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.productionprocess__processid__seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               riki    false    227            �            1259    65944    purchase_local    TABLE     �   CREATE TABLE public.purchase_local (
    purchaseid numeric(5,0) NOT NULL,
    purchasedate date,
    paymentmethod character varying(15),
    employeeid integer
);
 "   DROP TABLE public.purchase_local;
       public         heap r       riki    false            �            1259    65913    purchase_stage3    FOREIGN TABLE       CREATE FOREIGN TABLE public.purchase_stage3 (
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
 +   DROP FOREIGN TABLE public.purchase_stage3;
       public       f       riki    false    2186            �            1259    65949    purchaseitems_local    TABLE     �   CREATE TABLE public.purchaseitems_local (
    purchaseid numeric(5,0),
    productid numeric(5,0),
    quantity numeric(5,0)
);
 '   DROP TABLE public.purchaseitems_local;
       public         heap r       riki    false            �            1259    65910    purchaseitems_stage3    FOREIGN TABLE     �   CREATE FOREIGN TABLE public.purchaseitems_stage3 (
    purchaseid numeric(5,0),
    productid numeric(5,0),
    quantity numeric(5,0)
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'purchaseitems'
);
 0   DROP FOREIGN TABLE public.purchaseitems_stage3;
       public       f       riki    false    2186            �            1259    65916 
   role_local    TABLE     �   CREATE TABLE public.role_local (
    roleid numeric(3,0) NOT NULL,
    rolename character varying(15),
    hourlywage numeric(5,2)
);
    DROP TABLE public.role_local;
       public         heap r       riki    false            �            1259    57643    role_stage3    FOREIGN TABLE     �   CREATE FOREIGN TABLE public.role_stage3 (
    roleid integer,
    rolename character varying(50),
    hourlywage double precision
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'role'
);
 '   DROP FOREIGN TABLE public.role_stage3;
       public       f       riki    false    2186            �            1259    65926    supplier_local    TABLE     �   CREATE TABLE public.supplier_local (
    supplierid numeric(5,0) NOT NULL,
    suppliername character varying(15),
    phone character varying(10)
);
 "   DROP TABLE public.supplier_local;
       public         heap r       riki    false            �            1259    57637    supplier_stage3    FOREIGN TABLE     �   CREATE FOREIGN TABLE public.supplier_stage3 (
    supplierid integer,
    suppliername character varying(100),
    phone character varying(20)
)
SERVER satge3_server
OPTIONS (
    schema_name 'public',
    table_name 'supplier'
);
 +   DROP FOREIGN TABLE public.supplier_stage3;
       public       f       riki    false    2186            �            1259    82233    view_order_supplier_summary    VIEW     �   CREATE VIEW public.view_order_supplier_summary AS
 SELECT o.orderid,
    o.orderdate,
    s.suppliername
   FROM (public.orders_local o
     JOIN public.supplier_local s ON ((o.supplierid = s.supplierid)));
 .   DROP VIEW public.view_order_supplier_summary;
       public       v       riki    false    239    239    241    241    241            �            1259    82228     view_production_bottling_summary    VIEW     �  CREATE VIEW public.view_production_bottling_summary AS
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
 3   DROP VIEW public.view_production_bottling_summary;
       public       v       riki    false    227    227    218    218    220    220    220    225    225    227            �          0    40961    containers_ 
   TABLE DATA           F   COPY public.containers_ (containerid_, type_, capacityl_) FROM stdin;
    public               riki    false    218   ��       �          0    40964    employee 
   TABLE DATA           :   COPY public.employee (employeeid, role, name) FROM stdin;
    public               riki    false    219   <�       �          0    65921    employee_local 
   TABLE DATA           T   COPY public.employee_local (employeeid, employeename, hiredate, roleid) FROM stdin;
    public               riki    false    238   p�                 0    66016    employee_merge 
   TABLE DATA           T   COPY public.employee_merge (employeeid, employeename, hiredate, roleid) FROM stdin;
    public               riki    false    246   .�       �          0    40967    finalproduct_ 
   TABLE DATA           v   COPY public.finalproduct_ (quntityofbottle, batchnumber_, winetype_, bottlingdate_, numbottls, productid) FROM stdin;
    public               riki    false    220   ��       �          0    41052    grape_varieties 
   TABLE DATA           3   COPY public.grape_varieties (id, name) FROM stdin;
    public               riki    false    228   ��       �          0    40970    grapes 
   TABLE DATA           @   COPY public.grapes (grapeid, variety, harvestdate_) FROM stdin;
    public               riki    false    221   3�       �          0    40973 
   materials_ 
   TABLE DATA           Y   COPY public.materials_ (materialid_, name_, supplierid_, quantityavailable_) FROM stdin;
    public               riki    false    222   ��       �          0    65941    orderitems_local 
   TABLE DATA           W   COPY public.orderitems_local (orderid, productid, quantity, supplierprice) FROM stdin;
    public               riki    false    242   ��                 0    74072    ordermaterials 
   TABLE DATA           V   COPY public.ordermaterials (orderid, materialid, quantity, supplierprice) FROM stdin;
    public               riki    false    247   :�       �          0    65936    orders_local 
   TABLE DATA           T   COPY public.orders_local (orderid, orderdate, paymentterms, supplierid) FROM stdin;
    public               riki    false    241   ��       �          0    40976    process_equipment 
   TABLE DATA           E   COPY public.process_equipment (equipmentid_, processid_) FROM stdin;
    public               riki    false    223   -�       �          0    40979    process_materials 
   TABLE DATA           Q   COPY public.process_materials (usageamount, processid_, materialid_) FROM stdin;
    public               riki    false    224   �       �          0    40982    processcontainers 
   TABLE DATA           E   COPY public.processcontainers (containerid_, processid_) FROM stdin;
    public               riki    false    225   5�       �          0    65931    product_local 
   TABLE DATA           j   COPY public.product_local (productid, productname, price, brand, stockquantity, last_updated) FROM stdin;
    public               riki    false    240   w      �          0    40985    productionequipment_ 
   TABLE DATA           L   COPY public.productionequipment_ (equipmentid_, type_, status_) FROM stdin;
    public               riki    false    226   �       �          0    40988    productionprocess_ 
   TABLE DATA           �   COPY public.productionprocess_ (processid_, type_, startdate_, enddate_, seqnumber, grapeid, employeeid, batchnumber_) FROM stdin;
    public               riki    false    227   �!      �          0    65944    purchase_local 
   TABLE DATA           ]   COPY public.purchase_local (purchaseid, purchasedate, paymentmethod, employeeid) FROM stdin;
    public               riki    false    243   a1                 0    65949    purchaseitems_local 
   TABLE DATA           N   COPY public.purchaseitems_local (purchaseid, productid, quantity) FROM stdin;
    public               riki    false    244   �9      �          0    65916 
   role_local 
   TABLE DATA           B   COPY public.role_local (roleid, rolename, hourlywage) FROM stdin;
    public               riki    false    237   p      �          0    65926    supplier_local 
   TABLE DATA           I   COPY public.supplier_local (supplierid, suppliername, phone) FROM stdin;
    public               riki    false    239   �p                 0    0    employee_merge_employeeid_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.employee_merge_employeeid_seq', 888, true);
          public               riki    false    245                       0    0    employee_merge_employeeid_seq1    SEQUENCE SET     M   SELECT pg_catalog.setval('public.employee_merge_employeeid_seq1', 55, true);
          public               riki    false    250                       0    0    finalproduct__batchnumber__seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.finalproduct__batchnumber__seq', 891, true);
          public               riki    false    251                       0    0 !   productionprocess__processid__seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.productionprocess__processid__seq', 9008, true);
          public               riki    false    252                       2606    40992    containers_ containers__pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.containers_
    ADD CONSTRAINT containers__pkey PRIMARY KEY (containerid_);
 F   ALTER TABLE ONLY public.containers_ DROP CONSTRAINT containers__pkey;
       public                 riki    false    218            5           2606    65925 "   employee_local employee_local_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.employee_local
    ADD CONSTRAINT employee_local_pkey PRIMARY KEY (employeeid);
 L   ALTER TABLE ONLY public.employee_local DROP CONSTRAINT employee_local_pkey;
       public                 riki    false    238            ?           2606    66023 "   employee_merge employee_merge_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.employee_merge
    ADD CONSTRAINT employee_merge_pkey PRIMARY KEY (employeeid);
 L   ALTER TABLE ONLY public.employee_merge DROP CONSTRAINT employee_merge_pkey;
       public                 riki    false    246                       2606    40994    employee employee_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employeeid);
 @   ALTER TABLE ONLY public.employee DROP CONSTRAINT employee_pkey;
       public                 riki    false    219                       2606    40996     finalproduct_ finalproduct__pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.finalproduct_
    ADD CONSTRAINT finalproduct__pkey PRIMARY KEY (batchnumber_);
 J   ALTER TABLE ONLY public.finalproduct_ DROP CONSTRAINT finalproduct__pkey;
       public                 riki    false    220            !           2606    74056 +   finalproduct_ finalproduct_productid_unique 
   CONSTRAINT     k   ALTER TABLE ONLY public.finalproduct_
    ADD CONSTRAINT finalproduct_productid_unique UNIQUE (productid);
 U   ALTER TABLE ONLY public.finalproduct_ DROP CONSTRAINT finalproduct_productid_unique;
       public                 riki    false    220            1           2606    41058 $   grape_varieties grape_varieties_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.grape_varieties
    ADD CONSTRAINT grape_varieties_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.grape_varieties DROP CONSTRAINT grape_varieties_pkey;
       public                 riki    false    228            #           2606    40998    grapes grapes_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.grapes
    ADD CONSTRAINT grapes_pkey PRIMARY KEY (grapeid);
 <   ALTER TABLE ONLY public.grapes DROP CONSTRAINT grapes_pkey;
       public                 riki    false    221            %           2606    41000    materials_ materials__pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.materials_
    ADD CONSTRAINT materials__pkey PRIMARY KEY (materialid_);
 D   ALTER TABLE ONLY public.materials_ DROP CONSTRAINT materials__pkey;
       public                 riki    false    222            A           2606    74076 "   ordermaterials ordermaterials_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.ordermaterials
    ADD CONSTRAINT ordermaterials_pkey PRIMARY KEY (orderid, materialid);
 L   ALTER TABLE ONLY public.ordermaterials DROP CONSTRAINT ordermaterials_pkey;
       public                 riki    false    247    247            ;           2606    65940    orders_local orders_local_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.orders_local
    ADD CONSTRAINT orders_local_pkey PRIMARY KEY (orderid);
 H   ALTER TABLE ONLY public.orders_local DROP CONSTRAINT orders_local_pkey;
       public                 riki    false    241            '           2606    41002 (   process_equipment process_equipment_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.process_equipment
    ADD CONSTRAINT process_equipment_pkey PRIMARY KEY (equipmentid_, processid_);
 R   ALTER TABLE ONLY public.process_equipment DROP CONSTRAINT process_equipment_pkey;
       public                 riki    false    223    223            )           2606    41004 (   process_materials process_materials_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.process_materials
    ADD CONSTRAINT process_materials_pkey PRIMARY KEY (processid_, materialid_);
 R   ALTER TABLE ONLY public.process_materials DROP CONSTRAINT process_materials_pkey;
       public                 riki    false    224    224            +           2606    41006 (   processcontainers processcontainers_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.processcontainers
    ADD CONSTRAINT processcontainers_pkey PRIMARY KEY (containerid_, processid_);
 R   ALTER TABLE ONLY public.processcontainers DROP CONSTRAINT processcontainers_pkey;
       public                 riki    false    225    225            9           2606    65935     product_local product_local_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.product_local
    ADD CONSTRAINT product_local_pkey PRIMARY KEY (productid);
 J   ALTER TABLE ONLY public.product_local DROP CONSTRAINT product_local_pkey;
       public                 riki    false    240            -           2606    41008 .   productionequipment_ productionequipment__pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.productionequipment_
    ADD CONSTRAINT productionequipment__pkey PRIMARY KEY (equipmentid_);
 X   ALTER TABLE ONLY public.productionequipment_ DROP CONSTRAINT productionequipment__pkey;
       public                 riki    false    226            /           2606    41010 *   productionprocess_ productionprocess__pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__pkey PRIMARY KEY (processid_);
 T   ALTER TABLE ONLY public.productionprocess_ DROP CONSTRAINT productionprocess__pkey;
       public                 riki    false    227            =           2606    65948 "   purchase_local purchase_local_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.purchase_local
    ADD CONSTRAINT purchase_local_pkey PRIMARY KEY (purchaseid);
 L   ALTER TABLE ONLY public.purchase_local DROP CONSTRAINT purchase_local_pkey;
       public                 riki    false    243            3           2606    65920    role_local role_local_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.role_local
    ADD CONSTRAINT role_local_pkey PRIMARY KEY (roleid);
 D   ALTER TABLE ONLY public.role_local DROP CONSTRAINT role_local_pkey;
       public                 riki    false    237            7           2606    65930 "   supplier_local supplier_local_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.supplier_local
    ADD CONSTRAINT supplier_local_pkey PRIMARY KEY (supplierid);
 L   ALTER TABLE ONLY public.supplier_local DROP CONSTRAINT supplier_local_pkey;
       public                 riki    false    239            Y           2620    90431 .   productionprocess_ trg_complete_batch_bottling    TRIGGER     �   CREATE TRIGGER trg_complete_batch_bottling AFTER INSERT ON public.productionprocess_ FOR EACH ROW EXECUTE FUNCTION public.update_bottling_date_if_completed();
 G   DROP TRIGGER trg_complete_batch_bottling ON public.productionprocess_;
       public               riki    false    227    275            Z           2620    90425 %   product_local trg_update_last_updated    TRIGGER     �   CREATE TRIGGER trg_update_last_updated BEFORE UPDATE OF price ON public.product_local FOR EACH ROW EXECUTE FUNCTION public.update_last_updated();
 >   DROP TRIGGER trg_update_last_updated ON public.product_local;
       public               riki    false    240    240    262            X           2620    90427 '   materials_ trg_validate_material_insert    TRIGGER     �   CREATE TRIGGER trg_validate_material_insert BEFORE INSERT ON public.materials_ FOR EACH ROW EXECUTE FUNCTION public.validate_material_quantity();
 @   DROP TRIGGER trg_validate_material_insert ON public.materials_;
       public               riki    false    263    222            U           2606    66024 )   employee_merge employee_merge_roleid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.employee_merge
    ADD CONSTRAINT employee_merge_roleid_fkey FOREIGN KEY (roleid) REFERENCES public.role_local(roleid);
 S   ALTER TABLE ONLY public.employee_merge DROP CONSTRAINT employee_merge_roleid_fkey;
       public               riki    false    237    3379    246            I           2606    41060    productionprocess_ fk_employee    FK CONSTRAINT     �   ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT fk_employee FOREIGN KEY (employeeid) REFERENCES public.employee(employeeid);
 H   ALTER TABLE ONLY public.productionprocess_ DROP CONSTRAINT fk_employee;
       public               riki    false    227    3357    219            M           2606    65952    employee_local fk_employee_role    FK CONSTRAINT     �   ALTER TABLE ONLY public.employee_local
    ADD CONSTRAINT fk_employee_role FOREIGN KEY (roleid) REFERENCES public.role_local(roleid);
 I   ALTER TABLE ONLY public.employee_local DROP CONSTRAINT fk_employee_role;
       public               riki    false    237    238    3379            B           2606    74057 '   finalproduct_ fk_finalproduct_productid    FK CONSTRAINT     �   ALTER TABLE ONLY public.finalproduct_
    ADD CONSTRAINT fk_finalproduct_productid FOREIGN KEY (productid) REFERENCES public.product_local(productid);
 Q   ALTER TABLE ONLY public.finalproduct_ DROP CONSTRAINT fk_finalproduct_productid;
       public               riki    false    3385    240    220            O           2606    65962 $   orderitems_local fk_orderitems_order    FK CONSTRAINT     �   ALTER TABLE ONLY public.orderitems_local
    ADD CONSTRAINT fk_orderitems_order FOREIGN KEY (orderid) REFERENCES public.orders_local(orderid);
 N   ALTER TABLE ONLY public.orderitems_local DROP CONSTRAINT fk_orderitems_order;
       public               riki    false    241    242    3387            P           2606    65967 &   orderitems_local fk_orderitems_product    FK CONSTRAINT     �   ALTER TABLE ONLY public.orderitems_local
    ADD CONSTRAINT fk_orderitems_product FOREIGN KEY (productid) REFERENCES public.product_local(productid);
 P   ALTER TABLE ONLY public.orderitems_local DROP CONSTRAINT fk_orderitems_product;
       public               riki    false    3385    240    242            N           2606    65957    orders_local fk_orders_supplier    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders_local
    ADD CONSTRAINT fk_orders_supplier FOREIGN KEY (supplierid) REFERENCES public.supplier_local(supplierid);
 I   ALTER TABLE ONLY public.orders_local DROP CONSTRAINT fk_orders_supplier;
       public               riki    false    241    3383    239            Q           2606    74036 #   purchase_local fk_purchase_employee    FK CONSTRAINT     �   ALTER TABLE ONLY public.purchase_local
    ADD CONSTRAINT fk_purchase_employee FOREIGN KEY (employeeid) REFERENCES public.employee_local(employeeid);
 M   ALTER TABLE ONLY public.purchase_local DROP CONSTRAINT fk_purchase_employee;
       public               riki    false    243    3381    238            S           2606    65982 ,   purchaseitems_local fk_purchaseitems_product    FK CONSTRAINT     �   ALTER TABLE ONLY public.purchaseitems_local
    ADD CONSTRAINT fk_purchaseitems_product FOREIGN KEY (productid) REFERENCES public.product_local(productid);
 V   ALTER TABLE ONLY public.purchaseitems_local DROP CONSTRAINT fk_purchaseitems_product;
       public               riki    false    3385    244    240            T           2606    65977 -   purchaseitems_local fk_purchaseitems_purchase    FK CONSTRAINT     �   ALTER TABLE ONLY public.purchaseitems_local
    ADD CONSTRAINT fk_purchaseitems_purchase FOREIGN KEY (purchaseid) REFERENCES public.purchase_local(purchaseid);
 W   ALTER TABLE ONLY public.purchaseitems_local DROP CONSTRAINT fk_purchaseitems_purchase;
       public               riki    false    243    3389    244            V           2606    74082 -   ordermaterials ordermaterials_materialid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ordermaterials
    ADD CONSTRAINT ordermaterials_materialid_fkey FOREIGN KEY (materialid) REFERENCES public.materials_(materialid_);
 W   ALTER TABLE ONLY public.ordermaterials DROP CONSTRAINT ordermaterials_materialid_fkey;
       public               riki    false    222    3365    247            W           2606    74077 *   ordermaterials ordermaterials_orderid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ordermaterials
    ADD CONSTRAINT ordermaterials_orderid_fkey FOREIGN KEY (orderid) REFERENCES public.orders_local(orderid);
 T   ALTER TABLE ONLY public.ordermaterials DROP CONSTRAINT ordermaterials_orderid_fkey;
       public               riki    false    241    3387    247            C           2606    41011 5   process_equipment process_equipment_equipmentid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.process_equipment
    ADD CONSTRAINT process_equipment_equipmentid__fkey FOREIGN KEY (equipmentid_) REFERENCES public.productionequipment_(equipmentid_);
 _   ALTER TABLE ONLY public.process_equipment DROP CONSTRAINT process_equipment_equipmentid__fkey;
       public               riki    false    223    3373    226            D           2606    90464 3   process_equipment process_equipment_processid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.process_equipment
    ADD CONSTRAINT process_equipment_processid__fkey FOREIGN KEY (processid_) REFERENCES public.productionprocess_(processid_) ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public.process_equipment DROP CONSTRAINT process_equipment_processid__fkey;
       public               riki    false    227    3375    223            E           2606    41021 4   process_materials process_materials_materialid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.process_materials
    ADD CONSTRAINT process_materials_materialid__fkey FOREIGN KEY (materialid_) REFERENCES public.materials_(materialid_);
 ^   ALTER TABLE ONLY public.process_materials DROP CONSTRAINT process_materials_materialid__fkey;
       public               riki    false    222    3365    224            F           2606    90469 3   process_materials process_materials_processid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.process_materials
    ADD CONSTRAINT process_materials_processid__fkey FOREIGN KEY (processid_) REFERENCES public.productionprocess_(processid_) ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public.process_materials DROP CONSTRAINT process_materials_processid__fkey;
       public               riki    false    224    3375    227            G           2606    41031 5   processcontainers processcontainers_containerid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.processcontainers
    ADD CONSTRAINT processcontainers_containerid__fkey FOREIGN KEY (containerid_) REFERENCES public.containers_(containerid_);
 _   ALTER TABLE ONLY public.processcontainers DROP CONSTRAINT processcontainers_containerid__fkey;
       public               riki    false    3355    218    225            H           2606    90474 3   processcontainers processcontainers_processid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.processcontainers
    ADD CONSTRAINT processcontainers_processid__fkey FOREIGN KEY (processid_) REFERENCES public.productionprocess_(processid_) ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public.processcontainers DROP CONSTRAINT processcontainers_processid__fkey;
       public               riki    false    225    227    3375            J           2606    41041 7   productionprocess_ productionprocess__batchnumber__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__batchnumber__fkey FOREIGN KEY (batchnumber_) REFERENCES public.finalproduct_(batchnumber_);
 a   ALTER TABLE ONLY public.productionprocess_ DROP CONSTRAINT productionprocess__batchnumber__fkey;
       public               riki    false    3359    220    227            K           2606    74050 5   productionprocess_ productionprocess__employeeid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__employeeid_fkey FOREIGN KEY (employeeid) REFERENCES public.employee_merge(employeeid);
 _   ALTER TABLE ONLY public.productionprocess_ DROP CONSTRAINT productionprocess__employeeid_fkey;
       public               riki    false    246    3391    227            L           2606    41046 2   productionprocess_ productionprocess__grapeid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__grapeid_fkey FOREIGN KEY (grapeid) REFERENCES public.grapes(grapeid);
 \   ALTER TABLE ONLY public.productionprocess_ DROP CONSTRAINT productionprocess__grapeid_fkey;
       public               riki    false    3363    221    227            R           2606    74045 -   purchase_local purchase_local_employeeid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.purchase_local
    ADD CONSTRAINT purchase_local_employeeid_fkey FOREIGN KEY (employeeid) REFERENCES public.employee_merge(employeeid);
 W   ALTER TABLE ONLY public.purchase_local DROP CONSTRAINT purchase_local_employeeid_fkey;
       public               riki    false    246    243    3391            �   �
  x�5�I�)D����Iil�R�_G���c* 4�_���#~������'G������Z�]ci߹5�/~'�8��[Y�1���_�s�W�1�_u�����k�1�6��h�bk�1�د��y�G��j�N)���W=G�_�Z�#D��G$��Q�j�~���#�N��->w��ѩ����)�~��ȉ��g$f(�����[��8���J��n��ʑ�bJ�D�+���9c�Hݼ����Jh���8���ӣ���Q�Bm��Nu�b�Q2�om���ѓ+�9:�0ŧ�>��[ޓ�Gc�}��v����o4J��/טc}|��G�@��b�,�r��%;����g-���g���_0vĠs�6F�m3����ƪ5v���c��/v{s���[2��Z���-~�bItp��1�������#+r�O6T0�Ct��q�������*��s�R��Ë=Jf��]��=�|x�G��q'H���Kߍ��=�>�^�����{~2���zh��M�x�|9��*�Y[�� �wq�����%�Ml'�%
��0�i�� 9~#$e�9�O�)\*Zl �˦���6�|��߰�>)#p�
�ra�isX M�ˌ6�8��)?��V�H��X���M
.����&����$�b�����a��2V��8z}pQ��'� �.r�S��`
�Y9E�2f�@+�Ⱦ���k��.~��d�)��1QS���߸����W�l���٤�D�.���/_����Y�8Y"^oJ��|<���#�_��. �R\j�9S�S��(A�0��\�)�}.�Ͱ�X}#c��e寭�-,��dl�f�x{�|�m'bao㉵���XGZ{[GvB���ُ���Ci�(�M�����s�c:�)��K=R�:i��%���Z���y}D\LEř��O�#(�=.^2�ui�OEd��BWY8P�j)��s�V�������,Y�m�R���(����xW\� ^N#ĕ�T�&��n"c-��-ه��G1q�VąN���:KF`�.(�\�7\dK� �JN
��8;����'8���㊿ �֑�p���iDh[��tI�A�$tsB5��BY�Z� [���������dz�"�S����ĥR�#�R���'}����zQD����n�/���N�����\YJ��1E�YQƈ^f�_PI,�8H�G��זoA��5��d�e�k�J{HgW�̳Fa:�l�E���&x��mn8<��~����A�U���ZAg�HT�ݶ�'��&no�t�d��YС\*�l��;$���y=:�s�Y�.��5���Q�q_�{�r�6�UQDa,���S��J �5<Ty�Z�*Cܴ�l��z问z!uhP�|U���Z(ui�p�|;�.?�q�ʤ�;��4)�?�)~m�pt�j5?�j���:�L�Տ��^'..����Q�I�J�t�N��*.Éjg((D�4����|��a�4&�*^*ĪE�PRMc��Sf{xf��jz�X�!#b�4ȁ{>/�$R��f�(�t>���t{��I)��L���>�$��Y��Dh�?%1u�{d���{؍�^��׌��}�	Io_duʣ��'(N��p�D%7�r�(c\p���:�i��-w�P@|��ry�&��hg�gE���UO���jIաp�`����+�Y�@�š�=m���\ly2a�Y\�|�@ s����$�q��S��΄(�in���Q�g�)54N�P�;���u����\���P���(B�!s�X��]P c�V�Y��ӊ49v�uܱ�eJ�� (��+��"~4��+�,�mƒ4�[�I�:�!]Ï�y����$%ەK�2����[����@k2��Y\�Q�\��v}d���8A�m��"��c��I��g��4����8)��65���d������rİ@�pYR�	� DQ^A�D�Q%��*�H��[P��7�b)��2��=����t���-EC�Z�$$��U�T2�)l+� 𱴌}(d�H��\�A8_:W�P墡���ECr�"r�5Ô�-j�[�2j`��V���:�O�U��h\��تJ�"�F�EjJ�t|������={��
�r��DU�wr��5�]jMKc�G�y�I�t���m/W2��j9�R�.�;Hq��2�2�kIm�G�͘��N�Y(2I'o.^�\���Qr+���%�pO��u�*�'Ǔf��=1�Q��y�:�FW�P��U5�s3����ɪ����RO�6����<��y�}�8�Y�H�x�������F�".�8�]��N�����ʙ��%��P/S�y�k�ժ�G���D�S���:e*���c��LPHX��ӍtnC]��=���?<���ϋμn��h#���j!p�q�<�t�;�	�o�A�%#��~�'�f��j�����Ŀ�<���ɽ�Je'��_�>U�<����<�˦��6��a�5
R�������i�ETi��cv��u��M�R��,�F�R_���~q��E�F����9� `������[@��WcC��B�5�1ՙ����onז�Z~Qk����By��V���,�C����y\��XnUۥ�>���u���Y�B�o���RiR��C�6�!��I ��o4ٸ�1�Q~��K9}��$�s6�UC�O��s��ݪ��ò���A~P�k�hO�k��Ɓ��uD��r��t��1�'�|����F��ZQ~Q��䃽.��3��(d�`      �   $  x�EQ�N�0=�|��lG�B*�P.���E#������o�����Ն�~��Q&��#t����/:6CdOm��I'�s�Χ�Na.��e�.i��Z�[����-�l�4BØ��B�E&a�h�;�%6#���.͹ο��v���Z�M�8�0��v!�5)YZ�<�e�]BB��4��R��4Iޖ�"��֮�
N�i�:dUg���%�i���ODp�4�E����͕@�
¢Wk�X�(�٢x�y�no�{"��w�������P�>�����Z0<V���'~`��/�b      �   �   x�U���0DϻU�Pֱ�����A�A����ƹ`$,���3A7�,�O����W3/�=q+�H��6��P�P|�6G82R}�͊�Z�#�Ъ�a�������jԘ�1�����>���O�.���F�L���M�YP;֞o²�k�@��YU�!փ�         �  x��S�j�@<w�~�A=O�CX�sH.�\+� �!���E���^;����C�;����)�MQե���~�%��"�V�re9r�x.�?�:����_S���'�.r)�mO[��@ރ��U$<�FR ���0o�4�B�k�X����[$�W2��x��pH�n#��!�K�̠>�؟��
6i8�&㳖��EG�yɭK����B��T���pY=U�h��jg�sW����pQ��	��x����#��!�c�)�85�#r1E@��c$�Im�N�T���U�0���rp�p��p>��:T���z��8h��Uo.���4M�pR�Z$��w(���f��{�<�N���~#�.�I{M���� ��C:RƌM�=�=je��zt��-�Rz5��7/b��4.�B���u~��>)V��Y�����|��;A�O�=D-      �      x�u\K�f7n^E6P�^�cȠ�F�L{R�0��.��I/#H&YA��턤�H5�A�Wߕ.E���G���?�ϯ���ʗ0���?���)�������~]ۗ8>2?�>1|��o�|�3=�/!��c���w��O���?����_���;��~=��
a=Փ�#P?����~�������_��_��ɃW�o��v�.}I������_�㏿|]���_Њ�||~���?��'Y;�l�ߧl揁��޷qRц��h�\�yc<4|Mp~^?��ӏ�������n͐7��§V�4��@;��Z>�H�Qh�R��F�M�~ރ�?������Ah=��k���Qjo{���U�=��^/������s��9�A����t�	铢�0�;�"�������vt���^Pⵉ�79˯�<����-�Õ��Ϗ���vq�\8�pP�) U���F�i?�g8����~9|I�� ��Ȅ���C4��J���!�P�)'�r9�|�T>��1��ǋ��F��k8�B�1�T]���n�/g���I0�nE
7��k�?]���.Tw�"M�X�ZK��3)$ek��6��'��ƓT�f�_�?����cХm���ڱ����v�?����:Ѩ�
W��|�0�qC��}�"^�(w6���^Ѣبe��P�;5��N��,����΀�	 �i��X�5ZC��*����NVSy�T)�h1������ۣ>q{�����v��8d�0л �Ck�+��ڪ�sz�c�S��!�#���9&�)	���݂ h�����F�Q�����Au>��p��ύ���UA"��w��m�m�|8�cA��`8$Q0��>�$r�$��癣gn�F��ur^gz��&��O'`���S����{?j|h�JH������VYҎ:�#��S�J	8M^Ӹ���e��!�k�&#nX�ߋQ6*���F��p�	��� �����ab%�����l�פ��o�tr+��\�����g��g�2� 1ڌ��i
���P�����<�2�S���q��1L�i�)\��e��Ġ�w�s%J�ΐ�V�ANf��xp?��Bф^f�Q�<AP-�A�����	tî�0��@����C�v ��ʥ4 %��S�S,��9�N�`��O��	БkۧkD|EbDS24�Yg��Pl}�����<�,]��(�����C��a������3���q�*�S��`+��X�Qle=���8�G�K*\
�iyK��ovV ��3w�`Y��,ͳ+r�Y�b��\j��ewK�� 4��t�U��q�����.u#DCx�ӏ��� �"��	U� k(&��Ai�,ΡJ����H�{�	�gȳ�A��Rs�l�NI�[Ѣ�WٯjOdb%K�ڹ��CV��WK��3	�-s�q+��\4ɻ�Ce�jpId�'�m,����/�,�}���Vq?��ۢ�F�#���%8枣\�_khtJ!��
'�1�;�}�p,?ײ�vTƤ�[q�KP���9��y��'�\���Q��<�]�͌4S�u8�f���"+���(r%�n��-��=a36�|��ٔT@��vWv(�턨pG�������'��q�Qf�R�և	u�jT���Pܱ �~�]��Ȯ�wpˎw�<Ųc��,"�I��Z�RT�j�:�s��i�Úm�/̺E��.�Q�I���t�VK�R�X�uN����k�/@p�B*�`�h!r�%�8�1��t5�r4���f���?y?C�90e����T�l��h��n���b*�Ä�,C����M�V��}m7R�E*��ξ��<s+�����B�RF	͂.�n��� )�b�(��v7_R�Ȑo�� Ub�6H��h��v�\_a�x�k(x������/&S�Q�Ú�&�L��uq�숼F>����n
X�.�|S����&0$��zĀ�=/�?7��@�J*ёW-�y��q������<Q��X�!O�to����s�O�>A��k�և���U�XrG�y�
���ץ6CǆG���JQ�@��h��XȂ�������5�5�>"
��}�`_#h�1�#�hE}&�#W%���Q��cA�T�+'U�2UWS���{p@1H����>��49����x�_��c)�7����d*�פ�6�r	��l�.!�Zg���%b��c\�y��b\��[�7K�g�z�֚�K�.����l$u.�}�T�����'Y��[P����>��{��;���V6����c�>̢݇�$�NE�ںl'��#2��L#Z�<3����]Sxgج�$u��Uq�5)K_�\���IJ#�~6B�xJ�4��A��y,�=AP����0&�҅j	��t]k���F9$��o)QDv�4q�,ΝC��Q`ik
�s�NrR���k=I�� mq�M�S����z ���+��,�\.�J��9_�4��\�m̈�;���_ۭFZE1�+����r�Ra���s�g�Yw�I�a�:Kw��1C�΂�8U��a
�p��4E+���Uq�d�EAt'fv��3Q����8��'��~d�(ל-���0�9K�I���[�ß�����λY�!������������ݹ��F9Y���QrΏҔ�m9Q��H\��-x"f��#��e�6�]6�`�߲����'�9����{��j-�ť�զE��r5G�r�Nj���oDZ���W�AM_\�����ɸ1��zT�Έ�m&L-��IZ��K�6%�ͥF�Mf܏�^����XtpT>�h%tt��
��:���k����E?w����ʣ�Q��� �|_sU0"�+{�p��gSę�Z�I\�q6U�e�&IXk����(��X�	�q(��UCY19�Gos����f�#��;�Q���R�S�V$ӱ��7�j���g�]�'y�8I{
�D
7�0O#��V����äGT�T�de�x��\(����v{`��u���rs]���O�����C����-������ú�8k�r�4K��6e�83�>���C�;� auhF2U�q�uH���m���\�7)B�pi<rg������^�L���'��ϝDRT�cd��d(]UȆȧY���r�W���c�]d�p�[���xq)��o�j��]��ei��0�?��K1�%�n�6쯉j�>wW%�G�l��4[L�<.~?H�������2�T�n;���%6�]����e'ꬦ��AA�=~�Z(E�*�b�Ev�������BI�`˪�"���ǑLPmDY*�:ӤVa;���M��K�*�)mMF<"2i�@�$��q�_(�K�֋��;8�.�'�y�%�2����E�Ot�9CZTA�����D�D\g�}�;�Qe�z{��U����r�X̾���r�i��0QD�$�
zI��TJX,�N�6�[iՕ�R�]p��j�)�Z\-Ĉ��݅R��h������Y��s4~��v�,ڢ�z��J��T̀�t>yK��5��C��Syɗ�Ex�B�U��-�Q�}�%�^ V�A�UW��Ya��g4�H�.I\{�����j�C&�z�BV��7j4�UL��缌�L�ϓ~n�t��B����満�C����@\�f�F���k`Xo�<��ж��"�6�fǾ^�?�^�^s�P��y�4�I���i������`MT�H�hV���K�c�ZҔJ}�v	X'MXU�k.�� ��ކi�Q���!���>K5O�t#�<(�5Cy0/���_���R��xɲD�V:X̚�܋���ט4>/x5�˅^zw�Cv�ˊ�����a�� �2���t�H���y[A�������
�F�X����2\U�*�$��2�/v���a	��أ��Q��-q)���nRQ7����EM�CJd�޺�k���&��;C|�gV�n���_S<�e�W! ������mM�)~j�n��K�w�~_>*g	�^5c���F��YRV9��������(I��).P�y�O��:�J���U�bu,D� �  j���@���c��#�:���ۓ�?YkM��0���� ��u����c�����4U:B��C�D��~�è���*��PBI���Y���k����(%uY�CI�9���0tc9�|��A' β�ْ �u���}\�'bW���U��ƨ��ʨ3�&B\ȏ�%M4.��n���Un�����n�����h��Yp���K\l�,Wo�5�F�Dԃ�/���@��KHm*Њ���f���f�u�ʵ���]� ���o�"�ZŤ�bP���Q�Y�� �h����v;ʼ��6�)0+�r(7~���)\���=*+�eJ��P����`5�:]�^V������M�������'�`	\`�&�m�4+j��&�X������g�	�
�`jwgT��Nq<��m���%l��$����p�����v�D`�e�V���9N�c������խ'�_�\���V#WN=�B��흸@���(����r6��Y��k�<��T˩t�j�		m�9�W�& �`�'˷d�]�X�M@w�ֶ+O��	�C���ݵiĪu�������Ы%v�o[��ݛ�Q�p�Ѩ�`�[��IR��q���
�s���y;�����$2���Nm�D<�L�	
�Tn�f��;�3�DՁ�������hP�4��w+��Q%���/���_ix!��/��kI^G�D�ث��&�Q���e�}Ȗ���f$�w��2��5�P�Q���k���bQ�E���	{_in��'nҟ�aOFN['G��/W��� �]�n�Jz��/�X=v��.�щ.�n��#���`a�AB�>��EH�q�"��9���Z�V0''�d��(spܫ[���ѩ�\צ��K�[lsJ^�6�M?�Rʎ7���rw�(L��z<��8v���\1���2}�Tf	��u�"�5y��:2���[,��PR�31�,�����:y�[��]�����N�K�\�TA5|v�	��Ed!��ʠ�;vE)	��\�����i2�"(����X)�#��(�%:��"!�RgT#$�,3W�7�l��S%���9Ii%y�6J3G z���݄�$��\a�s���!i�|�N"|w\����R��I�#��{�mD�pt�ԟe����}���8�%      �   �   x��K
�0 ���)z���٪�"v'n�u��8���^��Y��4$�50����8O2��._�bo���$���}�s�ҺSI)� �$�tA
����YZ+�!�����n��7-Z}��I�w�x� �ч)�      �   q   x�M��C1�l/D�`���:"+~Q����KD�и�B��Ln��F��oƕ����K�,,�ȹ-�J�^_bKñe:�O�e�20��ώ�5�du�����_�X���(�"�      �   �   x�EO1n1��W��eɖ��v��%�%q� �pwm��W�RZH�~ƴ�p�,��a���a[�Ӵ��n��\�K�J��|��W�޺d�i�F�y+XU2�\�=g\��kl�n!�f��J�Ӳ��_����Y��w*8/�=�������O�B�y:�9�j%dE+4��?F��<��X��K��f��F���=��qTo��Q���e|�>�S�A�vx���e���ȕI�      �   	  x�]Y[�$�
��Y�Ȁ�{��_�%���-e0��*��>?�����������g �Sӟ����"t�	�W��r�궟����X-�CI-�v~���Ԅ�.y��E�'Qw4�k�T�ۘ�r���-��T�W��4~�z(Ǌ6qn͕:64H��.i{c�U�._�"رѴ�Ф�3Тn�H\�?�/T?NJm0��m��WJW'�#�����%�{��J*�c��T��E���e�\y&O����i��;���8wi���dm�. �t�I	���i8�JA`����{;.�ۗ؅M�\����oB��T7��Vm�}_Wr��6at_4�z 6��%'TuΕ����qY5�ck	�m��~:���{͓7�vT>�_qB�V;�q�7s�a+)�ܹ�,iF'�C�K�������rO�.�Y	�p�y��f9I=���D��ō��pu�;�Zr]�h���aa�-����M��&��Oa/��/�xq�R����u�Cj�5�����!F�%�?��ņ�h��#�NV��ϕg\�qV�T���RU�`�\��u:I!� WP"R�j���r.�x����7���uh�Ǒt4l6�{����:1v?�������I�_g� ��G��l3�v�EA�1*�M! O>ʤ+#�~&Խ��$1.��̛OJ�v�R��a�+K������D�b )5m�}�AQɍ�����
�|��v��K�`*��'p/�'\�s<߲�y�B${����8�P�2ӆ��)���Iҕ
���0�y{^��j��@cF�:H�McE��2���p���=3�ý6�wKhH��R%
��ȭ�����~��/�7���R��g0�yߋ%4���\��J`��]�_8FSF�q��q����@ƻ��6v�:, >[��eG�*sÅ�Y�t�~e#_�i=-��Y}�͐�f�H'�W}G~js.a���n��(#[�x�!�F�����EEmpm�H�R�	_ �7OiF��xPW1������3�C��͏~������'Z�Y����F#c��$�`{�t29�,�d�~��3��qI�6�3�h�S��YB�[��u^���N��}�/�j�m���p��-�9^���~%p���2�w9�3/�ɇQ'��ߧ(��׫��J�6;��������Hx�.r��6���Y�{�V7{��P�H%net���-��4�S��N�0�H$�Z����"�2z�Y�",�k�d3�%k�^�:#����D�=��x�pc��3�5�3b@E 4�|�&���������6h��K؈�he����o:�GE-U��1m��f|��^Q�f��D�6�oG�݋�D"l�GKh�EJq���I1`qA���J������Jt�z���
�ꪭ���+�0ڋ����:7���F���t�G6�n����xln����g�"h�:c&�;�8Q�g&Cu�7z�j~'(�.\����)���Y�2��aYY���8_U�.��Ɍz��9��@F>�9,hs���]��H�hDjx��l��N˞A�ɾI���g֑e~eE?��H,_�6ksv�뉟Z�6�xa(����^5M�|��WP��RSaa'�GZf��d�:�����|��"���İ�T~p�m�����ʩ��^-�y����W�cj�w��cJO�3qqGkOQz�֔K�e��g�W�o)a�>�z��Pe%R�5�w��Yh;=~'�3^���Y��p*a4/,'�L�k�����Kv�9��)�4c��) ��,�ۊa�J(��p��y�Hc|HN�V����s�,�rT�A����n���[i����BcC\�rG�=:Y�`�2MiB�}�E��'�v�P[a�Ky�A������xM��W�����b��e��1�����|���	5&HY����x�y+[,>�&D�d�_�O��F]!E��:����a9/Y46,D
�S����y
�}�f�.�.�C��9D[U���y��qӪPy~���� �?���D�o�X��)��xT�t�9tÝ�Pʦ�gT0�Ș�gه�M�Ѐ��K������]�qV�R��u���܁��ۑ������h��Sb��r���q.�;�tS�p�n1H�QU����Y"�&�<���.R�*FAȶ�����y����B�zmxc��$��`\�>G4և��{���F�ì���{1`�P��eX>K@�^��%�o@5y5��M�j'�O힊`�|�c�'@�Ŧ��`5�&wL�2/���W��I"�����8\��f,=�t����?��S���h̴JMr��V�MŏHwk�3�xek{���'\>��DR�lI|^���42ڿ�����>P��rb�{�2ଋW�S���,?�����+�_;����X���_G��G<9�t��)�G�փ��"�F�/M��?��H�������?x�         8   x�Ǳ 0���H����(�d7B¡UD֜� 2�f��S�a��U=V��$
�      �   �  x�}TKN�0\wN�=���.�$>6��r��q
HUylOfB�S��ҟ�]���e��o�N\�������ť����X���3�1jK�q��χEP�~�b��k։�a��H�����W�Crm_���NKe/��
��7��6�4�$�Cּ%�8e˼��b 9�zq^�qo;�Di�d��j��:֮�A&��W0%��m3���\��!�LFqP��
؂VGL�a�b���kxڲ�^�Eh$uq��dRB���xZ�L2_�D�hN�@$&nu0�t.Z���|��#��=�N�F`&�Jx�$ҳ�P�l�Ay'��C#h�	��ާ:<A55,PK��P�5�:�5tM}G}t�i]��(,���
�ǎ��q��S`��!1��9�fMi���	I�7.      �   �
  x�=�ە�6C�=��XԻ��_G�o~vvƲD� ��So��yz�������T���������zf������u�i��5-�z�������z�:����C��e�I�b��=�l��yvӢ������kC+�̚�Vڱ��mѣ��K'�����������[�9��.nRZ)��Q:Fo��9������/�z\[��̉ŉk����=�>��yZ�[|��>��o��׵�w|��'�mk��o���>m��e�v�u�[�9K?ɞvd�Ξe����e��ry�>z���r�Ó���f���Cw�*]Q��2����}�K�o6�g*t}�kK�r��G�]��k�nmkK��Ql�U>]&**�ap�����қ].z|;�Y���wq��`8h��>yKpx�޴����w��-{�~j�o���󴋌yE�;�����bW�ks�����U�mq�WE�YwZt�Z~j������?�su��N�5kKP�}�_��#9�;AS0ߕ��n���m��es7މж5M��x�i)}�1�x�hӒ����n$�����~�W�:g����+.^��;�t`�P��MȄ�5c�d��@!����#NY,G�0�f�Ƭ��,OV*RF˲'k�۹�i�����"?�ܚ5��~�Ƈ���Q���$����J?�z�]�p�\��9��t��_�6L�,;ޢD�����Ib����N�=���K��}x_��%W�I���oRAV�%8(;BeX�G��.������7_G����T�F�����@���\4H�	� zu��u���p�����26p�mAX5��&b��Rg�b' �Z�3_xR�9?_�8��9������'%c�C�ˊ����x��c��Z�Mw2Yw���ʏ�)/��%�Lꯏ����n��wrQk�7a�Cu2/9uW��F�ܳ\�J�U�t����4�Z��)N��wy����7��dpL��G$�6�c��&����D��7�k��Kp57�&ם�M�����s��)kw�[*�=7I�&6��� ��y@����ԬnJ��?�pd9D�B@n�
NUP:H4�T���_eItpmN1��nL��T06�F'��d\F���]|�lQV�=���BS�TS'E �/�1�Ǹ(����d�L�*|腁9J�K8�`w�?X�
��yԔo2۾�Q,x1�] �HRt�m��3�m��L5���G�23;+��;z�� 4˫K2P�H܍<2q��g��� ��0�E�o+��"�X�|�V�sc_�4�롐*:�M��xS���O�ל+}!\V]h5aQ�۴s�q�N1/3��8Gb����Ш}c��D1�V�\�]���5>�(j��9r����@ˌ4G��o�ISYZ�X�J:�h)G�)n�[��T��J.�h�K�Q|+ԤQs]2V*�$nm�<�p6�"�`.�k�.duB�2ۿE򣋭�H7�#{��23��
6`6���SA�a6�$�������
�ȵ^h�*hcB�$��AVl��]D�}�*�"��/�p����E��S[�+��JdKw2@Wd�|�n�F�x����0ڞ����88�"o.�_S���?pm��ܻ>f��ĸ�h�m#}�f�G��߶"@�����Sj�>	���ul����-��lDX�y5>tV��%G�k$&另�؉���7��N~���n�f3����A�/m������C��$�HKb�MI�;�˱�o��(�^HI��re(4����>���nB���se.��|�^�
���?�.<
 Y`�`�J�}i����PY��C���.?��.pu���t�+�7��v�I��ol��x�j VH�I�D�[F���N5�5~�p�d݋�,/������Y��q���F�m��q�^��7��+����"��N����F�J��ύ����]�)�'�
�`�O���<{0G�	ɚ�g%��;6���o��:�y�l�
p-i�"��͠�ڙ�𛤜$�o>�2t�>+�C��?����;�����:<0����#j]_���4I�)�Q7��-Eu ���i���=��䡛m$�����K}��fv=�5�X@�������Sm�z�V�3��i+��'�Ý�
`���?��M�F��Pۭ�O�<~���'7^������
`YJ17��~����ۆ�J+wS�������6��II���a���������G�;�hQ�IK�loG�n&�\���y��J��Ճ�ׁO��7øۃQ�x�#)!��a�^�=3��At#�-���ErT�4�4}YK�B2f������sf�~h)�+S"��2Ȱ0��ά
��k6:Fz��ZfB-P�8�sǘw����ڜ���a��m!�T(�O�#�i��_��glp�U�n�I6��E�!����6�������7-E=���QSn�
���_�Uft���>g�.rl�Lg�S!q �&�RfiG?숪�t�q��Os�Ep�)/Jh�
���nqjXK{�,��8���{��GN��d��тip���H��p�:�����B�QO��Ђ��s2���bGVҧ"h;Y����Cߣ���)ԛ�}�>L"p#䬉7'}���D����|H� '�2�ŠZ~�fn��̬��݌(�7Bm/Z��)"ҽ��e�˷�N�O�P�`zC��w���d��y�n���53,�͊pF$hz<
��
?-�GMcm�������s2�{��]�EpQ^^�T �|��J7���~��������d      �      x�=�K�7C�����w/��:�+�Ψ_W�I�����l{~��w[�/v|������^��E�f�����Q:z�"�8G�b|5R���Ř�����u��M}rt�.NM���ۼ*ݘ��d\��W�K����E)�F���~��;M'C7�B��u�����ѣ��'��=��P����������+����.j�~�8�G�����)���<:GY9��+}���&���y��r��%�&`c�y�+!�S�GQ��m�/��)jQ|�*)Z�	$*�Vwm�Y�uJ���i���d�<�Z�U��9��u�:�U�BR��7�5n��j�U�|]�7
����  `�~����H��zbj�gM��t��`(������K��-Z���M���ɧ!F�j�>K�j ��NMݾ
��J+`�߁�s?�M��;�
&�:��".
0�PVG1J�]��r4QH�D�K}	��q"��`�Z�<�4Q0��jPmp�5"��/*���w�HM�� �ЩM��K���VY�Í�ۍT�I��o�n�G�QO�)�Nۢ-�'����f�R�fm�@?�
W�!�h�M�X�?��%H<�d��J�Ia�f��~��pu�:�)]���ؿ �DG�QI�nQ�,�/P���z<HZ�����,���BW��$03jA�,�G�E"�J&�3
sP�0��k�K<�~r�ڟ+*&I/ڹ����S�[O7a�
�H�.w۝Z���t�,�JY������|��V�a	u<"��rH��|�!TV�)�l�gG�z�a�y��Uni�`frZh����"P�OI�Ec�Zzw�L�����&eF����tڮJ���8�e=n�����TB͘|}(�̌�>ߔXd�JV�kk0�����Fǰ�ɲ�{��2��p�m���k�����ܑ@����S�'��U8��^C��߬�Q��5/ǿ"Mc1��(���5��J�4ԝ���w`���ێq�1-�鴕�t!�$�{���{\�x��`b2Ld�? ���g)�,�s��5�nZ�^�J�;�AT���"��%�gb_�y��e��7Hs���k�3)Bas{��ٲ��?fv��m�V鶕i��SGKO�z8Mo��'�BW�-6�i
>�^':�zH��
�~����#��OG��:�L<��,��T�<گ��R{p�5%x�MP��c4i*���j�_LH� �A�u�y��g�H�u�#˾V�FD��Kp�'�p���� ��J���mJ G� 9Ꮋ�!�>dF�uM�M��:���cW�ԃ�oO8�[Lo"��|����m�]�|��E^�S5-�?��1r�-+�֧�n����ph[�v/�5귆��zx�){��Bz��� !�c��\?zuNCR��$����o�gzY����0#g��x3�f���<��&�c$��嵝�b���������Lu
L.��39���b�G���^��������@��'X �&|}_�?�r�^�'��+*=1���e�:�]�[c?�����ހ�8�!�i�H��VuX�
�Q��5�����}=@��h�����XQ��[�����J6��i��`Z      �   2  x�=�[�$9C�Ë�c�{/��u��Ț���c����_�j��=[����|�����{����m��e�m�������W�|�s�q�y������ze�9���nꝣ���Ȗs��>�b�]_�]'��Z���d{��[.��:�/��6C')�>�ﻷ����S���C��o�lk�H2��o
6��+O*��E���P4��n�z$��Ѕ����z4��0tQ.������מ~�:o����C_�r(�����oߧ�����n{J���]oX˙}7�����[J���lT����k�>��:a]�����7�7�2�-u�CnOS4z���8+�7۽�Qe{�����r�B{�}�P�S/�#LE���[��_���U�ws?�5�XާrGꜱ\�����+AR&�q;�TwZ��{��ۺ���*S^e%�j�H�uzd ]���~v�Է����dN �c�����o�+��[u�nG_��rH��~T�6X�<�Va��twR)�do;d=�g;�{:)	@�j",��S����Kl]� T��T�Y�a����p���>e_�C?�qJ�O��Gy]��{�%I"t9>U3�@ tSA� <%^_��B�9*�>e���/�����8u�n��(;ǯвߧڍ!PR��\5z���
�r�Ĝ.ˠ����X
���!��C)D�� `EO�����^Bw�0��M�����l��U$����y��@��}e�O1�]ӷ�2:Q(�O�K���:��ul�pZ���R'.��fty�����l��ᕰ�j�pD����MI�)��?��4�JX��o�=.?�t���1��b��c�vo��ØN�V_�k���W�:�诡!���W���!ww�uu�E�2�j�
u�w���{��7��KWV�L�\������ԏ�:�6�#�7\�Tt�_
��"B� ��������x��("gK�3l��N�~���]�D9��}�a�vw��<D�#��0
��9_����,�Vu]�5��)����.-:,ơƢ5a��LF0����t	�#�L��]��%L]�7��R�w�L	�����@��B�Hj�i�|Q}��q T�*wi�^���;�S¥��/_Vz$?j�8z1���8Rש�j��>����۱p��� ���� �JU�[*g+��!��l��A���l��Ȭ��!(m��*�$E�.k2�+ Ol��sS�R��:�=�V���������%�"%T�#j��4
&j�Y=M���&.����8v$�J�;@�t=@\�:���}"T��^7ל�׷9|�`��R����4��VIӖ���N��?�@��.T����ɆP��(.��ߥ
��������C◙=Q�(]+��q�uaK���\�V@��#��,�=�?H9���n�����%u��5��)/U��E�g����@��=E�f(���Aή�y�вm���84�h�\tx,E�)�K��<P@^G���ՅCƃQ�[o�i	�)D�\/Ua�X��n�=��1�eNQ���}-�ͺ��H+T�,������	�*��~��q|-�S����+K�Tߢ3`$�FѭzP���pt��&E��sдG,DL��|3�)o�9c��iA:(A�&@�mgT}=����s�����~Kr��YQ94�<�(���a�չR�L[#��+]6�4�`;@,����S���	�0�n��
y� �����,J��Y����6�:��ߢ����`�����âmq�,7�}��Y�h�0�n�p��$d����ī�p;V��:(y���C�e��k�����H<WCMݤcTc�]#�G�c�Y&��?�&-�ģ�x�ό���Qq~���Μ<|��Y�E�L<���NQ��P-�p骽<���ۮX�
e��$�
W)(�r�(�XEg������r ���¤������<ad���F�2��.�I�b�l��=vI�x� 6�����n�����n2�E����2�5t*UFS�HUC��cA�d��a'*��'D�_�������[��s{�����:ˌ�<�����oD)�,��i	�i�ޭ�;�WG�Ql���s�*
�bZ�F-�ư��(c��u!��^�n��� �g&PX����=X+Ͽ0������3k��T^��Q	`VL��ݳ�X���#�q@���Z[����^������=�z�+���Ň���z����j)�:�=�Վ��g�.{�`Ӌ`��?���6/4s;u�:�4o�/��q��^f�TI�u�D	/&��e��5V����Jw=S
�2�)����6���u*d�!a�V��7*l=#3���Hʢ�Ǘ�:F��;�]�ugG��2v̔p��;g��O�
�Y�/��h�l�v-� H��?e<Q��1G�9��)�����1
	(�D��L-,	ǌ�fm�����zwB�3�t�;�P��ox�Ȩ� -�ۙ�Q;|%�.ل�F�E��S������)�-gd��X�--5X�Y�gc�_�ѥ]ςg{�?���ʮ���6�y�B� *�P�G �Tx��"X����%Ҳ����1�i=�<:_sΆͦ�����%vf��������G��yX'fF\H��o�sI^N�i�����v?݆��f>���l Ac�"bΣ����X'�*~d��ؽݴJh�j�&f�SϨ�ͱ�:@����%�13%;��[QU�}c�gl�Ӌ%�T>	�ͣ�f�!1M��m�g�Q[do�+ b�iqL�0ȋ�&����z%��j���L1�4+���S�~^����4;]����Ú�-��j����y�e6� >/m���v$e���� K/ř�Q7�z��fQ��O�0������e0�2vx|{�q���eB@k�a͍x�����U:SY��t�̾$Qڟ�)&���g�Sl�k&��� o-�L�ǋZ���L2�C�_K�^3��� V�Z`B&ۢ����{�I�e��,̺����ՕѯU[̟����F9�����C fBa������w��w��W{�rr6��:�j�b/�܇9��n(wd3Ʊ-�Ī}N܍��cK�G_������>=;t��Ƹ��q���������F���͘]w�9��]�R��m��4�-CY���`�y�0Y�tFc�68�M$�\�6��?p��ӷ3��������ߕ� �,��h���s��������Z�ת/�K��d��j��lC^)J�U�Ss��n��K���Ň5X��(��q��Vf�S�xjO࿊e���۵N�&cU�[R��;��[�x$��X-�����e�Ṙ�A�d)�����5p�7��+�����0%!u��ہQKL�q������w��      �      x��\�nIr]����Y�E�2s���z`���hƂ�@����_�)�h�ղx�o�w���3"N���h��&��2#�qNDT��t:?}?]��.N?Nw���z��<����N_&�������N�Nק��դ���>���ܔ��O_��O��Ӳ�K�ޝnN��ۛ��E����e:=�nO�'3C�Cz�3��y�����E�x���(�>��ޞ�5�O���,&>�s�Y�̷�Ǵ�c����ʃ����I)E��)�O?�D����Q/ң��̻V�GWI�aR��*�I[��l7���z�-��D�2-���#)=�]��_����Β��_&�Y�6��"-�6a�3���&-���$۰�#5ݝ.&�w���݁�&����^X �J���/z����dD���w�3YO����u�%�c=O��G)��"���nO�Mz���<Lڲ����mR���iS$�r>�>mU�#���j6���ȘB�t��Ҏ6s�^{s�3]MV��#sR��E���Ŏ�,J��7���E%&�=�N�t�^v/{T�[�kԭj��4��#��C�@�e;#9�Qv9�\�bM5��^�ߤ�ŭ')�XP�ˉ���ߧK��CF�/0�2���o]^������Dݴ�$ �g��^���Y30߯I�O��,�_�X��M��_��7�T�ǿ�Kg�Ҳw�8�r���t�����F?�6�ܮg��S�!$E����%	�:m�b�vi��oX�Z�#���=��)&��@��o�^�Wl>�=Y[<���bx%:�9[W���=�6������8��@��*+�q���7i�Q�=o������^���&�[k��|ζ�}O9�m�;	%���筪_|����m	7OIB^�AJ]�rR;B�M"H�u��=x��M�E�7iS,��]�s�s��K�G-�b�D���dK�ge�D"����8v�O��%����$u����(!���\�)1��;f+�$.��O���,���3�B��ғ���lX�#]�v��ۤ�[�Vo���&�<��yK"7�u�zc#�M�;�HF�~�|�)Oqh��&/�2�d�EI�lt�O�N K�ݥG�>aD �F~ЅI4��� �[%MInan�&|��ރ�r���Q".��J����K����g��!���*�*i��s�3IJ���i7��DG�������$�{΋z2�d,9u^p~8$ Zs����n�z9�<��"P��Ě�|�6�����_�񶣚Xc���3���H8��j_��D�O	�qȥP~��WM�A6jGN��{z�5�i��ѭ��h ��D?���2��ͅ!�k^&��P��p]�'_O�)� M�:F�]
�m��t	'Ǣgv	��X��:�@�#���E�n�&?�yr���Flf)�����FDJ�
����#;���?V���	�#��)o��dc���9�=ncV��Z�PQf�<%�x���>$��^��g�G����O��)]�VֻW�w:0
�#�ЂK�E��tW�A+��D�	f����� 񈅗6!De��AdBC�
3zh�^��E���Uᩬ�=i&�!Offn�(��E<�n���C�������5���AYDs��:��
�\Ē���������ӻ���V	�Օr e�"6���&�@4����ل>2�C�e���Thrwa��T���ΐ2���6}W����r�Và�	i݈��G����(/�@�������v����8���5㓔��E4��#��i�4DQB¥]��
��g��+���Q��z^%Fѷ}�Uþ�.�E���%�M�[tcH�i��Ak(�U;���d����͆6���v�*�c�ANH.�hԀG������-/�BDP�+��:,HZS����X}�FV�뗹�4S��6���n&�5aR鼧O�N��4�d�e�v8��!�j��y�(D�m�U��u��f1�e)'#���,lv!�F�P�WS�1�B�x۲�\a���k�WAErP\Q�A?JX��d�>u<�YJ���N�:k�����WDK�BH��`��l���nЗ �
v?��)�|�A4;4"��� �}�7S�!:(<����o7���R�E�{�X��jV�u� �(eZ^�k��!3*\/�r��j�ChТ�=!�>�rZ�U`D�NR�8��k]{-�^���%)�ʭK���kՁ[B�,�Ʀ�5�[��B�<i�Gr{��@��Z��lNػ"vG��C-��|ddsQ��cH����4n����	������Vlz1&�!��n��f��R{s-��E�ķ�;�߳��� `
��;� !Qe^4�R@h1�R�|x';��U��6��ܭ�g��ؚQ�"n {��D#��x�����J7`v�9�Џ@A��e�s�<�0z�2�� j�ɷޏsל.���\�2���^`������+�A��p�8Z��q��n�����غV*3�{M�˚zEwq��P�L�8���*��T��#,SL&Ɉ�B��=�xו��\<�ʙ%U4�R��Q�9(zhZ�0,
%I4�}�����[W��j�	�I�UMQL�7ܨ� YFk����������^0:XZHk�C)
��n�E���vPB��t�΂�5@|�b��lW2�}#�ڈ��J�D8��L!j��`�M��lj!�6*t[o�FL܉�H�M�Y�m��]���X�-�h�w�7�è�C�Z�������������n��Pa`/r��zXt�[Ε]���<���_tUk��oU�m�����0�GZ�/e+��ڱ��?��n;����ޢ�`�����h͐1�:��`#bG�<���)�!��HMJ;7����6�$���u���f:��A�]2z��@X���D�2Vqd��etx�26���hmQ����Kn_BFO��\��_2_���|�����,�T���E��W�a�Φ3�,q'��\�B7	a���vC�YNI��y�:�IW�BX� ���fU	D�)J�y;�5$��rz.�u- _%?/Xy�U�̊���*���̀��}�lƮ���8��j3�Y*o�a�m�7�A�I��$�P��
�˲f Yt_�Cb��K����Ƞ�@}À�� �!��j�-����~�)\j)8E�UOǒvKưDKW��YG�jP>]1Oi��hv2K�ޕr��v��k��$��u+���K��Y *�:�<�7a@&t��<�{�B�%�9(M�|��Qzy#-kP�Wfn�h��l�LΦ#�C�t�x�jK�����8�J|o��Q!�zZ�ѳR�����Å�7g\¥�vN�F��	-�!�l�t1P3�=�n8���ר2�,�f��"�"_�1���Q�U�ف�)��C�n֚W���hm�oBtdZ����v4� �[#�g���M�@[���:����H��`Z�#$0���-j3���	��.�Șð�j�
�`��ܞt`0r�6iWQUT���3�b�O��J��J��]����ɇ�Ƣ�8C��k�*�_i[�����"G�=U�\[��9]58D�����6�m���7~Ի�v�N;D�N���"n���Aܯ���*��n!̀�(j!U�T�ֆZ��Z�t1V�ͮM��=�j[������ʜ0��DH�>�s՚Ҁ������l����6r����:))�6N�!�����;���Ȥ̂wV$X;W��0|�e���,g�f��H�/.tD��X����YH��ϛE��svX�6c`\��H��,�q�2.pTx�YڠQ8��V6b?f�n�`�<6�uH�9�ė�����1��C�{m�]e0c��eh����\E�|m׵Ql�`KfM<rM醁��nPv�P�<��]�c�o=z�I���Dr/�l}���ؘ>(�����Z#�����}���ѵ���+�)7A����q��BBдi]�>����pƆΞ9���"G�n����
��?�OC���,�J�&�X��X$�<���`�QgV=}EZ���>kf�u�7m��r�!٠�����ƃ#�) �)�7��ܱ�,��
���Q^���r+�j����� �  ���k��z�oo����}��6�����7�߿�ƫ���������;9Rl~�k;����������
n��ͻ_޾G�,�_���׷������w� �>���Ĵ���7���Ͽ�;�Ts���_���� F7ې���c�=���!��S>x���9����Z�u:����w ���\��u*.Y���r(ϝ���xXL*@��,��8��׸��gL���!�S��J�m��n�l`�͝\ʲ1�Fd�J����ҏM�>��e��Vs�fo����:�dLS�U��%WI�:�5�>�h����0���R(�Di9,��)�bl���6����&Ȅ��C����GJtQ���V��@��M(z@Br����#]G��n�}Q�P�5߂YlD�֍�� �;����VZ�ǩ����_�g����꿸�MeѸ5L^v}�2E�1����:ȇ��Z^��)b�w��'�����:���U]]
6Q'��k�v�T�&h���O{�Y��@�:���1^\_.����uH� 9a�Va��G�u^�㽙^;��r8��{�`��:faaU�C^65���]��G����/��4����o�Y)�ڶτy��f�fQtXN�4�������(�dlm�ͧ��Ǌ���ܔ[�	W���PplJF��M�^.�����%H��r��L�i�C�%av#v|�`m
���lf�w��f|��i���)ļ��WftR�r�rJF(�-lJ�lF���&�hE����M����*`��c> v[�[�Y����r�n��A���n�~�[�,y\ZĖy��.)V�#�����������yј�c���@>R��9�)A��ݩ&4�k�}|���6�e����t$4�/�E}�*)j������L�Y{Bl�� >�ou�SqFP�+*3@&�G'g$�}��ځ �(�s���N�"�'˛�&G�g�ϽQzZ�z�q���O�tԃ��(��[\7�(�|"d���
��N,~��ëW��6�      �   �   x�mRM��0<o~E~�tw�yU����KЀEm%V���I���0;3�	�nh��Nk��L����h�6��j���U?�;���iU��{�W�"b	K3�\��*��5l��l�n`��S3؛����E�z��F�cS'�"a�11�Xsv���m��=JYڲ_� DB~G�\�Xz�B�T�M�Z����3i|F����X���V�]m��k*����,�����Λ����3���PJ����N      �   �  x�}�i��8�[w�	q��K�	��� ����cz���(.�A�O�Խ�?{����q���S�O���>���,�t�����f�Tw��|z4����/���t{�5���d�<�$���Is�k�z�矲��9�?{Y�sj��9��|m6N����G����0��Ӫ<���)o���U��v�����̫�����Ϲ�{�W�z�i�X�A�UYK,��J��I=_��쯻���k���,k{1��s\��|}3�G|n'tZbe߬��Wu@������O�Ag��Ô?ͧ��|��*Kվi�~z��~�6@������]��S�l�Z������P�1)��>�/��B_�ڏ�3���}k����?gƏ��q��qz&V�Is�כw?�3ߏ�]4�})�r��84iV��J1+h���#K��V�E����ϝ*�(��X+;iP"�k���|#@����j��E˩%��ϱOȱ[�c�����S~�p����%�S���0?rǖ�w���	�>���a�Z�]B�l����&����1�q�м���~��L�IZly��:�ȼW�KW�ws(�6X��uT��iR��x���
0��B�u8u��T���۸�@��u�7h��P�on��-۱�yX#��7��A����W�mw�8���{�����X�yCø�8�OZ�[�A�}o�i5��E}�!~��")��ȗ^�
]r0����gP�Ŝ�03��m��bN�T �{
E��r��˜��������w�����O1N�C����N}u��=������Bq����l���h�,��2�?��p����}���8�Q���U~��Aֹ]��d�뺫=��o��_�Y���/Vkļ��8P��z�(���l�-q���ɚH��ywg����9�ܖ�~�5��o�-�������$7D�N�E5OLX�y���_a=��I��
�q�h�qh�h�e�gX4����j��p���"�����F����z�8�� �Uڨ�sX��`)�c+��?c�L�Ql�����AIj(�!X$����8D�*0�y��>/8���̫��e'v^,��ž'Ɔ��͂��e2���8��җ�X���8�	�d�X��=� V_�c�:��O2�"~�	9%_b��?(�p�����!1��80-��S� U�Ӳn%
���C���d�*!#⮠(�_1c�x�$������4J��c=�ج31���불���~�f�X�~���/B.	=�^;8~���s���g4#�(�]/ި#k��hK��2�Z��fl�#�B�Qđ}YC�����8���x@�nJ���X�^�G�R(��+�	��GKl|�Y-�G�c�_�hP�~gL���o%�d�v�2��㔝����[;�
��*��[B�Fb����U��-�R۲ĻD�����g�5Z��ܣ--���aܣq�����+�����Sz[�)�.HGb'͍Wze��&w��t�0BI�Jp/X���k��P�h5�����-��4����{�F�����q�?b>�����q�_��J�iM�AY��3*��K���\{u�j���]�[²�=1��H��}�]���+���|)���Ҋm���נ�Wz�Dπ8��k��c:������JgPs,���]�end� Jʫ���Bk���(��(�	_�s&9/��
ꁄ�@�^v�=�ԍI�K*��M0V� ��k/��D����iF��߿�ǉ���b=")w�x1���!�G�5�.�0v��H����!P��Oh�c;��FÙN�f`�эs���W}ٷ��k?��vױ�s�|����)6+&g"���ő�r���� &%O��v-Ǥ�I��`�|��X8�?"hs�b�dm�H>�-��6h�e�+8NX�n�10�}je�dE�����ԡ��8@���!s���8@�4ڄi�K��I	�]�� �q�S�It�Z�7�՝렕G������2�<G��$�����#1ɒ�&D=(I��J����8M��-�V���w_b@��quH�$�0Gb\�
�V%1�5�A�<ʳH�̉����W�8�oYmOLJD��O�X{ٶp��Q�c�e�Θ�Ll�ض�qT`Ǐm�����V$�Ku��� ��VѬwL�EU�6�r� �Ѳ�z&Ŋ�m}�{W�Q����XI�hq�6�����bRCAIϗ�Hl�o�ag	u��L��I�WZ1-(������� ��6�Y�&a�慧���#H��!1	J���+z���|Y�V���������]�I��U�=���|��_`o���~��q���;\�լA��wh��I�S��}4"A�H�D�Q�c��Wj�x�,-"2P��0A�ĤI ����}r��I�૷���>�Ws��ѤQ���lp���V��%
�vJ[R/��9�<[br��憢*�u`R/��p�K���^�\)�%��+-��u�=�w:z���W �~�G��D�x����q��S���-�:DHڣl��c�h��j�s�C����DRj�w�9�#G�.x���Af�%���q�P�h�^�)NI���K%��h�����p������@ui&&-⯖��9(qK�K֌NTX�6�՘�1�1q�K�P�ĤQ,!H�+�$[���"�ח��f˚�E�&0ɖ��U�{4ɖ���#PL��Ҭ�Z$l�t�i	q-�#,`�2���S�epL��k�J
+���Oeo�|ܱxȩ��)�t+���iչ�[&���F���&N���n�䊥����A�G ;yF3()qb'{^�qJ:T�<BC-�3�7�rz��	w��8��� ��ZƤNI�t��~>�4Ͼ�.AL��S���|_Zj�;&&�J��HPR6���(�;����d�������vB��/�	�E������E;GH�H�˦u7<X� �Qzܥ��I��:�uSm��Ԃ�{_��r��-P!��J�O_�T��w� 0�h��������ѣ�t�)�0ͣ��iY"����%�iY�qJ�!r=5Z��F� w��K�H�(� W��0�50�!�u��f��~���=�	(���m�܍�rr��F�������9U厜zԷ@q�����]���B�����fb�B���P	�3N��f���7�?���i�/�@~��9�#l�L���+)�q�y~���5ʊU{(� T>j斋��@��Rj(��$!��s���0�:Dמ�|gr����ǓD_��?  �e!��Q#�v�6V[�z�!Gbr���q����1m!�5�vc`�m�����b�XZ�z�
7���8-V-FO/).������t����:G4/�t��U��UR�@���9c��)C`���"�f�$)��g42��L�_�.�z�)��	�o�MKJ� ��)�ף̅IJ�=�z5�(�6�]�I$M�F��A���;%��(���,\�H��&��lXK�q5Py�ts�O��dX�:+{b�Eʢ�� �H�\�IÌ�"o 5���D_����v�t�Z����"���yr��W6�q����P��[.�����2�3���4ʨ�?���Dw��U�9��6���/0��0�C���~c�7>��J(�锴���zЀ�iL���ѵ���g������F�`�0���5�$X7w�Y^�IaTJ�5�����;&=2����9��*�fR�"�1!x<c�� �E�'��0w�֢���l���9��0O��W��{��p�d��6L�~�̣q�s���yP�����:���y�L�����!��[�M.T�a`@q�Lw�r�C]�SW�����~��#o[=��g'����`j�X2�M�ԅ���x����c�F��N��bMK3K��W�հ�Cߕ�X?��/s�3���=V�z���:�>07y�z񠻒������5�ț�Z�7���sW���v���|�={�F��������l��4�      �     x�u�=������^�� D�܋ev�%vj�h�c��]�k�a2�8$��_<������������?��q����y��b�����?���eG����k?�?��/o_������|��s�?��j��̯W��~=���������sO�mǽ�Ui��fy�����g=�^J]C�ꇥ�m��S�\������W���3E0.�a+՜��\K�Bw�]�q��yϽ#R�KEp��S�!pK6�l���@�4���aS�{imls��z�&W�?"]]��^Jxl#�@���D�]S�!��D��!4h�Xi�P�϶=�� �@b��Ɏ�L;�?����_���ugFA������5;"�5{jnE���ϣgdR��4/��}#½k���N����=���%"p��L�,�s��Evx�Υ�|D.�1�4�RUG�!} ��Ǖw�3r��5���ۥ_@`)"��yi&�-�u�?�V����٥9�~v%t��?�.��?]p"��R"@L��s��.��l"Z3���y���i4�O�ߏ	�_j���7��~Wa�o^�|��_�y+�y!��k�����< �r��L��Ċ��ֶF�˷��L?+��
Z�4k�FgMA��.QW��j �i�d;'�����W��«�v�	]�.1����'�P{���*a�\�7�����X4�^s��sc����>1
Fd�?ϲ��9ձ� s�E��ʓ��o�."P#�,�"�6�d �E+=��d��R�Ůkx���s���
Yt�;�ʲtQۆg_VK��g�9���7=���MN��?@ ��D�:�g���6���_�;����)��߻���(����蜽��4�]48(�Vt�J�d��ծ�Q�ț���l�,�b?]���^lA$4�`���n�/���\ʦ�<�Iɵ�v����*�^��Z@*3���Q������s�xe��^[�i6�W�̗�4Vn��w�O��*~����s^�IT��s���ij��jzᔶ0s�|`�7�������౴�x}s���s��,6!�U_��P��}����-�]�t�(�"�NkuFpg�Z�4��7m;�������|������?r�f&����8ֳ�����o�s3Kj�v���g�]�7}�m��*cb�L�5���n��ȉ�dTL0��1�srg|��N]�ܙ}���Sy�OwGOVg��� ����<3���9���<t4��g�%gz�ܣ����@�}���m��P��#��3f�J܂c:�(���n��-[�~�n�i�s.���r	������w�Ppz�&{D��p�֫�
/�,�.Ԍ�+��]���� �O�Y�0��=��N/X�]n��:��3���c�xK��R�x�]?��/{]����L�̆�/}�{]��70���'����x�'=��C0ֵ�z��	?1�,��Z[����{Թ�����aj�<����ܫރ�}��k:�cn�w��i��|Go�s�~��fZ�Ǿ΍�>k�5��3�<ݗr
=1�ܴ2>��u�{���\S{�g-�ҚWS9ȳ~u�^�/�h��WY>��sr�^�������o��5��|�F������n�<Sc�Y�g>��4o����wK�Ygdᨧ��E���:�x� �4p� �,�� �4������+tm�ybw�4�R�6�?k�^|�3����w�A�#� ������G��g����G,���y^������/&䕍眛�W^���^����ԞSb���o���o]k��z ���"���}�d����ec����q�������
W���6<?�@@�C�n�?�,9����ۖ�O�+��"F|D'�+13���� �,�|���(Rd ��pH�<*0�d�>��w���\�ȫr��������η�Q|{��(ϳ1��~?��]���:���@d��M�6�;�'��{�Uߜ:�}�',3� �TNx���6�>�H���ΘZ�Хo��!�!�ן7���#��,&�����u�?�Z�׿��)F�             x�E�Y�%��D�#S��a.o��(l�q�G汐D��4BQ���ƿ��߹?����oiǿ��ݟ��_���+��O~.UBm�<nE��W�M�]P�_�?m�[F�[����f�6+�s�*q��M����L�\C���k_NД���T�+�n5���߼������D�����}���ʌ�]�i_�ؚ�*�D�7#�v��\��q�e~�]�r_��n�>޿���Ŭ�V��g[7[U��}���������/Q/A���E��>�o���\�����>�����A��t=���87�������kk�K�����}n��_����Sn�M�G��?��sn�W�Z�Z���Q�C���J[ߧ|������ m��>>1"���˺�l��7y�-Ŝ5��I~e�n�8Q�z1���V�Kj��$ڹ�2�UM��n�\Q* �ޛd���_j���~����H�"ehf�E鉧	�:V��@��|E�g�V�e�X�m� ��I��Ww�}��O2^���u�j�l]��.V	�Cߔ���uL���ͪ�'>�m������tu�S���)m*��{>'n���F�v��j��y��#��3�d|��7�ny��-�V�W�vp�����_�T��ؖ���_����1Vq깒xU�T�ˎ�J��h��߭�m�ǀ�/��-�U�Bm'�*�Q^F��*C���HU@cQ�rx|���Z�}�#�Iû��״_k�`ET���IQ�O�n�l���:��G�սLÏ#�MS<���m4���>�����+�ˀ3ԉ$˧�}��-04#�W��jQK�Řyȩ�Y�]�	z%G��u���a*2w����5��כD�錯S�2W��$$�_��2���+����e��D9���r���A�UnǙ�o%�l#pG�Kq����0C]p�Ko�	���K�yܕ�{��h�g}�x�f��M�q #�[c���S�y�j�A��.����_����hәh��l�x����������"R�F��@�Ο_����������46Ips��Qծ��?T�j� ��$���r�9�k�w��|ɮ��E��k�R�R�.�R�;�:�1GENˢrz綌���N�-S�p�����Z0��-[���c\P���(eh�]��!��Nݬ�T�&,��MZ��&��x������|Gr�X�V�He��Vg:y)ɰ<��q�8͒�Z���v3�X������~ͳꈝ�t��jp4ŋP��H��=-��~`}���d�Rt��8Sq�ߣ_��. mbAA��;�<�	t���E��BP��P#��3E�Հ���OxG	:�����澼C�XL�EP��� ����M��4��_x�ɛW�=E�sfwƓ�x�p�L��R�zx7��j&m+�	�_��F.�T�%�I�=�I/ܨ��G9Vx��u��~�UC�dF3�eF�<�^
�9nW�:�gY:����%��K����t��c��Z䦿�[o��cy�#=M���V��.�~�����Q����n�= ,(�ڲҤ
V�#��w�SI���5�b]]N�:��LVI]]CU�,AMa��(�N^�FR�6���I�54(*�3� �v�w:Ic���I����\t+1ܜ@�I�k����d�*�����,�$�>��I(�I���"X*/��L�������5���b¿��g�d_�ڰ+-X���JR&�Ez+�������9ZjT� �/^�t#��0D||Ԍe�ϙ�/�4ąX����6�@��sCT�Y�hToF�e�?fe��$~��Z��JK*�r9�T'+��*���LQ�P��Z�`���=":��RLO�&(�4��eH�P�b���wi�('R�ȮMt4��lXMP�����b��|�b�DGZ#K�6S�r֯^����"���;�f�7��N��} ��**T�*��%e����+`��]��ihcť^ĲQ)��3r�K�k/A]VM���V	�=��F�@��X$��	��L��i^l(��.�$c��i�^>�J��(���~��K�-д.аX]û�#DTj���&�ψ��e��,�v�VJ�a�����O{R>������t:�EB��]�-~�`[@���T�f�%�5�,��| �+�,��_ډR3���t���6�-�B�q��5m�d����4��
uEva�<���h�+a�0�%�N ����
�N��(S�/�K�CC�����?�ߌ���<�^3�ܢ�j�6�YH/V��πY_�]K���U��_�_�l�Ug�&m����r��\󷞉_���, V�*���'�WR�6��]���l������P�F�*Zʴuz9��|5[ߒe������&��X��AhD�Y��W'�|P��Cs�l�Ld�D�:{�9�T�Ac*A�`�=���Zq�K�
λ� �p���:f�y��a%��_�`N4?�LP�x���v�V��gNcA>1�uZ�����7@�S�fZ����[���7mɔ��Ċ~�o�+�`IC��}/���E��ki�,��a����A3p�8UmI��Q���´�
R��^�52�2�����gY�j��D���D>����V2��l
6v��O'-u�I�H��!H��΋3�j���*���Vf�[b͆� �p�Ec�հ�"��FX|�0���-��ivr�v,�j�L�WV�h���ؐA������ijm"1|���%^g���t�ӿ����M)E�V-V#�~��w����);jɭ�`Zg��~�����ȒT-� u$uuQ���{H���#�����9&���:�c������D�+�l5����;YO��d#�"���f��ŭ�B�u��\@[X�{�YZ�T�[�jLmҠ��X;ӗXh��m����`�w��z����Y��0�m��y�[�H)�t�`\P��޾*������]N��>���b�/���f���DW2�òh��2��)�	̤u%+����"m��nl�T�J�QG5�j��e�e�54�[���
0�m�r�Ni�1~ڏ����I�MK��7,,�baBEF��s�(X�$,�Lu��+��aQ[�%$
��8V��Kn���~Aw6�Qp���H�W��1��i����@�y��i �z֒�I��XM�J)�ϙ��	���i����J0����!S,BGc�F	U�����Ƴ�J����׉¸�4�"��ۄ��iP�H��J����U�t��wS*�zY�����ش�4
��i� ����'��i�x���۲Z���H���؀G�n5X�&c�y;9�gF=�Y�`i�=�ӳV��F?a�/��Ǽ(��e����x�ҵ�ƻA[@��%�&xl�p}Gv ���: M�x�p�~#�C�I�wfٯY�a��RDc��xUy���S��r0k(��m��;6E5(�d!��b� &�c��՛H�QD�X�m,Ԁ[��\sҜ�����h���e3�@87I]�)e}�H���uhe[��Ŵ"+Xf��>�98[8�=k��|_�U�l�{�0 �Y��^��ma1�l���
bI��j��-)���W�-�T�f�\�Ͻ�O�Z�����B2i��/��-�'㚥��NriL6FV@��Ӹ��Aگ'Æ=���`#���jF����g�J	��Ǵ踚��K�Q�wi���Q@s-��!D�?�"���6<�K���`38������{O���wB����٫@��x?��L&�e�L��_���ͨk����w:,V����k���������i�<Bk-	��()��y��hsp�+�Y�lP���v�{�Y,#;~�j2�gŷ��L���"�y�6�C� ��4;}��1���6������ܖ_��^�y�,xX��!�£�������Bm�І]xp��ɯ0Y!�A�xȈM/���� m�N���"@±ʎ5Ꙙ�aK1b���>X/����Q��8�+�'S_�Z�JJ�Y J0k��aF�O�1
�����}��ͯ��
��F�Sfn�Z���)	�.�0�9�W���    �C����VJ�$��]�~���i
o%Yi;"��(�a�jokJMDڝ�-�`���K
��5����LMbC%0ʻ����9��V��w��\���W��S6u�=�6�PU;�i�O���0Bm��]R�I���K�ˏ�x	Z�ɤ��������:Y�wL�<�.B��KhÍ��E���"%�K���	7�/[o��P��4*LPm�$R:��=?&3�r�h����:õ�/�c�E}���}5��C=)�c�����r�\��������k��/����V(���tV������7P�%h�#��ki#�ѡi�ؿd�_ �D��N�V�f��a�o�j�P������_~�5���������-���.�d�Z�Y��ػ����cE���e�����y��;�r�Oj�=v�9T#����&ȓ��G11�Z�#I�[|���3�[/�0~r��I�+���Z�h��<[�1����S�p�Ck�h�Ѽ]vR���k���k7�6ѳ�K�f�C���Vyr_i�~)��\��Q��k26�[ж=��k�����y9E�����4EhPy,\�����eQ`��g���;-B5���k��.��pH�؏�a�����J�>�^.e뗺Y)�қQ�hs�i(�Y��R�w3m�E�3 ��2N�;,;���_����q�-��K:~o�1@\=������o8��aO=����V���4�b�fԨ���FH~M�yىg�#y�)���t}�e5��֢�G+���L��##*��
�W�_Q�W��FPfq{���Zs�5�Y�<~#no��:���xrZ��t'�%Hl����t
ЈX�b�Bz�{�v� y�y���g��9�5uju�J���AK���D����7	'�e��q�HO!�?�O7�����E�����+x��n��f�/_�q��W������7	���E�L�p��t�vѿe��R��}h�6����cvu����aZi���i��%.<��r��ퟟ"�xi�i���!�l7ӑ)YU���M;�ئ9�L��j��(���=�w8��>��$��᥌��L7�F	�'h�2u��Q��H��t3��9��eaH�h~'��n��'ɋ��w���q;��%w�E+ͫm|-�2M�N�툉'���ɐt?�I �JT6 ����B��j�5�hzs�7�j^��k���_�4{�z�ʹ���Ԝ2']jF_�lf6���[��B9E�7c�������? F��c?��&FL�3�`�K
���r/I�#Yo�`�Љ&�A�>?�;X�8��c�T��Nm1�n#M55��B�1j����G_�=뱫����HG�=&�*���Z�5v�@�tG�^K푰�:��B�Zz|o]9XCM@���h��Lbn�yT�K��,r
k1&~=YW6'��8U���i���2���.U�(�!�z)�<��xGGE���C*^�h�eOSO�/D��po꠺_��i��^}@���j0�"�'U�l��`���:���8�y���M�d��^���\b�?d�P�~>����j�i�p}(9��T&�ٔ6�sV���L��)���r��G�=aP�K�6�jώ�<4�Z�׋���E�%�(��F ����O�˱���-�I^%�jC�����{r�֝�ۭ)�����S���������`?@�Xo���	����#���R���^W�qJ�����7D$�3�x̹��Y���R�B��l�6�@k��ƀ�^�Β������b���Ɖ"�O���O�&���Jpc#;��О��9��g�����MەG�x�Nh �o��ُ�kN,yŪ�m?TW��lO��)�/k<�����/A�|�j4��/yx��UЏ�h?A�dAl!y̑˟u
|�}�Bh)wl|釳����eڗb���M걼_o���x39d�Ih��+;��l]U��[z�v���C�P��%�c���3�
46��}�e�NB�K&v�.s���PI��o(�L]��!����;M;�|�U�$�(�:9_5��S�w�	�b�kl�� n���%�c���:��L�Z��FW���3����z[Bތ��Lj��ʹ�� �[ᶳ <�#G5���2����x^�m�~���%����^ �����?��Ґbt�k�Gx�̅��j}9�ɵƟ��r��μ�m�XШI;^��39B��C�h�چ��皣���y�c���ז���s��|F��[�bz���aw���m;+��dϤ*�|�c�7��eW{v���@�#k�bz�Z�W=޹oC�z\��Es(�e��H�5Ar&Ep����QK����4�y��'X#nZ�l����s�7�-��*���	Ҩژ �=�����01{ts�_���1�k� m�r�#6����c��c�r����v���u�Z9k�n+C;b��zx��S�Yud�!ż#GD�z�:L*�^ӷ J����R���j��%)�wu�]#r�*q~,%5J�{� ���>����P!u�lNo�A�O�����^��;�J;1�'IlG��m[+;����،o����с8J7���AC#�(�m?Z�B�ʒC����G��c������F�@��{��1�'d���=^9@���"�|S�=�M+�G����]�sd���+���G�w/�?6������-��<X��mF�\����RN��-e/��B����Y�,��z{�H�Gs��y�ose�~��5�B��7q�(�#�؎X"�N{~� B�ޝЬm�	��!#6��`k�f���;4s<){������VK�
���I#N���s�/�om��P4�,P��,b��3��.�����+4��Ѝ�h��r@�W��(� �f�f�MG���g漵����?����o��Bf4W�E|y��\h�^!+!2y�A���E�nf2���Q�˿�gNPj�1�El���KP�s�qS�ݦ�G�܅�O�.���:���'�Z�?�(YkIV�)Dʖ��%����3�����8�G��eg��K^�;d#M/���n[��0�ce�Ƣv�[~q�m��������@K��0�;woP�EV���uw����[
��BG_hxpb9�w=����N�R��o����=H���f�*0���GOZ��.+v<Ӛ+t<2Y��C�����p�G�ӹ ;L q#�?)�տ�Xk8Y~Ԥb��f{	���%w�	5M)���K�y�[�-A+5�A�"z�
{vx/��,�����u��[�k\7�i�P�;16X!�,�&��(�[!�%�6~Y��rp.g���7h�=u��x�ٞm�c�kP>��D��<��U�Q��,B.h��R�B���p�����c.X�l3����� �T�Av��쓿AX��uk���3T������b9(�Q���~�=0�ǳ�KhlA�WDZá]lP��8�A�RqNX.⨝7˳`1?��0ҦjOv��� ;�&�S��{H�&\�C˱�J��YLS�Z2��@С��߫������`$/E:O�>2�_9�*��~ٞ�D�+�w�/R��oɽn������X��)VO&�]�%�}֖�Orpt&�/t��O�N?U�q0�l6]��l(�K[��1	�k������{��y�+�>T��$W����=�?:uq ��!sZ:���s��8��e�,`�t�5t<�d�r
�z:�lDPf}�6�����p���u6q�̠P�ÜM{�@���4%m�G�ُ���n%��M�l�	%j��}�ϵh��H��<R���$!먀u�d��&ڝ�~)�Yi�� |�%���Y(�r[����X[���e����+_^��Q'_
��`m�p��F�i�Y4�OVuB�
 f&;��g��8�Zu�0��:V�jXwY�0_V��#B~�%M^�<�k��X����ȣ[�&� ��8N�4�_F�<�[O��BĬ)���������x��,	�]Iq"�8�f)����Z1`���p��9�U\������ g��v�FUA�D+��gk�,�����2w�? ��:�M�c�?�Ă6���5 �^�ފ��B�I�~i����x��+    �����_�h�/ta�1͡�p���I���v��@Ѷ*�+q�=��:y�xZ��y����:JU�v�����N����7RRO���s#B���*f�&~�
�%����<��ѽ�0r�0ڐ&iR쐚�Nsp�¢�ð�E���H󇬢�������O�&�L*vb��Z�4X��H�X+i@)����i1h��g�6�@��)J���fu|̪	:����0>�D�+Nȁ��?�ݖȯ�C?�]"����7$�	����I�B5��NЊ��ۦٹ��l+�����_E���.��P<��S�W��P�s�J)0֮e�d��_�H��<���z��A"6��#�����az9�b�y):���z��g{*���K[�d<�O�)����z$��p���)��X�٪!�E.T����C)þ�zF�K��	5�
m���F�6���B��9���늛�aK['Á��z��Pp �/Aʴr�4�iYg�f���Oޠ-����Mh�{I����H���/�����+t"��R`=Ь��C ��ȉ� ' ����?@���>H �¤?�#PgV�X�_CA%����.b�^v�m����(��HԈ�)�.&��� ㌄0�r,���pW��ou���Тr5G�@^���'aA_"���wWc#c�!��\�����$+l�g��5��.l'��B�R�f�a��wǒ�h��t[u���%�^���vH���a�jֱu֟�%(
�iZ!r���;�!�@��A���b���5��ѥ�s���!ݠ�5��C�Oj�G�.�FX~!���s}�����fNN��R'٩n�M�1�^�p��[�P��9�(dŹ�
J���^���8���!�����E��e������j5&�����~�8,d��xu��K�ɶ?�[u�N �p�V�J0X�I�$�ܗD��i���s^��s1��p'a�HИMȤEm5W1���2Z�E���n��GK 6�p��.ӈ�Z�硓��
��'�l����D�k!�.���o"ū��KԿ��pS��@
�y ��S�=Γ�Ah8Я�x�b$/�~�����6}���"�bcb���8~4�������V^|]%;l �Y���\�G��2C��ٰa՗I��f��� p
��!+��_���	��H�]��!�O��	�z��H}���Y6���a��\	�|�x������T$�Œ"壐j�ۜNhD�����
������G��5�Y	�<)��
q��؆x�V���2Β�K��03a� Y���ۦJ�z|�5�?��9닀?��`�� � ��ޗh��o�To,�î��&0�\@��PL��z����l� � �;ph�D@?`�;a�ƶ,�����#��R�7k�C����B���{"Y0P�QU��z9K�.�#G���p��x��~Ǩ��D+����u��ze�:�!����lK��{$[���$G{!!��i��A�ڴ7}>gY�[9@����i�qDR���_�ġ�2>hBx8\4g�3��ŕW�f�b�k�/-�X�V'�A��>f�$��j���R
ͅ�||�Ur��˄�W�Lc{�h�M�)Jr� .1�����宜���һV������U��b��)����j_J`_;����A��c-4#O|O�m�tf{ݙ��8*h�����f���p�\�#�Ch��+^��~βK�0����ɸ';[n�x
��t��_؎�઴��K������w<�)�<�Y��X�l�o��dwNaE�I�<˵�O�@���+�5�(kn͋���B��\��F��Ư�1���h�51�
����}����m��O @�\~~,���&�x�=~��Wd�˻���s�I}���7?O����/xe�}r�Kk(�����3�3� ���]L��lO1<g�8�{�nSd�!��C6��߮��<�TM�#��oBg"����W&~qY��/q���G
{�bsؾ|�X�F>9^RVe�~@�G�x�լ9�;\�wW�-�M�W$��F5d
�1�lO~F�G+�z#�N����$66Jṗ���o>����WK)�]2��&U�o|[����Pb�؎�L�A��.����P��ےۄЭ&/�����b��F�
 ��o�f�|}�g����z����������3�ԑ
��v-�m˒Hi��I���x��(&�}�x<�6P����rΠ��m|��q�j�y�?_#��B�B�3��*�{�q�d�D��=�A��9�(���Z���K��zn �(�p���O+�ñ��u�ة��>��l�F��|Ƨ��b8�"N��e�������C�?�8Ί�t�S$�9���_Y�yl&C��o� ��2ۑ�|rlZ�.PD��{W��*�FPB����p�B8ѱ�.�*
�q���oNd�D!7�s~e�x�	��K���� rjq,� ��9t�5���l��|��$G{��q�%
?�%L_���F��*�Fy����#����h���my\��]MX߻��
 _����ة0�5n<�
�;nT��"�sy����m�5L��Dp�
$�l��k'46z���j~E=z9��Ѿ�@�D����o��]��.�F&ʖ�~�\_.�wM��WD� -�%���J"a3�R����Ֆ!��G���ԏ�k���� ._2�|KO�ޝ*(�'�نK�^�!�G�LMd/hh�q�E��\NCE���l�b8��W	,�A��qV�E�� Ǆ"�1����Z?���:S���b>���Ķ�K꩑W����+��hՐ���h��O䙴��[
�����ʴ��S0����'�K�ž_Ƽ�\]���b�Gވ;���1���c�0Z���ۨ����O0ե%� h�v����W��t�}(����y^^c��En%�RSᖋTH�a���Ď �y	�e�w�ٚ�Alx�8^�7�Vf~����p�U�k�rs�m�*�ћ@�ĥ5���{�������?G�F��1m>.s�P{-o���D�=�8�/�w}[Y���y�`�)�l<�O�wڕ��F3�����[���\u�^�0�Ƕ��g�"���GB�����4��ny�,�Z�����`�B����"׃���p�VO��"����V*c5�����ט&�~����Ȱ��B�U���F˥9�^96��r-��< ��w2�(-b��Z��G2^::<D�ZrRW���8�"�i=�pz	4jhv=Bn��V��r�]{[�1��hD1ͷSV��qO9r�&-5�[��^;�S��A�f�S�H��:�{�ᚠu�w��ځ\V�O�Cc��Ǜhv&h�L�D�C��Ű�r��\HY_4	��)՛8N��9l�AB,��F^�5����a��|�.4�2@D�2�A��w#���m59�q����oKqv�%X�"�|h����X˯|�Q��G���_F��+�E��y4�+� e�h�=�� ���͉�<w�0vpc�ӛ��M7��0����ңD���;E��[�W�9<��m��O½Q~`;4_��)�XAc�-- v�<�P-��DB'�-I N@��׭j��qg[�Ej�d}����ͥ�7)��Ā�|�q��U_X�1̏ߟ"� k�6^R�����֗��D���;6��h|�V{�)��~��1-1׆f��Ɵ��S%�Z�X��l_�;yK��2�v��*��d7�m0ʝ�m��o��������VEy���G�H�*mI[ئ�6߶^�T:�pY���ۖ�I������N�:�|lO�mş.vK߇��_���V���� �V����9h���\�ō �[�Ɂ:�u�λ6V����Sy��ԙ�(�9~d�fտ؈�)i��[� \�A������uX����L /�pr���#�w�PՂ���E�՛��F W@�N�H���r�	�+���/	K�Cv����/4����kz1͡ �[wd�0�3��m�p�+	�?%I'bv+#T�}����ݶxN�u0�O��bo	���*��7��#��	qE,��sݐS�kpO�4����,�̞�jyb><��� c  C�;p��o��,']��Hݟ���ț��?���'�_�9�,���'���:ѣv�IK\�*{�y�%��s2���D���JM��ȑZ���}���|���0B����z�I-|��tW#�/��X�O�8 �n��5���h�< EF����A����~����� ���kA|F�8�紩�ݟ�޾���kߍ.�kTU1���F�} �F��Bj^8��ŋ�z��z<���6"�1P���c�Ɓ��'��O{D��Ӌo>���x"p�y��2�$��e>�+��jg]^b_?�[cW�����r�(\�F�{b;����r��!�7	��K_��gÀ�s~��p���c�qZ���k����f��m�?�a�����p� �N /z%UC�$��|����e�G�F�x¬�N^�h�\?�̣q�+�x��)ŎI|��ƻ���7^덝P�-׳V#����H&�oZ{)�fŻ��g�/r�����j��?L��u?��u:��'��A�/7��;��O�)�2���uF���0�LMj>�It�6V�v�o���=	�L�}�����������_h^ǉ�r��1�]�Mx�p�2m.[�;��U�uk�:>��vLc��rE_�I!<��X�'���-Բ�/Ծy�k�F���YX	&�$6[�J
�W@�"��ŗ��˗S��q蔛���@��8�rlh�9߮�Z��cgRX���U�|�:�M��A�3�2�b�yu�D��K��G�s���������D�J��;�yQ�Ŭad�I���g[(�A;	=Ws,��wD�PĈ��K]��z�{�ce��A�&����l��� d	9��a���q��
m�����N�����ܱ:@��#�<W��I�fb�"q���8_1��f3̲�c7�:��ɃW���l���!i���/�k#��o���C4�� �[/�i kWZ8�֨=Ƭ��=��}�l�������U�Q�Q���5���<*ܼ�GC�؄���e_�p�8]�S��S���.��p���f��Y{�AK��/�E�Y͏fi3	af�7_�����L��F�a��� �@���$�
�[�.M42�.<��U�2"�W���^�w�GtD3U���LL{nI��N�C�q{Կ����8�pX�Gs��ml��nA�1�e�;����\/�-��:�5P�J�.�H�j���4A���Ui��� �#c��@^���KZ�w��ck��r��-�"/cf����9[���9��� ��N�m�8�`�7?����v�X��]Khqƨx�CC�^鳸��+GRH�r�=I�/7�r�0'ꄈ������x�7�=��Á�i��"��{]�x+Xl��3|9jxK�KQK�]����nq�x@Bd� �f���v|�t3�}l�hF6|��c���#ƅ�M��̩�Ր���c�^�#��1=�����~\�7��le1{��ޱ�*|Q�#z�A���s�� {���#D�>��l>=��.1�-��z��l�������F���1i`��[�a)��79��G�-�?'�77*5�i��m�����a{��9��M�/H�%p��Rx��~b��7� .�&qv�_�
���������xޗ      �   �   x�U�]�0���S�((��CA �����u��<�I�ovf�X������(�� ����t<Lh�ޙ��xy��s�$U���^���߇����ΐt$#��<˅�V����aR�?N��K.��Ld=���7��nG�B>�4<o��U�cA�6�ݘ$6Wd��g��ؓ��׽De�㱝�v��` [t�W�ng�s�z��QJ�o���0�/w��      �   U  x�m�Qn�0D�����_�uBB��C%D�M	ȅ�:����� Y���ى5ػ��.���.����(_5�ղn$[/lZ�L���/ʮ���l(N�`��'~[;s��*`�>����Y��q��C���P�1Ĉ0����$ix�P��=q��U�	�-"��bj.U���F/��?��-�;SD�9r�q�Հ&�e�i�J��XmѮQt�a��F�b=�-�u��Ѧ?դ��B�zt���ω�Խ_E�[���|��$��������{ǥ(J���c�o|M�k�D��ã�+Y�p'�u��6�kg������ZR��k�ܿ�x��n�m!"?�Q�     