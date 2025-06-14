# Model Day - Professional Modeling Career Manager 📱

A comprehensive Flutter application designed specifically for models to manage their careers, bookings, and professional activities.

## 🌟 Features

### Core Functionality
- **📅 Event Management** - Complete event system with 10 different event types
- **💼 Job Tracking** - Enhanced job forms with financial calculations
- **👥 Agent Directory** - Comprehensive agent management with contracts
- **🏢 Agency Management** - Track agency relationships and contracts
- **📊 Export System** - CSV export functionality for all data
- **📱 Mobile Navigation** - Swipe gestures for mobile devices

### Event Types Supported
1. **Options** - Client options with rates and status tracking
2. **Jobs** - Complete job management with financial calculations
3. **Direct Options** - Direct booking options
4. **Direct Bookings** - Direct job bookings
5. **Castings** - Casting calls with transfer capabilities
6. **On Stay** - Travel assignments with accommodation
7. **Tests** - Photo tests (free/paid)
8. **Polaroids** - Polaroid sessions
9. **Meetings** - Industry meetings
10. **Other** - Custom events

### Advanced Features
- **🔐 Secure Authentication** - Firebase-powered user management
- **📱 Responsive Design** - Works seamlessly on all devices
- **🎯 Quick Navigation** - Beautiful dashboard with easy access to all features
- **💰 Financial Calculations** - Automatic rate calculations with taxes and fees
- **📄 File Management** - Document upload and management
- **🌍 Multi-Currency** - Support for 9 different currencies

## 🚀 Technology Stack

- **Frontend**: Flutter (Web, iOS, Android)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **UI/UX**: Custom responsive design with animations
- **Deployment**: Vercel (Web)
- **Database**: Cloud Firestore with optimized queries

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK (>=3.2.3)
- Dart SDK
- Firebase account
- Git

### Local Development
```bash
# Clone the repository
git clone https://github.com/Shujah-Abdur-Rafay/MODEL-DAY.git
cd MODEL-DAY

# Install dependencies
flutter pub get

# Run the app
flutter run -d web
```

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication (Email/Password, Google Sign-in)
3. Create Firestore database
4. Add your Firebase configuration to `lib/firebase_options.dart`

### Environment Variables
Create a `.env` file in the root directory:
```env
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_PROJECT_ID=your_project_id
```

## 🚀 Deployment

### Vercel Deployment
This project is optimized for Vercel deployment:

1. **Connect to Vercel**:
   ```bash
   # Install Vercel CLI
   npm i -g vercel

   # Deploy
   vercel
   ```

2. **Automatic Deployment**:
   - Push to main branch triggers automatic deployment
   - Vercel configuration is in `vercel.json`
   - Build command: `flutter build web --release --base-href=/`

3. **Environment Variables in Vercel**:
   - Add Firebase configuration in Vercel dashboard
   - Set environment variables for production

### Manual Build
```bash
# Build for web
flutter build web --release

# The build files will be in build/web/
```

## 🎯 Latest Updates (v3.0)

✅ **Complete Event System** - All 10 event types implemented
✅ **Enhanced Job Forms** - Financial calculations and multi-currency support
✅ **Agency Management** - Contract tracking and enhanced details
✅ **Export Functionality** - CSV export for all data types
✅ **Mobile Swipe Navigation** - Gesture-based navigation
✅ **File Upload System** - Document management with type icons
✅ **Responsive Design** - Optimized for all screen sizes
✅ **Vercel Optimization** - Configured for seamless deployment

## 🔗 Live Demo

**Web App**: [Model Day on Vercel](https://model-day.vercel.app)

## 📱 Usage

### Creating Events
1. Use the Quick Add Event button on the Welcome page
2. Select from 10 different event types
3. Fill in the type-specific form fields
4. Submit to create the event

### Managing Jobs
1. Navigate to Jobs section
2. Create new jobs with enhanced financial calculations
3. Track payment status and job progress
4. Export data as needed

### Agency Management
1. Add agencies with complete contact information
2. Track contract dates and agency types
3. Manage representing vs mother agency relationships

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support, email support@modelday.app or create an issue in this repository.

---

*Built with ❤️ for the modeling community*
