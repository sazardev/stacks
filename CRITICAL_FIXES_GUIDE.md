# 🔧 Critical Fixes Implementation Guide
**Priority: CRITICAL - Do These First**

---

## 1. Fix Dependency Injection System

### Problem
The app uses manual DI registration instead of generated code, and mock repositories might be injected instead of Firebase implementations.

### Solution

#### Step 1: Update `pubspec.yaml`
Ensure these dependencies exist:
```yaml
dependencies:
  injectable: ^2.3.2
  get_it: ^7.6.4

dev_dependencies:
  injectable_generator: ^2.4.1
  build_runner: ^2.4.6
```

#### Step 2: Run Code Generation
```powershell
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Step 3: Update `injection.dart`
Replace manual registration with generated code:

```dart
// lib/infrastructure/core/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Register Firebase instances
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  
  // Generated registrations
  getIt.init();
}
```

#### Step 4: Verify All Repositories Use @LazySingleton
Check each Firebase repository has proper annotation:

```dart
@LazySingleton(as: OrderRepository)
class FirebaseOrderRepository implements OrderRepository {
  // ...
}
```

#### Step 5: Delete Mock Repositories
```powershell
# Delete these files
Remove-Item "lib\infrastructure\repositories\food_safety_repository_impl.dart"
Remove-Item "lib\infrastructure\repositories\analytics_repository_impl.dart"

