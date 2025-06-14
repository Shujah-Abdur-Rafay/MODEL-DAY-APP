-- Modal Day Complete Database Setup Script
-- Run this in your Supabase SQL Editor to create all tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Job table
CREATE TABLE IF NOT EXISTS public."Job" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  client_name TEXT NOT NULL,
  type TEXT,
  location TEXT,
  booking_agent TEXT,
  date DATE,
  time TEXT,
  end_time TEXT,
  rate DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  agency_fee_percentage DECIMAL(5, 2),
  tax_percentage DECIMAL(5, 2),
  additional_fees DECIMAL(10, 2),
  extra_hours DECIMAL(5, 2),
  payment_status TEXT DEFAULT 'unpaid',
  status TEXT DEFAULT 'pending',
  files JSONB,
  notes TEXT
);

-- Create Agent table
CREATE TABLE IF NOT EXISTS public."Agent" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  agency TEXT,
  city TEXT,
  country TEXT,
  instagram TEXT,
  notes TEXT
);

-- Create Casting table
CREATE TABLE IF NOT EXISTS public."Casting" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  client_name TEXT NOT NULL,
  type TEXT,
  location TEXT,
  booking_agent TEXT,
  date DATE,
  time TEXT,
  end_time TEXT,
  rate DECIMAL(10, 2),
  extra_hours DECIMAL(5, 2),
  extra_hours_rate DECIMAL(10, 2),
  agency_fee_percentage DECIMAL(5, 2),
  tax_percentage DECIMAL(5, 2),
  additional_fees DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  files JSONB,
  notes TEXT,
  status TEXT DEFAULT 'pending',
  callback BOOLEAN DEFAULT false,
  callback_date DATE,
  payment_status TEXT DEFAULT 'unpaid'
);

-- Create Test table
CREATE TABLE IF NOT EXISTS public."Test" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  client_name TEXT NOT NULL,
  type TEXT,
  location TEXT,
  booking_agent TEXT,
  date DATE,
  time TEXT,
  end_time TEXT,
  status TEXT DEFAULT 'scheduled',
  notes TEXT
);

-- Create Shooting table
CREATE TABLE IF NOT EXISTS public."Shooting" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  client_name TEXT NOT NULL,
  type TEXT,
  location TEXT,
  booking_agent TEXT,
  date DATE,
  time TEXT,
  end_time TEXT,
  rate DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  files JSONB,
  notes TEXT,
  status TEXT DEFAULT 'pending',
  converted_to_job BOOLEAN DEFAULT false
);

-- Create Polaroid table
CREATE TABLE IF NOT EXISTS public."Polaroid" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  client_name TEXT NOT NULL,
  type TEXT,
  location TEXT,
  booking_agent TEXT,
  date DATE,
  time TEXT,
  end_time TEXT,
  rate DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  files JSONB,
  notes TEXT,
  status TEXT DEFAULT 'pending'
);

-- Create Meeting table
CREATE TABLE IF NOT EXISTS public."Meeting" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  client_name TEXT NOT NULL,
  type TEXT,
  location TEXT,
  booking_agent TEXT,
  date DATE,
  time TEXT,
  end_time TEXT,
  email TEXT,
  phone TEXT,
  rate TEXT,
  currency TEXT DEFAULT 'USD',
  notes TEXT,
  status TEXT DEFAULT 'scheduled'
);

-- Create IndustryContact table
CREATE TABLE IF NOT EXISTS public."IndustryContact" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  name TEXT NOT NULL,
  job_title TEXT,
  company TEXT,
  instagram TEXT,
  mobile TEXT,
  email TEXT,
  city TEXT,
  country TEXT,
  notes TEXT
);

-- Create Agency table
CREATE TABLE IF NOT EXISTS public."Agency" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  name TEXT NOT NULL,
  agency_type TEXT,
  website TEXT,
  address TEXT,
  city TEXT,
  country TEXT,
  main_booker JSONB,
  finance_contact JSONB,
  additional_contacts JSONB,
  commission_rate DECIMAL(5, 2),
  contract TEXT,
  notes TEXT,
  status TEXT DEFAULT 'active'
);

-- Create JobGallery table
CREATE TABLE IF NOT EXISTS public."JobGallery" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  name TEXT NOT NULL,
  photographer_name TEXT,
  location TEXT,
  hair_makeup TEXT,
  stylist TEXT,
  date DATE,
  description TEXT,
  images TEXT
);

