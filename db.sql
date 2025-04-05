--
-- PostgreSQL database dump
--

-- Dumped from database version 15.12 (Debian 15.12-0+deb12u2)
-- Dumped by pg_dump version 15.12 (Debian 15.12-0+deb12u2)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: benutzer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.benutzer (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    nachname character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    plz integer NOT NULL,
    wohnort character varying(255) NOT NULL,
    strasse character varying(255) NOT NULL,
    ispremium boolean DEFAULT false
);


ALTER TABLE public.benutzer OWNER TO postgres;

--
-- Name: benutzer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.benutzer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.benutzer_id_seq OWNER TO postgres;

--
-- Name: benutzer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.benutzer_id_seq OWNED BY public.benutzer.id;


--
-- Name: koordinaten; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.koordinaten (
    breitengrad double precision,
    laengengrad double precision,
    b_id integer,
    handy_id integer,
    zeitpunkt timestamp with time zone,
    zeitpunkt_stunde time without time zone
);


ALTER TABLE public.koordinaten OWNER TO postgres;

--
-- Name: benutzer id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benutzer ALTER COLUMN id SET DEFAULT nextval('public.benutzer_id_seq'::regclass);


--
-- Data for Name: benutzer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.benutzer (id, name, nachname, email, plz, wohnort, strasse, ispremium) FROM stdin;
\.


--
-- Data for Name: koordinaten; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.koordinaten (breitengrad, laengengrad, b_id, handy_id, zeitpunkt, zeitpunkt_stunde) FROM stdin;
\.


--
-- Name: benutzer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.benutzer_id_seq', 1, false);


--
-- Name: benutzer benutzer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benutzer
    ADD CONSTRAINT benutzer_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