# If other *_impl.dart files exist (not Firebase*), delete them too
```

#### Step 6: Update Main App Initialization
```dart
// lib/main.dart or lib/main_demo.dart
import 'infrastructure/core/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureDependencies();  // DI setup
  runApp(MyApp());
}
```

---

## 2. Complete Firestore Security Rules

### Problem
Your `firestore.rules` file is incomplete - no actual collection rules, incomplete helper functions.

### Solution

Replace `firestore.rules` with comprehensive rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ======================== Helper Functions ========================
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    
    function isRole(role) {
      return isAuthenticated() && getUserData().role == role;
    }
    
    function isKitchenStaff() {
      return isAuthenticated() && (
        isRole('line_cook') || 
        isRole('sous_chef') || 
        isRole('head_chef') || 
        isRole('kitchen_manager') ||
        isRole('owner')
      );
    }
    
    function isManagerOrAbove() {
      return isAuthenticated() && (
        isRole('kitchen_manager') || 
        isRole('general_manager') || 
        isRole('owner')
      );
    }
    
    function isOwnerRole() {
      return isAuthenticated() && isRole('owner');
    }
    
    function isValidString(value, minLen, maxLen) {
      return value is string && 
             value.size() >= minLen && 
             value.size() <= maxLen;
    }
    
    function isValidTimestamp(value) {
      return value is timestamp;
    }
    
    // ======================== Users Collection ========================
    
    match /users/{userId} {
      allow read: if isAuthenticated();
      
      allow create: if isAuthenticated() && 
                       isOwner(userId) &&
                       isValidUserData();
      
      allow update: if isAuthenticated() && 
                       (isOwner(userId) || isManagerOrAbove()) &&
                       isValidUserData();
      
      allow delete: if false; // Never allow user deletion via client
      
      function isValidUserData() {
        return request.resource.data.keys().hasAll(['id', 'email', 'name', 'role', 'createdAt']) &&
               isValidString(request.resource.data.email, 5, 100) &&
               isValidString(request.resource.data.name, 2, 100) &&
               isValidTimestamp(request.resource.data.createdAt);
      }
    }
    
    // ======================== Orders Collection ========================
    
    match /orders/{orderId} {
      allow read: if isAuthenticated() && isKitchenStaff();
      
      allow create: if isAuthenticated() && isValidOrderData();
      
      allow update: if isAuthenticated() && 
                       isKitchenStaff() &&
                       isValidOrderData();
      
      allow delete: if isManagerOrAbove();
      
      function isValidOrderData() {
        let data = request.resource.data;
        return data.keys().hasAll(['id', 'customerId', 'items', 'status', 'createdAt']) &&
               data.items.size() > 0 &&
               data.items.size() <= 100 &&
               isValidTimestamp(data.createdAt);
      }
    }
    
    // ======================== Stations Collection ========================
    
    match /stations/{stationId} {
      allow read: if isAuthenticated();
      
      allow create: if isManagerOrAbove() && isValidStationData();
      
      allow update: if isAuthenticated() && 
                       isKitchenStaff() &&
                       isValidStationData();
      
      allow delete: if isManagerOrAbove();
      
      function isValidStationData() {
        let data = request.resource.data;
        return data.keys().hasAll(['id', 'name', 'capacity', 'stationType']) &&
               isValidString(data.name, 2, 100) &&
               data.capacity > 0 &&
               data.capacity <= 100;
      }
    }
    
    // ======================== Recipes Collection ========================
    
    match /recipes/{recipeId} {
      allow read: if isAuthenticated();
      
      allow create: if isKitchenStaff() && isValidRecipeData();
      
      allow update: if isKitchenStaff() && isValidRecipeData();
      
      allow delete: if isManagerOrAbove();
      
      function isValidRecipeData() {
        let data = request.resource.data;
        return data.keys().hasAll(['id', 'name', 'category', 'ingredients', 'instructions']) &&
               isValidString(data.name, 2, 200) &&
               data.ingredients.size() > 0 &&
               data.instructions.size() > 0;
      }
    }
    
    // ======================== Inventory Collection ========================
    
    match /inventory/{itemId} {
      allow read: if isAuthenticated() && isKitchenStaff();
      
      allow create: if isKitchenStaff() && isValidInventoryData();
      
      allow update: if isKitchenStaff() && isValidInventoryData();
      
      allow delete: if isManagerOrAbove();
      
      function isValidInventoryData() {
        let data = request.resource.data;
        return data.keys().hasAll(['id', 'name', 'quantity', 'unit']) &&
               isValidString(data.name, 2, 100) &&
               data.quantity >= 0;
      }
    }
    
    // ======================== Tables Collection ========================
    
    match /tables/{tableId} {
      allow read: if isAuthenticated();
      
      allow create: if isManagerOrAbove() && isValidTableData();
      
      allow update: if isAuthenticated() && isValidTableData();
      
      allow delete: if isManagerOrAbove();
      
      function isValidTableData() {
        let data = request.resource.data;
        return data.keys().hasAll(['id', 'number', 'capacity', 'status']) &&
               data.capacity > 0 &&
               data.capacity <= 20;
      }
    }
    
    // ======================== Kitchen Timers Collection ========================
    
    match /kitchen_timers/{timerId} {
      allow read: if isAuthenticated() && isKitchenStaff();
      
      allow create: if isKitchenStaff() && isValidTimerData();
      
      allow update: if isKitchenStaff() && isValidTimerData();
      
      allow delete: if isKitchenStaff();
      
      function isValidTimerData() {
        let data = request.resource.data;
        return data.keys().hasAll(['id', 'name', 'duration', 'status']) &&
               isValidString(data.name, 2, 100);
      }
    }
    
    // ======================== Food Safety Collection ========================
    
    match /food_safety/{docId} {
      // Nested collections
      match /temperature_logs/logs/{logId} {
        allow read: if isAuthenticated() && isKitchenStaff();
        allow create: if isKitchenStaff();
        allow update: if isKitchenStaff();
        allow delete: if isManagerOrAbove();
      }
      
      match /violations/{violationId} {
        allow read: if isAuthenticated() && isKitchenStaff();
        allow create: if isKitchenStaff();
        allow update: if isKitchenStaff();
        allow delete: if isManagerOrAbove();
      }
      
      match /haccp_control_points/{ccpId} {
        allow read: if isAuthenticated() && isKitchenStaff();
        allow create: if isManagerOrAbove();
        allow update: if isKitchenStaff();
        allow delete: if isManagerOrAbove();
      }
      
      match /audits/{auditId} {
        allow read: if isAuthenticated() && isKitchenStaff();
        allow create: if isManagerOrAbove();
        allow update: if isManagerOrAbove();
        allow delete: if isOwnerRole();
      }
    }
    
    // ======================== Cost Tracking Collection ========================
    
    match /cost_tracking/{docId} {
      match /costs/{costId} {
        allow read: if isManagerOrAbove();
        allow create: if isManagerOrAbove();
        allow update: if isManagerOrAbove();
        allow delete: if isOwnerRole();
      }
      
      match /cost_centers/{centerId} {
        allow read: if isManagerOrAbove();
        allow create: if isOwnerRole();
        allow update: if isManagerOrAbove();
        allow delete: if isOwnerRole();
      }
      
      match /profitability_reports/{reportId} {
        allow read: if isManagerOrAbove();
        allow create: if isManagerOrAbove();
        allow update: if isManagerOrAbove();
        allow delete: if isOwnerRole();
      }
      
      match /recipe_costs/{recipeCostId} {
        allow read: if isManagerOrAbove();
        allow create: if isManagerOrAbove();
        allow update: if isManagerOrAbove();
        allow delete: if isManagerOrAbove();
      }
    }
    
    // ======================== Analytics Collection ========================
    
    match /analytics/{docId} {
      match /metrics/{metricId} {
        allow read: if isManagerOrAbove();
        allow create: if isKitchenStaff();
        allow update: if isKitchenStaff();
        allow delete: if isManagerOrAbove();
      }
      
      match /performance_reports/{reportId} {
        allow read: if isManagerOrAbove();
        allow create: if isManagerOrAbove();
        allow update: if isManagerOrAbove();
        allow delete: if isOwnerRole();
      }
      
      match /order_analytics/{analyticsId} {
        allow read: if isManagerOrAbove();
        allow write: if isManagerOrAbove();
      }
      
      match /staff_performance/{performanceId} {
        allow read: if isManagerOrAbove();
        allow write: if isManagerOrAbove();
      }
      
      match /kitchen_efficiency/{efficiencyId} {
        allow read: if isManagerOrAbove();
        allow write: if isManagerOrAbove();
      }
    }
  }
}
```

