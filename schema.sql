-- Evergrow Electrical Service — Supabase Schema (v2 — safe to re-run)
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Paste → Run
-- All statements use IF NOT EXISTS / exception blocks so re-running won't break existing data.

CREATE TABLE IF NOT EXISTS invoices (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  date          date NOT NULL,
  invoice_number text NOT NULL,
  company_name  text NOT NULL,
  amount        numeric(10,2) NOT NULL,
  status        text DEFAULT 'unpaid',
  paid_date     date,
  created_at    timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS quotations (
  id                uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  date              date NOT NULL,
  quotation_number  text NOT NULL,
  company_name      text NOT NULL,
  amount            numeric(10,2) NOT NULL,
  status            text DEFAULT 'pending',
  accepted_date     date,
  created_at        timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS work_permits (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  worker_name   text NOT NULL,
  fin_number    text,
  permit_number text NOT NULL,
  expiry_date   date NOT NULL,
  csoc_expiry   date,
  created_at    timestamptz DEFAULT now()
);
-- add new columns to existing work_permits tables (safe to re-run):
ALTER TABLE work_permits ADD COLUMN IF NOT EXISTS fin_number text;
ALTER TABLE work_permits ADD COLUMN IF NOT EXISTS csoc_expiry date;

CREATE TABLE IF NOT EXISTS road_tax (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  plate_number  text NOT NULL,
  description   text,
  expiry_date   date NOT NULL,
  created_at    timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS insurance_policies (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  policy_name   text NOT NULL,
  provider      text NOT NULL,
  start_date    date NOT NULL,
  expiry_date   date NOT NULL,
  notes         text,
  created_at    timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS licensing_invoices (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  date          date NOT NULL,
  invoice_number text NOT NULL,
  company_name  text NOT NULL,
  amount        numeric(10,2) NOT NULL,
  status        text DEFAULT 'unpaid',
  paid_date     date,
  created_at    timestamptz DEFAULT now()
);

-- Enable RLS (idempotent)
ALTER TABLE invoices           ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotations         ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_permits       ENABLE ROW LEVEL SECURITY;
ALTER TABLE road_tax           ENABLE ROW LEVEL SECURITY;
ALTER TABLE insurance_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE licensing_invoices ENABLE ROW LEVEL SECURITY;

-- Create policies (wrapped in DO blocks so re-running is safe)
DO $$ BEGIN
  CREATE POLICY "allow_all" ON invoices FOR ALL TO anon USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "allow_all" ON quotations FOR ALL TO anon USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "allow_all" ON work_permits FOR ALL TO anon USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "allow_all" ON road_tax FOR ALL TO anon USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "allow_all" ON insurance_policies FOR ALL TO anon USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "allow_all" ON licensing_invoices FOR ALL TO anon USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ── NEW (2026-06): bank payments + salary/payments tabs ──
CREATE TABLE IF NOT EXISTS uob_payments (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  date date, invoice_number text, name text, amount numeric(10,2),
  created_at timestamptz DEFAULT now()
);
CREATE TABLE IF NOT EXISTS ocbc_payments (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  date date, invoice_number text, name text, amount numeric(10,2),
  created_at timestamptz DEFAULT now()
);
CREATE TABLE IF NOT EXISTS salary_payments (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  date date NOT NULL, name text NOT NULL, amount numeric(10,2) NOT NULL,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE uob_payments    ENABLE ROW LEVEL SECURITY;
ALTER TABLE ocbc_payments   ENABLE ROW LEVEL SECURITY;
ALTER TABLE salary_payments ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN CREATE POLICY "allow_all" ON uob_payments    FOR ALL TO anon USING (true) WITH CHECK (true); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE POLICY "allow_all" ON ocbc_payments   FOR ALL TO anon USING (true) WITH CHECK (true); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE POLICY "allow_all" ON salary_payments FOR ALL TO anon USING (true) WITH CHECK (true); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ── MIGRATION (2026-06): bank-payment Name column + allow any field to be left blank ──
-- Safe to re-run. Adds the Name column to UOB/OCBC and drops all NOT NULL rules so
-- partial entries are accepted. Does NOT touch or delete any existing rows.
ALTER TABLE uob_payments  ADD COLUMN IF NOT EXISTS name text;
ALTER TABLE ocbc_payments ADD COLUMN IF NOT EXISTS name text;
ALTER TABLE invoices           ALTER COLUMN date DROP NOT NULL, ALTER COLUMN invoice_number DROP NOT NULL, ALTER COLUMN company_name DROP NOT NULL, ALTER COLUMN amount DROP NOT NULL;
ALTER TABLE work_permits       ALTER COLUMN worker_name DROP NOT NULL, ALTER COLUMN permit_number DROP NOT NULL, ALTER COLUMN expiry_date DROP NOT NULL;
ALTER TABLE road_tax           ALTER COLUMN plate_number DROP NOT NULL, ALTER COLUMN expiry_date DROP NOT NULL;
ALTER TABLE insurance_policies ALTER COLUMN policy_name DROP NOT NULL, ALTER COLUMN provider DROP NOT NULL, ALTER COLUMN start_date DROP NOT NULL, ALTER COLUMN expiry_date DROP NOT NULL;
ALTER TABLE licensing_invoices ALTER COLUMN date DROP NOT NULL, ALTER COLUMN invoice_number DROP NOT NULL, ALTER COLUMN company_name DROP NOT NULL, ALTER COLUMN amount DROP NOT NULL;
ALTER TABLE uob_payments       ALTER COLUMN date DROP NOT NULL, ALTER COLUMN invoice_number DROP NOT NULL, ALTER COLUMN amount DROP NOT NULL;
ALTER TABLE ocbc_payments      ALTER COLUMN date DROP NOT NULL, ALTER COLUMN invoice_number DROP NOT NULL, ALTER COLUMN amount DROP NOT NULL;
