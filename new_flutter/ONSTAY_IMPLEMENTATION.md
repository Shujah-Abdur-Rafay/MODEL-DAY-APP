# OnStay Supabase Integration Implementation

This document outlines the complete implementation of the OnStay feature in the Flutter application, mirroring the functionality from the original JavaScript project.

## Overview

The OnStay feature allows users to manage their accommodation stays with full CRUD (Create, Read, Update, Delete) operations, user authentication, and data persistence through Supabase.

## Implemented Components

### 1. OnStay Model (`lib/models/on_stay.dart`)

**Features:**
- Complete data model matching the original JavaScript entity
- All fields from the database schema including:
  - Basic info: location_name, stay_type, address
  - Dates: check_in_date, check_out_date, check_in_time, check_out_time
  - Financial: cost, currency, payment_status
  - Contact: contact_name, contact_phone, contact_email
  - Status: status, notes, files
  - Metadata: created_by, created_date, updated_date, is_sample

**Helper Methods:**
- `dateRange`: Formatted date range display
- `timeRange`: Formatted time range display
- `formattedCost`: Currency-formatted cost display
- `statusColor` & `paymentStatusColor`: Color coding for status indicators
- `copyWith`: Immutable updates
- `fromJson` & `toJson`: Supabase serialization

### 2. OnStay Service (`lib/services/on_stay_service.dart`)

**CRUD Operations:**
- `list()`: Get all stays for current user
- `get(id)`: Get specific stay by ID
- `create(data)`: Create new stay
- `update(id, data)`: Update existing stay
- `delete(id)`: Delete stay

**Advanced Filtering:**
- `getByStatus(status)`: Filter by stay status
- `getByPaymentStatus(paymentStatus)`: Filter by payment status
- `getUpcoming()`: Future check-in dates
- `getCurrent()`: Currently staying (between check-in and check-out)
- `getPast()`: Past stays (check-out date passed)
- `searchByLocation(query)`: Search by location name

**Security Features:**
- Row Level Security (RLS) enforcement
- User authentication checks
- User-scoped data access (created_by filtering)
- Automatic timestamp management

### 3. OnStay Listing Page (`lib/pages/on_stay_page.dart`)

**UI Features:**
- Tabbed interface (All, Upcoming, Current, Past)
- Card-based stay display with:
  - Location name and status chips
  - Stay type and address
  - Date and time ranges
  - Cost and payment status
- Empty state with call-to-action
- Pull-to-refresh functionality
- Detailed view modal with all stay information

**Interactive Elements:**
- Status and payment status color coding
- Tap to view details
- Navigation to edit form
- Add new stay button

### 4. OnStay Form Page (`lib/pages/new_on_stay_page.dart`)

**Form Sections:**
1. **Basic Information**
   - Location name (required)
   - Stay type (dropdown)
   - Address (multi-line)

2. **Dates & Times**
   - Check-in/out date pickers
   - Check-in/out time fields
   - Date validation (check-out after check-in)

3. **Cost Information**
   - Cost amount (required, numeric)
   - Currency selection (dropdown)

4. **Contact Information**
   - Contact name, phone, email
   - Email validation

5. **Status Information**
   - Stay status (pending, confirmed, cancelled, completed)
   - Payment status (unpaid, paid, partial)

6. **Additional Notes**
   - Free-text notes field

**Form Features:**
- Comprehensive validation
- Loading states
- Error handling
- Success feedback
- Support for both create and edit modes
- Scrollable form with proper keyboard handling

## Database Integration

### Supabase Configuration
- Uses existing Supabase setup from main.dart
- URL: `https://nvawwmygojhhvimvjiif.supabase.co`
- Anonymous key authentication
- Row Level Security enabled

### Database Schema
The OnStay table structure matches the original migration:
```sql
CREATE TABLE "OnStay" (
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
```

### RLS Policies
- Users can only view/edit their own stays
- Automatic user ID assignment on creation
- Secure data isolation between users

## Key Features Implemented

### 1. **Complete CRUD Operations**
- Create new stays with comprehensive form
- Read/list stays with filtering and search
- Update existing stays (edit functionality)
- Delete stays with confirmation

### 2. **User Authentication Integration**
- Leverages existing AuthService
- User-scoped data access
- Automatic user ID assignment

### 3. **Advanced Filtering & Search**
- Filter by status (pending, confirmed, etc.)
- Filter by payment status
- Time-based filtering (upcoming, current, past)
- Location-based search

### 4. **Rich UI/UX**
- Material Design 3 components
- Dark theme consistency
- Loading states and error handling
- Responsive design
- Accessibility considerations

### 5. **Data Validation**
- Required field validation
- Email format validation
- Numeric validation for costs
- Date logic validation

### 6. **Error Handling**
- Network error handling
- Form validation errors
- User-friendly error messages
- Graceful degradation

## Usage Instructions

### Adding a New Stay
1. Navigate to OnStay page
2. Click the "+" button
3. Fill out the comprehensive form
4. Save to create the stay

### Viewing Stays
1. Use tabs to filter by time period
2. Tap any stay card to view details
3. Use pull-to-refresh to update data

### Editing Stays
1. Tap a stay card to view details
2. Click "Edit" in the detail modal
3. Modify fields as needed
4. Save changes

### Filtering & Search
- Use tab bar for quick time-based filtering
- Service methods support additional filtering options
- Search functionality available through service layer

## Technical Notes

### Dependencies Used
- `supabase_flutter`: Database and authentication
- `provider`: State management (via existing AuthService)
- Material Design 3 components
- Existing app theme and layout components

### Code Organization
- Models: Data structures and serialization
- Services: Business logic and API calls
- Pages: UI components and user interaction
- Follows existing app architecture patterns

### Performance Considerations
- Efficient data loading with user-scoped queries
- Proper disposal of controllers and resources
- Optimized rebuild patterns with setState
- Lazy loading and pagination ready (can be added)

## Future Enhancements

### Potential Additions
1. **File Upload Support**
   - Implement file attachment functionality
   - Image gallery for stay photos
   - Document storage (confirmations, receipts)

2. **Calendar Integration**
   - Visual calendar view of stays
   - Conflict detection for overlapping dates
   - Export to device calendar

3. **Expense Tracking**
   - Detailed cost breakdown
   - Currency conversion
   - Expense categories

4. **Notifications**
   - Check-in/out reminders
   - Payment due notifications
   - Status change alerts

5. **Reporting**
   - Stay statistics and analytics
   - Cost summaries by period
   - Export functionality

6. **Offline Support**
   - Local data caching
   - Sync when online
   - Offline form completion

This implementation provides a solid foundation for accommodation management with room for future enhancements based on user needs.