-- Create AiJob table
CREATE TABLE IF NOT EXISTS public."AiJob" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  client_name TEXT NOT NULL,
  type TEXT,
  description TEXT,
  location TEXT,
  booking_agent TEXT,
  date DATE,
  time TEXT,
  rate DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  ai_assets JSONB,
  status TEXT DEFAULT 'pending',
  payment_status TEXT DEFAULT 'unpaid',
  notes TEXT
);

-- Create DirectBooking table
CREATE TABLE IF NOT EXISTS public."DirectBooking" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  client_name TEXT NOT NULL,
  booking_type TEXT,
  location TEXT,
  booking_agent TEXT,
  date DATE,
  time TEXT,
  end_time TEXT,
  rate DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  extra_hours TEXT,
  agency_fee_percentage TEXT,
  tax_percentage TEXT,
  additional_fees TEXT,
  phone TEXT,
  email TEXT,
  status TEXT DEFAULT 'scheduled',
  payment_status TEXT DEFAULT 'unpaid',
  files JSONB,
  notes TEXT
);

-- Create DirectOptions table
CREATE TABLE IF NOT EXISTS public."DirectOptions" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
  client_name TEXT NOT NULL,
  option_type TEXT,
  location TEXT,
  booking_agent TEXT,
  date DATE,
  time TEXT,
  end_time TEXT,
  rate DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  extra_hours TEXT,
  agency_fee_percentage TEXT,
  tax_percentage TEXT,
  additional_fees TEXT,
  phone TEXT,
  email TEXT,
  status TEXT DEFAULT 'option',
  payment_status TEXT DEFAULT 'unpaid',
  files JSONB,
  notes TEXT
);

-- Create OnStay table (matching original project)
CREATE TABLE IF NOT EXISTS public."OnStay" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,
  
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

-- Create Report table
CREATE TABLE IF NOT EXISTS public."Report" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  is_sample BOOLEAN DEFAULT false,

  title TEXT NOT NULL,
  date_from DATE,
  date_to DATE,
  payment_status TEXT,
  date_filter TEXT,
  export_url TEXT,
  total_jobs INTEGER DEFAULT 0,
  total_amount DECIMAL(10, 2) DEFAULT 0
);

-- Create Comments table for community posts
CREATE TABLE IF NOT EXISTS public."Comment" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),

  post_id TEXT NOT NULL,
  author_id TEXT NOT NULL,
  author_name TEXT NOT NULL,
  content TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Job" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Agent" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Casting" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Test" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Shooting" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Polaroid" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Meeting" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."IndustryContact" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Agency" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."JobGallery" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."AiJob" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."DirectBooking" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."DirectOptions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."OnStay" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Report" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Comment" ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for profiles
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create RLS policies for Job table
CREATE POLICY "User can view their own jobs" ON public."Job"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create jobs" ON public."Job"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own jobs" ON public."Job"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own jobs" ON public."Job"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for Agent table
CREATE POLICY "User can view their own agents" ON public."Agent"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create agents" ON public."Agent"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own agents" ON public."Agent"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own agents" ON public."Agent"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for Casting table
CREATE POLICY "User can view their own castings" ON public."Casting"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create castings" ON public."Casting"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own castings" ON public."Casting"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own castings" ON public."Casting"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for Test table
CREATE POLICY "User can view their own tests" ON public."Test"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create tests" ON public."Test"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own tests" ON public."Test"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own tests" ON public."Test"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for Shooting table
CREATE POLICY "User can view their own shootings" ON public."Shooting"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create shootings" ON public."Shooting"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own shootings" ON public."Shooting"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own shootings" ON public."Shooting"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for Polaroid table
CREATE POLICY "User can view their own polaroids" ON public."Polaroid"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create polaroids" ON public."Polaroid"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own polaroids" ON public."Polaroid"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own polaroids" ON public."Polaroid"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for Meeting table
CREATE POLICY "User can view their own meetings" ON public."Meeting"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create meetings" ON public."Meeting"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own meetings" ON public."Meeting"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own meetings" ON public."Meeting"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for IndustryContact table
CREATE POLICY "User can view their own contacts" ON public."IndustryContact"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create contacts" ON public."IndustryContact"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own contacts" ON public."IndustryContact"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own contacts" ON public."IndustryContact"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for Agency table
CREATE POLICY "User can view their own agencies" ON public."Agency"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create agencies" ON public."Agency"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own agencies" ON public."Agency"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own agencies" ON public."Agency"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for JobGallery table
CREATE POLICY "User can view their own galleries" ON public."JobGallery"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create galleries" ON public."JobGallery"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own galleries" ON public."JobGallery"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own galleries" ON public."JobGallery"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for AiJob table
CREATE POLICY "User can view their own ai jobs" ON public."AiJob"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create ai jobs" ON public."AiJob"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own ai jobs" ON public."AiJob"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own ai jobs" ON public."AiJob"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for DirectBooking table
CREATE POLICY "User can view their own direct bookings" ON public."DirectBooking"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create direct bookings" ON public."DirectBooking"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own direct bookings" ON public."DirectBooking"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own direct bookings" ON public."DirectBooking"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for DirectOptions table
CREATE POLICY "User can view their own direct options" ON public."DirectOptions"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create direct options" ON public."DirectOptions"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own direct options" ON public."DirectOptions"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own direct options" ON public."DirectOptions"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for OnStay table
CREATE POLICY "User can view their own stays" ON public."OnStay"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create stays" ON public."OnStay"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own stays" ON public."OnStay"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own stays" ON public."OnStay"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for Report table
CREATE POLICY "User can view their own reports" ON public."Report"
  FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "User can create reports" ON public."Report"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "User can update their own reports" ON public."Report"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "User can delete their own reports" ON public."Report"
  FOR DELETE USING (auth.uid() = created_by);

