# 🚀 Model Day - Vercel Deployment Guide

This guide will help you deploy your Model Day Flutter application to Vercel successfully.

## 📋 Prerequisites

Before deploying, ensure you have:

- ✅ Flutter SDK installed (>=3.2.3)
- ✅ Git repository set up
- ✅ Vercel account created
- ✅ Firebase project configured

## 🔧 Pre-Deployment Setup

### 1. Firebase Configuration

Ensure your Firebase configuration is properly set up:

```dart
// lib/firebase_options.dart should contain your Firebase config
// Make sure all required services are enabled:
// - Authentication (Email/Password, Google Sign-in)
// - Firestore Database
// - Storage (if using file uploads)
```

### 2. Environment Variables

For production deployment, you may need to set environment variables in Vercel:

1. Go to your Vercel project dashboard
2. Navigate to Settings > Environment Variables
3. Add any required variables (if applicable)

## 🚀 Deployment Methods

### Method 1: Automatic Deployment (Recommended)

1. **Connect GitHub to Vercel**:
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your GitHub repository: `https://github.com/Shujah-Abdur-Rafay/MODEL-DAY`

2. **Configure Project**:
   - Framework Preset: `Other`
   - Root Directory: `./` (leave as default)
   - Build Command: `flutter build web --release --base-href=/`
   - Output Directory: `build/web`
   - Install Command: `flutter pub get`

3. **Deploy**:
   - Click "Deploy"
   - Vercel will automatically build and deploy your app
   - Every push to main branch will trigger a new deployment

### Method 2: Manual Deployment

1. **Install Vercel CLI**:
   ```bash
   npm i -g vercel
   ```

2. **Build the Project**:
   ```bash
   # Use the provided script
   ./deploy.sh  # On Unix/Mac
   # OR
   deploy.bat   # On Windows
   
   # OR manually:
   flutter pub get
   flutter build web --release --base-href=/
   ```

3. **Deploy to Vercel**:
   ```bash
   vercel --prod
   ```

## ⚙️ Configuration Files

### vercel.json
The project includes an optimized `vercel.json` configuration:

```json
{
  "version": 2,
  "builds": [
    {
      "src": "pubspec.yaml",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "build/web"
      }
    }
  ],
  "routes": [
    // Optimized routing for Flutter web assets
  ],
  "buildCommand": "flutter build web --release --base-href=/",
  "installCommand": "flutter pub get"
}
```

### .vercelignore
Excludes unnecessary files from deployment to optimize build times.

## 🔍 Troubleshooting

### Common Issues and Solutions

1. **Build Fails**:
   ```bash
   # Clear Flutter cache and rebuild
   flutter clean
   flutter pub get
   flutter build web --release
   ```

2. **Assets Not Loading**:
   - Ensure `--base-href=/` is used in build command
   - Check that asset paths in `pubspec.yaml` are correct

3. **Firebase Connection Issues**:
   - Verify Firebase configuration in `lib/firebase_options.dart`
   - Ensure Firebase project has correct domain settings
   - Add your Vercel domain to Firebase authorized domains

4. **Routing Issues**:
   - The `vercel.json` includes proper SPA routing configuration
   - All routes should redirect to `index.html`

### Performance Optimization

1. **Enable Compression**:
   - Vercel automatically enables gzip compression
   - The configuration includes proper headers for optimization

2. **Caching**:
   - Static assets are automatically cached by Vercel
   - Flutter web builds include proper cache headers

## 📱 Post-Deployment

### 1. Test Your Application

After deployment, test these key features:
- ✅ User authentication (login/signup)
- ✅ Navigation between pages
- ✅ Event creation and management
- ✅ Data persistence
- ✅ Mobile responsiveness
- ✅ File uploads (if applicable)

### 2. Custom Domain (Optional)

To add a custom domain:
1. Go to Vercel project settings
2. Navigate to "Domains"
3. Add your custom domain
4. Update DNS settings as instructed

### 3. Analytics and Monitoring

Consider adding:
- Vercel Analytics for performance monitoring
- Error tracking (Sentry, etc.)
- User analytics (Google Analytics, etc.)

## 🔗 Useful Links

- **Live App**: Your Vercel deployment URL
- **GitHub Repository**: https://github.com/Shujah-Abdur-Rafay/MODEL-DAY
- **Vercel Documentation**: https://vercel.com/docs
- **Flutter Web Documentation**: https://docs.flutter.dev/platform-integration/web

## 🆘 Support

If you encounter issues:

1. Check the Vercel deployment logs
2. Review the Flutter web build output
3. Ensure all dependencies are compatible with web
4. Verify Firebase configuration

For additional support, create an issue in the GitHub repository.

---

**Happy Deploying! 🎉**
