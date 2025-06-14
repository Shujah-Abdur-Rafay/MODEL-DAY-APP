-- Create Comments table for community posts
-- This is for Firebase Firestore collections, but included for reference

-- Note: Since this project uses Firebase Firestore, this SQL is for reference only.
-- Firestore collections are created automatically when documents are added.

-- The comments will be stored in Firestore with the following structure:
-- Collection: 'comments'
-- Document fields:
-- - postId: string (reference to the community post)
-- - authorId: string (user ID)
-- - authorName: string (display name)
-- - content: string (comment text)
-- - timestamp: timestamp (when comment was created)

-- For Supabase users, you can run this SQL to create the comments table:

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

-- Enable Row Level Security
ALTER TABLE public."Comment" ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Anyone can view comments" ON public."Comment"
  FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create comments" ON public."Comment"
  FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Users can update their own comments" ON public."Comment"
  FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Users can delete their own comments" ON public."Comment"
  FOR DELETE USING (auth.uid() = created_by);

-- Create trigger for updated_date
CREATE TRIGGER update_comment_updated_date BEFORE UPDATE ON public."Comment" FOR EACH ROW EXECUTE FUNCTION update_updated_date();

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_comment_user_id ON public."Comment"(created_by);
CREATE INDEX IF NOT EXISTS idx_comment_post_id ON public."Comment"(post_id);
