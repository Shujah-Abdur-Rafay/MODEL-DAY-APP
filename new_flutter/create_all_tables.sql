-- Create all required tables for the Model Day app

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create Jobs table
CREATE TABLE IF NOT EXISTS "jobs" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  -- Job specific fields
  client_name TEXT NOT NULL,
  type TEXT,
  location TEXT,
  date DATE,
  time TIME,
  end_time TEXT,
  rate DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  booking_agent JSONB,
  status TEXT DEFAULT 'pending',
  payment_status TEXT DEFAULT 'unpaid',
  agency_fee_percentage DECIMAL(5, 2),
  tax_percentage DECIMAL(5, 2),
  additional_fees DECIMAL(10, 2),
  extra_hours DECIMAL(5, 2),
  notes TEXT,
  files JSONB,
  images JSONB,
  requirements TEXT
);

-- Create Castings table
CREATE TABLE IF NOT EXISTS "castings" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  -- Casting specific fields
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  date DATE,
  time TIME,
  status TEXT DEFAULT 'pending',
  casting_director TEXT,
  agency TEXT,
  requirements TEXT,
  notes TEXT,
  files JSONB
);

-- Create Tests table
CREATE TABLE IF NOT EXISTS "tests" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  -- Test specific fields
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  date DATE,
  time TIME,
  status TEXT DEFAULT 'pending',
  photographer TEXT,
  agency TEXT,
  requirements TEXT,
  notes TEXT,
  files JSONB
);

-- Enable Row Level Security
ALTER TABLE "jobs" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "castings" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "tests" ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for Jobs table
CREATE POLICY "User can view their own jobs" ON "jobs"
  FOR SELECT
  USING (auth.uid() = created_by);

CREATE POLICY "User can create jobs" ON "jobs"
  FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "User can update their own jobs" ON "jobs"
  FOR UPDATE
  USING (auth.uid() = created_by);

CREATE POLICY "User can delete their own jobs" ON "jobs"
  FOR DELETE
  USING (auth.uid() = created_by);

-- Create RLS policies for Castings table
CREATE POLICY "User can view their own castings" ON "castings"
  FOR SELECT
  USING (auth.uid() = created_by);

CREATE POLICY "User can create castings" ON "castings"
  FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "User can update their own castings" ON "castings"
  FOR UPDATE
  USING (auth.uid() = created_by);

CREATE POLICY "User can delete their own castings" ON "castings"
  FOR DELETE
  USING (auth.uid() = created_by);

-- Create RLS policies for Tests table
CREATE POLICY "User can view their own tests" ON "tests"
  FOR SELECT
  USING (auth.uid() = created_by);

CREATE POLICY "User can create tests" ON "tests"
  FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "User can update their own tests" ON "tests"
  FOR UPDATE
  USING (auth.uid() = created_by);

CREATE POLICY "User can delete their own tests" ON "tests"
  FOR DELETE
  USING (auth.uid() = created_by);

-- Create triggers to automatically update the updated_date
CREATE OR REPLACE FUNCTION update_updated_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_date = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers on all tables
DROP TRIGGER IF EXISTS update_jobs_updated_date ON "jobs";
CREATE TRIGGER update_jobs_updated_date
BEFORE UPDATE ON "jobs"
FOR EACH ROW
EXECUTE FUNCTION update_updated_date();

DROP TRIGGER IF EXISTS update_castings_updated_date ON "castings";
CREATE TRIGGER update_castings_updated_date
BEFORE UPDATE ON "castings"
FOR EACH ROW
EXECUTE FUNCTION update_updated_date();

DROP TRIGGER IF EXISTS update_tests_updated_date ON "tests";
CREATE TRIGGER update_tests_updated_date
BEFORE UPDATE ON "tests"
FOR EACH ROW
EXECUTE FUNCTION update_updated_date();