### Deploy Rules
```powershell
firebase deploy --only firestore:rules
```

---

## 3. Secure Configuration Files

### Step 1: Add to `.gitignore`
```gitignore
# Firebase configuration files
google-services.json
GoogleService-Info.plist
firebase-debug.log
.firebase/

# Environment files
.env
.env.local
.env.production
```

### Step 2: Remove Sensitive Files from Git
```powershell
git rm --cached android/app/google-services.json
git rm --cached ios/Runner/GoogleService-Info.plist
git commit -m "Remove sensitive Firebase configuration files"
```

### Step 3: Use Environment Variables
Create `.env` file (add to .gitignore):
```env
FIREBASE_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=stacks-restaurant-management
FIREBASE_APP_ID=your_app_id_here
```

### Step 4: Use flutter_dotenv Package
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

### Step 5: Load Environment Variables
```dart
// lib/main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  
  final apiKey = dotenv.env['FIREBASE_API_KEY'];
  // Use in Firebase initialization
  
  runApp(MyApp());
}
```

### Step 6: Production Builds with --dart-define
```powershell
flutter build apk `
  --dart-define=FIREBASE_API_KEY=your_prod_key `
  --dart-define=FIREBASE_PROJECT_ID=your_prod_project `
  --release
```

---

## 4. Fix Unused Dependencies Warning

### File: `lib/application/use_cases/analytics/advanced_analytics_use_cases.dart`

Remove or use the unused repositories:

```dart
@injectable
class GenerateKitchenEfficiencyReportUseCase {
  final AnalyticsRepository _analyticsRepository;
  // Remove these if not used:
  // final OrderRepository _orderRepository;
  // final UserRepository _userRepository;

  GenerateKitchenEfficiencyReportUseCase({
    required AnalyticsRepository analyticsRepository,
    // Remove if not used:
    // required OrderRepository orderRepository,
    // required UserRepository userRepository,
  }) : _analyticsRepository = analyticsRepository;
       // Remove if not used
       // _orderRepository = orderRepository,
       // _userRepository = userRepository;

  // ... rest of implementation
}
```

### File: `lib/application/use_cases/food_safety/simplified_food_safety_use_cases.dart`

Same fix - remove unused `UserRepository` references.

---

## 5. Consolidate Duplicate Files

### Problem
Multiple versions of same use cases exist.

### Solution

#### Food Safety Use Cases
Choose ONE and delete others:
- Keep: `simplified_food_safety_use_cases.dart` (appears most complete)
- Delete: `food_safety_use_cases.dart` and `advanced_food_safety_use_cases.dart`

```powershell
Remove-Item "lib\application\use_cases\food_safety\food_safety_use_cases.dart"
Remove-Item "lib\application\use_cases\food_safety\advanced_food_safety_use_cases.dart"
```

#### Order BLoC
Choose ONE and delete the other:
- Keep: `order_bloc.dart` (more complete)
- Delete: `order_bloc_simple.dart`

```powershell
Remove-Item "lib\presentation\blocs\order\order_bloc_simple.dart"
```

Update any imports that reference deleted files.

---

## 6. Verification Steps

After completing all fixes:

### 1. Clean and Rebuild
```powershell
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Check for Errors
```powershell
flutter analyze
```

### 3. Run Tests
```powershell
flutter test
```

### 4. Test Firebase Connection
```powershell
flutter run
```

Then try:
1. Create a user (register)
2. Login
3. Create an order
4. View stations

### 5. Verify Firestore Rules
In Firebase Console:
1. Go to Firestore → Rules
2. Click "Rules Playground"
3. Test operations with different user roles

---

## Expected Results

After these fixes:
- ✅ All repositories use Firebase implementations
- ✅ No mock/stub repositories injected
- ✅ Firestore database secured with proper rules
- ✅ Configuration files not in git
- ✅ No compiler warnings for unused dependencies
- ✅ No duplicate files
- ✅ App ready for UI development

---

## Estimated Time

- Fix DI: 1-2 hours
- Firestore rules: 2-3 hours
- Secure configuration: 1 hour
- Fix warnings: 30 minutes
- Consolidate files: 30 minutes
- Testing: 1-2 hours

**Total: 1 day of focused work**

---

Next: After these critical fixes, proceed to UI development (see PRODUCTION_READINESS_REPORT.md Phase 1).
