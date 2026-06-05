-- Evergrow Electrical Service — Supabase Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Paste → Run

CREATE TABLE invoices (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  date          date NOT NULL,
  invoice_number text NOT NULL,
  company_name  text NOT NULL,
  amount        numeric(10,2) NOT NULL,
  status        text DEFAULT 'unpaid',
  paid_date     date,
  created_at    timestamptz DEFAULT now()
);

CREATE TABLE work_permits (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  worker_name   text NOT NULL,
  permit_number text NOT NULL,
  expiry_date   date NOT NULL,
  created_at    timestamptz DEFAULT now()
);

CREATE TABLE road_tax (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  plate_number  text NOT NULL,
  description   text,
  expiry_date   date NOT NULL,
  created_at    timestamptz DEFAULT now()
);

CREATE TABLE insurance_policies (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  policy_name   text NOT NULL,
  provider      text NOT NULL,
  start_date    date NOT NULL,
  expiry_date   date NOT NULL,
  notes         text,
  created_at    timestamptz DEFAULT now()
);

-- Allow access via anon key (your shared password gates the frontend)
ALTER TABLE invoices           ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_permits       ENABLE ROW LEVEL SECURITY;
ALTER TABLE road_tax           ENABLE ROW LEVEL SECURITY;
ALTER TABLE insurance_policies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow_all" ON invoices           FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON work_permits       FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON road_tax           FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON insurance_policies FOR ALL TO anon USING (true) WITH CHECK (true);
