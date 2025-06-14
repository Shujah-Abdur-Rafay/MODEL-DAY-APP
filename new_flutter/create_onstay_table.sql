-- Create OnStay table
CREATE TABLE IF NOT EXISTS "OnStay" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  -- OnStay specific fields
  location_name TEXT NOT NULL,
  stay_type TEXT,
  address TEXT,
  check_in_date DATE,
  check_out_date DATE,
  check_in_time TEXT,
  check_out_time TEXT,
  cost DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  contact_name TEXT,
  contact_phone TEXT,
  contact_email TEXT,
  status TEXT DEFAULT 'pending',
  payment_status TEXT DEFAULT 'unpaid',
  notes TEXT,
  files JSONB
);

-- Enable Row Level Security
ALTER TABLE "OnStay" ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for OnStay table
CREATE POLICY "User can view their own stays" ON "OnStay"
  FOR SELECT
  USING (auth.uid() = created_by);

CREATE POLICY "User can create stays" ON "OnStay"
  FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "User can update their own stays" ON "OnStay"
  FOR UPDATE
  USING (auth.uid() = created_by);

CREATE POLICY "User can delete their own stays" ON "OnStay"
  FOR DELETE
  USING (auth.uid() = created_by);

-- Create a trigger to automatically update the updated_date
CREATE OR REPLACE FUNCTION update_updated_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_date = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger on the OnStay table
DROP TRIGGER IF EXISTS update_onstay_updated_date ON "OnStay";

CREATE TRIGGER update_onstay_updated_date
BEFORE UPDATE ON "OnStay"
FOR EACH ROW
EXECUTE FUNCTION update_updated_date();
