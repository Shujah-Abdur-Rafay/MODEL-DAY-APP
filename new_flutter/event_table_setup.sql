-- Create Event table for all event types
CREATE TABLE IF NOT EXISTS public."Event" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  
  -- Event type and basic info
  type TEXT NOT NULL CHECK (type IN ('option', 'job', 'directOption', 'directBooking', 'casting', 'onStay', 'test', 'polaroids', 'meeting', 'other')),
  client_name TEXT,
  date DATE,
  end_date DATE,
  start_time TEXT,
  end_time TEXT,
  location TEXT,
  
  -- Agent/Contact info
  agent_id UUID REFERENCES public."Agent"(id),
  
  -- Financial info
  day_rate DECIMAL(10, 2),
  usage_rate DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  
  -- Status fields
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'inProgress', 'completed', 'canceled', 'declined', 'postponed')),
  payment_status TEXT DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'partiallyPaid', 'paid')),
  option_status TEXT CHECK (option_status IN ('pending', 'clientCanceled', 'declined', 'postponed', 'confirmed')),
  
  -- Additional data
  notes TEXT,
  files JSONB,
  additional_data JSONB
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_event_type ON public."Event"(type);
CREATE INDEX IF NOT EXISTS idx_event_date ON public."Event"(date);
CREATE INDEX IF NOT EXISTS idx_event_created_by ON public."Event"(created_by);
CREATE INDEX IF NOT EXISTS idx_event_agent_id ON public."Event"(agent_id);
CREATE INDEX IF NOT EXISTS idx_event_status ON public."Event"(status);

-- Enable Row Level Security
ALTER TABLE public."Event" ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own events" ON public."Event"
  FOR SELECT USING (auth.uid() = created_by);

CREATE POLICY "Users can insert their own events" ON public."Event"
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update their own events" ON public."Event"
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete their own events" ON public."Event"
  FOR DELETE USING (auth.uid() = created_by);

-- Create trigger to update updated_date
CREATE OR REPLACE FUNCTION update_updated_date_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_date = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_event_updated_date BEFORE UPDATE ON public."Event"
    FOR EACH ROW EXECUTE FUNCTION update_updated_date_column();

-- Grant permissions
GRANT ALL ON public."Event" TO authenticated;
GRANT ALL ON public."Event" TO service_role;
