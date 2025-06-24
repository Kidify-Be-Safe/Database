--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13 (Debian 15.13-0+deb12u1)
-- Dumped by pg_dump version 15.13 (Debian 15.13-0+deb12u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA public;


--
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- Name: kidify; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA kidify;


ALTER SCHEMA kidify OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: application/octet-stream; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public."application/octet-stream" AS bytea;


ALTER DOMAIN public."application/octet-stream" OWNER TO postgres;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin; Type: TABLE; Schema: kidify; Owner: postgres
--

CREATE TABLE kidify.admin (
    a_id integer NOT NULL,
    mail character varying(255),
    passwort character varying(255),
    anzeigename character varying(255)
);


ALTER TABLE kidify.admin OWNER TO postgres;

--
-- Name: admin_a_id_seq; Type: SEQUENCE; Schema: kidify; Owner: postgres
--

CREATE SEQUENCE kidify.admin_a_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE kidify.admin_a_id_seq OWNER TO postgres;

--
-- Name: admin_a_id_seq; Type: SEQUENCE OWNED BY; Schema: kidify; Owner: postgres
--

ALTER SEQUENCE kidify.admin_a_id_seq OWNED BY kidify.admin.a_id;


--
-- Name: benutzer; Type: TABLE; Schema: kidify; Owner: postgres
--

CREATE TABLE kidify.benutzer (
    id integer NOT NULL,
    vorname character varying(255) NOT NULL,
    nachname character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    plz integer NOT NULL,
    wohnort character varying(255) NOT NULL,
    strasse character varying(255) NOT NULL,
    ispremium boolean DEFAULT false,
    passwort_hash character varying(255),
    b_id_hash character varying(255),
    istverifiziert boolean DEFAULT false,
    telefon character varying(25)
);


ALTER TABLE kidify.benutzer OWNER TO postgres;

--
-- Name: benutzer_id_seq; Type: SEQUENCE; Schema: kidify; Owner: postgres
--

CREATE SEQUENCE kidify.benutzer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE kidify.benutzer_id_seq OWNER TO postgres;

--
-- Name: benutzer_id_seq; Type: SEQUENCE OWNED BY; Schema: kidify; Owner: postgres
--

ALTER SEQUENCE kidify.benutzer_id_seq OWNED BY kidify.benutzer.id;


--
-- Name: freundesliste; Type: TABLE; Schema: kidify; Owner: postgres
--

CREATE TABLE kidify.freundesliste (
    b_id integer,
    f_id integer,
    CONSTRAINT freundesliste_check CHECK ((b_id <> f_id))
);


ALTER TABLE kidify.freundesliste OWNER TO postgres;

--
-- Name: koordinaten; Type: TABLE; Schema: kidify; Owner: postgres
--

CREATE TABLE kidify.koordinaten (
    breitengrad double precision,
    laengengrad double precision,
    b_id integer,
    zeitpunkt timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    stadt character varying(255),
    strasse character varying(255),
    plz integer,
    land character varying(255),
    ampel integer
);


ALTER TABLE kidify.koordinaten OWNER TO postgres;

--
-- Name: listencheck; Type: VIEW; Schema: kidify; Owner: postgres
--

CREATE VIEW kidify.listencheck AS
 SELECT f1.b_id,
    f1.f_id
   FROM (kidify.freundesliste f1
     JOIN kidify.freundesliste f2 ON (((f1.b_id = f2.f_id) AND (f1.f_id = f2.b_id))));


ALTER TABLE kidify.listencheck OWNER TO postgres;

--
-- Name: ls; Type: VIEW; Schema: kidify; Owner: postgres
--

CREATE VIEW kidify.ls AS
 SELECT koordinaten.breitengrad,
    koordinaten.laengengrad,
    koordinaten.b_id,
    koordinaten.zeitpunkt,
    koordinaten.stadt,
    koordinaten.strasse,
    koordinaten.plz,
    koordinaten.ampel
   FROM kidify.koordinaten
  ORDER BY koordinaten.zeitpunkt DESC;


ALTER TABLE kidify.ls OWNER TO postgres;

--
-- Name: freund_daten; Type: VIEW; Schema: kidify; Owner: postgres
--

CREATE VIEW kidify.freund_daten AS
 SELECT l.b_id,
    l.f_id,
    b.id,
    b.vorname,
    b.nachname,
    b.plz,
    b.wohnort,
    b.strasse,
    b.b_id_hash,
    ls.breitengrad,
    ls.laengengrad,
    ls.zeitpunkt,
    ls.stadt,
    ls.strasse AS f_strasse,
    ls.plz AS f_plz,
    ls.ampel
   FROM ((kidify.listencheck l
     JOIN kidify.benutzer b ON ((l.f_id = b.id)))
     CROSS JOIN kidify.ls ls);


ALTER TABLE kidify.freund_daten OWNER TO postgres;

--
-- Name: freundekoordinaten_view; Type: VIEW; Schema: kidify; Owner: postgres
--

CREATE VIEW kidify.freundekoordinaten_view AS
 SELECT DISTINCT k.breitengrad,
    k.laengengrad,
    k.b_id,
    k.zeitpunkt,
    k.stadt,
    k.strasse,
    k.plz,
    k.land,
    k.ampel,
    k.rn,
    u.vorname,
    u.nachname,
    u.email,
    u.wohnort,
    u.strasse AS benutzer_strasse
   FROM ((( SELECT koordinaten.breitengrad,
            koordinaten.laengengrad,
            koordinaten.b_id,
            koordinaten.zeitpunkt,
            koordinaten.stadt,
            koordinaten.strasse,
            koordinaten.plz,
            koordinaten.land,
            koordinaten.ampel,
            row_number() OVER (PARTITION BY koordinaten.b_id ORDER BY koordinaten.zeitpunkt DESC) AS rn
           FROM kidify.koordinaten) k
     JOIN kidify.listencheck lc ON ((lc.f_id = k.b_id)))
     JOIN kidify.benutzer u ON ((u.id = k.b_id)))
  WHERE (k.rn <= 5);


ALTER TABLE kidify.freundekoordinaten_view OWNER TO postgres;

--
-- Name: freunde; Type: VIEW; Schema: kidify; Owner: postgres
--

CREATE VIEW kidify.freunde AS
 SELECT DISTINCT freundekoordinaten_view.vorname,
    freundekoordinaten_view.nachname,
    freundekoordinaten_view.email,
    freundekoordinaten_view.b_id
   FROM kidify.freundekoordinaten_view;


ALTER TABLE kidify.freunde OWNER TO postgres;

--
-- Name: istinfreundesliste; Type: TABLE; Schema: kidify; Owner: postgres
--

CREATE TABLE kidify.istinfreundesliste (
    b_id integer,
    f_id integer,
    istinfreundesliste boolean
);


ALTER TABLE kidify.istinfreundesliste OWNER TO postgres;

--
-- Name: letzte_standorte; Type: VIEW; Schema: kidify; Owner: postgres
--

CREATE VIEW kidify.letzte_standorte AS
 SELECT koordinaten.breitengrad,
    koordinaten.laengengrad,
    koordinaten.b_id,
    koordinaten.zeitpunkt,
    koordinaten.stadt,
    koordinaten.strasse,
    koordinaten.plz,
    koordinaten.ampel
   FROM kidify.koordinaten
  ORDER BY koordinaten.zeitpunkt DESC
 LIMIT 5;


ALTER TABLE kidify.letzte_standorte OWNER TO postgres;

--
-- Name: freundkoordinaten; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.freundkoordinaten AS
 SELECT f.b_id,
    f.f_id,
    k.breitengrad,
    k.laengengrad
   FROM (kidify.freundesliste f
     JOIN kidify.koordinaten k ON ((f.f_id = k.b_id)));


ALTER TABLE public.freundkoordinaten OWNER TO postgres;

--
-- Name: letzte_standorte; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.letzte_standorte AS
 SELECT koordinaten.breitengrad,
    koordinaten.laengengrad,
    koordinaten.b_id,
    koordinaten.zeitpunkt
   FROM kidify.koordinaten
  ORDER BY koordinaten.zeitpunkt DESC
 LIMIT 5;


ALTER TABLE public.letzte_standorte OWNER TO postgres;

--
-- Name: listencheck; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.listencheck AS
 SELECT f1.b_id,
    f1.f_id
   FROM (kidify.freundesliste f1
     JOIN kidify.freundesliste f2 ON (((f1.b_id = f2.f_id) AND (f1.f_id = f2.b_id))));


ALTER TABLE public.listencheck OWNER TO postgres;

--
-- Name: ls; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.ls AS
 SELECT koordinaten.*::kidify.koordinaten AS koordinaten,
    koordinaten.breitengrad,
    koordinaten.laengengrad,
    koordinaten.b_id,
    koordinaten.zeitpunkt
   FROM kidify.koordinaten
  ORDER BY koordinaten.zeitpunkt DESC;


ALTER TABLE public.ls OWNER TO postgres;


--
-- Name: admin a_id; Type: DEFAULT; Schema: kidify; Owner: postgres
--

ALTER TABLE ONLY kidify.admin ALTER COLUMN a_id SET DEFAULT nextval('kidify.admin_a_id_seq'::regclass);


--
-- Name: benutzer id; Type: DEFAULT; Schema: kidify; Owner: postgres
--

ALTER TABLE ONLY kidify.benutzer ALTER COLUMN id SET DEFAULT nextval('kidify.benutzer_id_seq'::regclass);



--
-- Data for Name: job; Type: TABLE DATA; Schema: cron; Owner: postgres
--

COPY cron.job (jobid, schedule, command, nodename, nodeport, database, username, active, jobname) FROM stdin;
5	0 0 30 * * *	delete from kidify.benutzer where isverifiziert = false;	localhost	5432	tracking	postgres	t	\N
\.


-- Name: jobid_seq; Type: SEQUENCE SET; Schema: cron; Owner: postgres
--

SELECT pg_catalog.setval('cron.jobid_seq', 5, true);


--
-- Name: runid_seq; Type: SEQUENCE SET; Schema: cron; Owner: postgres
--

SELECT pg_catalog.setval('cron.runid_seq', 186149, true);


--
-- Name: admin_a_id_seq; Type: SEQUENCE SET; Schema: kidify; Owner: postgres
--

SELECT pg_catalog.setval('kidify.admin_a_id_seq', 1, false);


--
-- Name: benutzer_id_seq; Type: SEQUENCE SET; Schema: kidify; Owner: postgres
--

SELECT pg_catalog.setval('kidify.benutzer_id_seq', 111, true);


--
-- Name: test_i_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.test_i_seq', 1, false);


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: kidify; Owner: postgres
--

ALTER TABLE ONLY kidify.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (a_id);


--
-- Name: benutzer benutzer_pkey; Type: CONSTRAINT; Schema: kidify; Owner: postgres
--

ALTER TABLE ONLY kidify.benutzer
    ADD CONSTRAINT benutzer_pkey PRIMARY KEY (id);


--
-- Name: SCHEMA kidify; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA kidify TO web_anon;


--
-- Name: TABLE benutzer; Type: ACL; Schema: kidify; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE kidify.benutzer TO web_anon;


--
-- Name: SEQUENCE benutzer_id_seq; Type: ACL; Schema: kidify; Owner: postgres
--

GRANT SELECT,UPDATE ON SEQUENCE kidify.benutzer_id_seq TO web_anon;


--
-- Name: TABLE freundesliste; Type: ACL; Schema: kidify; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE kidify.freundesliste TO web_anon;


--
-- Name: TABLE koordinaten; Type: ACL; Schema: kidify; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE kidify.koordinaten TO web_anon;


--
-- Name: TABLE listencheck; Type: ACL; Schema: kidify; Owner: postgres
--

GRANT SELECT ON TABLE kidify.listencheck TO web_anon;


--
-- Name: TABLE freund_daten; Type: ACL; Schema: kidify; Owner: postgres
--

GRANT SELECT ON TABLE kidify.freund_daten TO web_anon;


--
-- Name: TABLE freundekoordinaten_view; Type: ACL; Schema: kidify; Owner: postgres
--

GRANT SELECT ON TABLE kidify.freundekoordinaten_view TO web_anon;


--
-- Name: TABLE freunde; Type: ACL; Schema: kidify; Owner: postgres
--

GRANT SELECT ON TABLE kidify.freunde TO web_anon;


--
-- Name: TABLE istinfreundesliste; Type: ACL; Schema: kidify; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE kidify.istinfreundesliste TO web_anon;


--
-- Name: TABLE letzte_standorte; Type: ACL; Schema: kidify; Owner: postgres
--

GRANT SELECT ON TABLE kidify.letzte_standorte TO web_anon;



--
-- PostgreSQL database dump complete
--

