import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:stacks/presentation/blocs/auth/auth_bloc.dart';
import 'package:stacks/presentation/blocs/auth/auth_event.dart';
import 'package:stacks/presentation/blocs/auth/auth_state.dart';
import 'package:stacks/application/use_cases/user/user_use_cases.dart';
import 'package:stacks/application/use_cases/user/authenticate_user_use_case.dart';
import 'package:stacks/application/dtos/user_dtos.dart';
import 'package:stacks/domain/entities/user.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/failures/failures.dart';

// Generate mocks for use cases
@GenerateMocks([
  AuthenticateUserUseCase,
  RegisterUserUseCase,
  LogoutUserUseCase,
  UpdateUserUseCase,
  IsSessionValidUseCase,
])
import 'auth_bloc_test.mocks.dart';

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockAuthenticateUserUseCase mockAuthenticateUserUseCase;
    late MockRegisterUserUseCase mockRegisterUserUseCase;
    late MockLogoutUserUseCase mockLogoutUserUseCase;
    late MockUpdateUserUseCase mockUpdateUserUseCase;
    late MockIsSessionValidUseCase mockIsSessionValidUseCase;

    setUp(() {
      mockAuthenticateUserUseCase = MockAuthenticateUserUseCase();
      mockRegisterUserUseCase = MockRegisterUserUseCase();
      mockLogoutUserUseCase = MockLogoutUserUseCase();
      mockUpdateUserUseCase = MockUpdateUserUseCase();
      mockIsSessionValidUseCase = MockIsSessionValidUseCase();

      authBloc = AuthBloc(
        authenticateUserUseCase: mockAuthenticateUserUseCase,
        registerUserUseCase: mockRegisterUserUseCase,
        logoutUserUseCase: mockLogoutUserUseCase,
        isSessionValidUseCase: mockIsSessionValidUseCase,
        updateUserUseCase: mockUpdateUserUseCase,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitialState', () {
      expect(authBloc.state, isA<AuthInitialState>());
    });

    group('LoginEvent', () {
      const email = 'test@example.com';
      const password = 'password123';

      final testUser = User(
        id: UserId('test-id'),
        email: email,
        name: 'Test User',
        role: UserRole.lineCook,
        createdAt: Time.now(),
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoadingState, AuthenticatedState] when login is successful',
        build: () {
          when(
            mockAuthenticateUserUseCase.execute(any),
          ).thenAnswer((_) async => Right(testUser));
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(const LoginEvent(email: email, password: password)),
        expect: () => [
          isA<AuthLoadingState>(),
          isA<AuthenticatedState>().having(
            (state) => state.user.email,
            'user email',
            email,
          ),
        ],
        verify: (_) {
          verify(
            mockAuthenticateUserUseCase.execute(
              const AuthenticateUserDto(email: email, password: password),
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoadingState, AuthErrorState] when login fails',
        build: () {
          when(mockAuthenticateUserUseCase.execute(any)).thenAnswer(
            (_) async => const Left(ValidationFailure('Invalid credentials')),
          );
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(const LoginEvent(email: email, password: password)),
        expect: () => [
          isA<AuthLoadingState>(),
          isA<AuthErrorState>().having(
            (state) => state.message,
            'error message',
            contains('credentials'),
          ),
        ],
      );
    });

    group('RegisterEvent', () {
      const email = 'newuser@example.com';
      const password = 'password123';
      const name = 'New User';
      const role = 'lineCook';

      final testUser = User(
        id: UserId('new-user-id'),
        email: email,
        name: name,
        role: UserRole.lineCook,
        createdAt: Time.now(),
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoadingState, RegistrationSuccessState] when registration is successful',
        build: () {
          when(
            mockRegisterUserUseCase.execute(any),
          ).thenAnswer((_) async => Right(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const RegisterEvent(
            email: email,
            password: password,
            name: name,
            role: role,
          ),
        ),
        expect: () => [
          isA<AuthLoadingState>(),
          isA<RegistrationSuccessState>().having(
            (state) => state.user?.email,
            'user email',
            email,
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoadingState, AuthErrorState] when registration fails',
        build: () {
          when(mockRegisterUserUseCase.execute(any)).thenAnswer(
            (_) async => const Left(ValidationFailure('Email already exists')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const RegisterEvent(
            email: email,
            password: password,
            name: name,
            role: role,
          ),
        ),
        expect: () => [
          isA<AuthLoadingState>(),
          isA<AuthErrorState>().having(
            (state) => state.message,
            'error message',
            contains('exists'),
          ),
        ],
      );
    });

    group('LogoutEvent', () {
      final authenticatedUser = User(
        id: UserId('authenticated-user'),
        email: 'authenticated@example.com',
        name: 'Authenticated User',
        role: UserRole.cook,
        createdAt: Time.now(),
        isAuthenticated: true,
        sessionId: 'session-123',
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoadingState, UnauthenticatedState] when logout is successful',
        build: () {
          when(
            mockLogoutUserUseCase.call(any),
          ).thenAnswer((_) async => Right(authenticatedUser.logout()));
          return authBloc;
        },
        seed: () => AuthenticatedState(user: authenticatedUser),
        act: (bloc) => bloc.add(const LogoutEvent()),
        expect: () => [isA<AuthLoadingState>(), isA<UnauthenticatedState>()],
      );
    });

    group('convenience getters', () {
      final authenticatedUser = User(
        id: UserId('test-user'),
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.sousChef,
        createdAt: Time.now(),
        isAuthenticated: true,
      );

      test('isAuthenticated returns true when user is authenticated', () {
        authBloc.emit(AuthenticatedState(user: authenticatedUser));
        expect(authBloc.isAuthenticated, isTrue);
      });

      test('isAuthenticated returns false when user is not authenticated', () {
        authBloc.emit(const UnauthenticatedState());
        expect(authBloc.isAuthenticated, isFalse);
      });

      test('currentUser returns user when authenticated', () {
        authBloc.emit(AuthenticatedState(user: authenticatedUser));
        expect(authBloc.currentUser, equals(authenticatedUser));
      });

      test('currentUser returns null when not authenticated', () {
        authBloc.emit(const UnauthenticatedState());
        expect(authBloc.currentUser, isNull);
      });

      test('isChef returns true for chef roles', () {
        authBloc.emit(AuthenticatedState(user: authenticatedUser)); // sousChef
        expect(authBloc.isChef, isTrue);
      });

      test('hasPermission works correctly', () {
        authBloc.emit(AuthenticatedState(user: authenticatedUser));
        // Assuming sousChef has manageUsers permission
        expect(authBloc.hasPermission(Permission.manageUsers), isTrue);
        // Assuming sousChef doesn't have system admin permissions
        expect(authBloc.hasPermission(Permission.manageSystem), isFalse);
      });
    });
  });
}