-- Create RLS policies for Comment table
CREATE POLICY "Anyone can view comments" ON public."Comment"
  FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create comments" ON public."Comment"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Users can update their own comments" ON public."Comment"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Users can delete their own comments" ON public."Comment"
  FOR DELETE USING (auth.uid() = created_by);

-- Create a trigger to automatically update the updated_date
CREATE OR REPLACE FUNCTION update_updated_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_date = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for all tables
CREATE TRIGGER update_job_updated_date BEFORE UPDATE ON public."Job" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_agent_updated_date BEFORE UPDATE ON public."Agent" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_casting_updated_date BEFORE UPDATE ON public."Casting" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_test_updated_date BEFORE UPDATE ON public."Test" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_shooting_updated_date BEFORE UPDATE ON public."Shooting" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_polaroid_updated_date BEFORE UPDATE ON public."Polaroid" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_meeting_updated_date BEFORE UPDATE ON public."Meeting" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_industrycontact_updated_date BEFORE UPDATE ON public."IndustryContact" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_agency_updated_date BEFORE UPDATE ON public."Agency" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_jobgallery_updated_date BEFORE UPDATE ON public."JobGallery" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_aijob_updated_date BEFORE UPDATE ON public."AiJob" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_directbooking_updated_date BEFORE UPDATE ON public."DirectBooking" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_directoptions_updated_date BEFORE UPDATE ON public."DirectOptions" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_onstay_updated_date BEFORE UPDATE ON public."OnStay" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_report_updated_date BEFORE UPDATE ON public."Report" FOR EACH ROW EXECUTE FUNCTION update_updated_date();
CREATE TRIGGER update_comment_updated_date BEFORE UPDATE ON public."Comment" FOR EACH ROW EXECUTE FUNCTION update_updated_date();

-- Create function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_job_user_id ON public."Job"(created_by);
CREATE INDEX IF NOT EXISTS idx_agent_user_id ON public."Agent"(created_by);
CREATE INDEX IF NOT EXISTS idx_casting_user_id ON public."Casting"(created_by);
CREATE INDEX IF NOT EXISTS idx_test_user_id ON public."Test"(created_by);
CREATE INDEX IF NOT EXISTS idx_shooting_user_id ON public."Shooting"(created_by);
CREATE INDEX IF NOT EXISTS idx_polaroid_user_id ON public."Polaroid"(created_by);
CREATE INDEX IF NOT EXISTS idx_meeting_user_id ON public."Meeting"(created_by);
CREATE INDEX IF NOT EXISTS idx_industrycontact_user_id ON public."IndustryContact"(created_by);
CREATE INDEX IF NOT EXISTS idx_agency_user_id ON public."Agency"(created_by);
CREATE INDEX IF NOT EXISTS idx_jobgallery_user_id ON public."JobGallery"(created_by);
CREATE INDEX IF NOT EXISTS idx_aijob_user_id ON public."AiJob"(created_by);
CREATE INDEX IF NOT EXISTS idx_directbooking_user_id ON public."DirectBooking"(created_by);
CREATE INDEX IF NOT EXISTS idx_directoptions_user_id ON public."DirectOptions"(created_by);
CREATE INDEX IF NOT EXISTS idx_onstay_user_id ON public."OnStay"(created_by);
CREATE INDEX IF NOT EXISTS idx_report_user_id ON public."Report"(created_by);
CREATE INDEX IF NOT EXISTS idx_comment_user_id ON public."Comment"(created_by);
CREATE INDEX IF NOT EXISTS idx_comment_post_id ON public."Comment"(post_id);
