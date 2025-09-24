// User Mapper for Firebase Document to Domain Entity conversion
// Handles authentication data and user profile information

import '../../domain/entities/user.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';

/// Mapper for converting User entities to/from Firestore documents
class UserMapper {
  /// Convert User entity to Firestore document
  Map<String, dynamic> toFirestore(User user) {
    return {
      'id': user.id.value,
      'name': user.name,
      'email': user.email,
      'role': _roleToString(user.role),
      'isActive': user.isActive,
      'isAuthenticated': user.isAuthenticated,
      'sessionId': user.sessionId,
      'lastLoginAt': user.lastLoginAt?.dateTime.millisecondsSinceEpoch,
      'createdAt': user.createdAt.dateTime.millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Convert Firestore document to User entity
  User fromFirestore(Map<String, dynamic> data, String documentId) {
    return User(
      id: UserId(data['id'] as String),
      name: data['name'] as String,
      email: data['email'] as String,
      role: _stringToRole(data['role'] as String),
      isActive: data['isActive'] as bool? ?? true,
      isAuthenticated: data['isAuthenticated'] as bool? ?? false,
      sessionId: data['sessionId'] as String?,
      lastLoginAt: data['lastLoginAt'] != null
          ? Time.fromMillisecondsSinceEpoch(data['lastLoginAt'] as int)
          : null,
      createdAt: Time.fromMillisecondsSinceEpoch(data['createdAt'] as int),
    );
  }

  // Helper methods for enum conversions
  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.dishwasher:
        return 'dishwasher';
      case UserRole.prepCook:
        return 'prep_cook';
      case UserRole.lineCook:
        return 'line_cook';
      case UserRole.cook:
        return 'cook';
      case UserRole.cookSenior:
        return 'cook_senior';
      case UserRole.chefAssistant:
        return 'chef_assistant';
      case UserRole.sousChef:
        return 'sous_chef';
      case UserRole.chefHead:
        return 'chef_head';
      case UserRole.expediter:
        return 'expediter';
      case UserRole.kitchenManager:
        return 'kitchen_manager';
      case UserRole.generalManager:
        return 'general_manager';
      case UserRole.admin:
        return 'admin';
    }
  }

  UserRole _stringToRole(String role) {
    switch (role) {
      case 'dishwasher':
        return UserRole.dishwasher;
      case 'prep_cook':
        return UserRole.prepCook;
      case 'line_cook':
        return UserRole.lineCook;
      case 'cook':
        return UserRole.cook;
      case 'cook_senior':
        return UserRole.cookSenior;
      case 'chef_assistant':
        return UserRole.chefAssistant;
      case 'sous_chef':
        return UserRole.sousChef;
      case 'chef_head':
        return UserRole.chefHead;
      case 'expediter':
        return UserRole.expediter;
      case 'kitchen_manager':
        return UserRole.kitchenManager;
      case 'general_manager':
        return UserRole.generalManager;
      case 'admin':
        return UserRole.admin;
      default:
        throw ArgumentError('Unknown user role: $role');
    }
  }
}
