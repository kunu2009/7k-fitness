# Fitness Tracker - API Documentation

This document outlines the API structure and integration points for connecting the Fitness Tracker app with a backend server.

## Base URL

```
https://api.fitnesstracker.com/v1
```

## Authentication

All endpoints require Bearer token authentication (after implementation):

```
Authorization: Bearer {token}
```

## Response Format

All responses follow this standard format:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {},
  "error": null,
  "timestamp": "2025-10-16T12:00:00Z"
}
```

## User Endpoints

### 1. User Registration
- **Endpoint**: `POST /auth/register`
- **Description**: Register a new user
- **Request Body**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "fullName": "John Doe",
  "age": 30,
  "height": 180,
  "weight": 75
}
```
- **Response**: User object with authentication token

### 2. User Login
- **Endpoint**: `POST /auth/login`
- **Description**: Authenticate user
- **Request Body**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```
- **Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "fullName": "John Doe"
  }
}
```

### 3. Get User Profile
- **Endpoint**: `GET /users/profile`
- **Authentication**: Required
- **Description**: Retrieve current user's profile
- **Response**:
```json
{
  "id": "user_123",
  "email": "user@example.com",
  "fullName": "John Doe",
  "age": 30,
  "height": 180,
  "weight": 75,
  "createdAt": "2025-01-15T10:00:00Z",
  "updatedAt": "2025-10-16T12:00:00Z"
}
```

### 4. Update User Profile
- **Endpoint**: `PUT /users/profile`
- **Authentication**: Required
- **Request Body**:
```json
{
  "fullName": "Jane Doe",
  "age": 31,
  "weight": 72
}
```

## Fitness Data Endpoints

### 1. Get Daily Data
- **Endpoint**: `GET /fitness/daily?date=2025-10-16`
- **Authentication**: Required
- **Description**: Get fitness data for a specific day
- **Response**:
```json
{
  "date": "2025-10-16",
  "calories": 1250,
  "steps": 5500,
  "waterGlasses": 8,
  "sleepHours": 7.5,
  "bpm": 86,
  "weight": 74
}
```

### 2. Create/Update Daily Data
- **Endpoint**: `POST /fitness/daily`
- **Authentication**: Required
- **Request Body**:
```json
{
  "date": "2025-10-16",
  "calories": 1250,
  "steps": 5500,
  "waterGlasses": 8,
  "sleepHours": 7.5,
  "bpm": 86,
  "weight": 74
}
```

### 3. Get Weekly Data
- **Endpoint**: `GET /fitness/weekly?week=43&year=2025`
- **Authentication**: Required
- **Response**:
```json
[
  {
    "date": "2025-10-13",
    "calories": 1200,
    "steps": 5200,
    "waterGlasses": 8,
    "sleepHours": 7,
    "bpm": 85,
    "weight": 75
  },
  // ... more days
]
```

### 4. Get Monthly Data
- **Endpoint**: `GET /fitness/monthly?month=10&year=2025`
- **Authentication**: Required
- **Response**: Array of daily fitness data for the month

## Workout Endpoints

### 1. Get All Workouts
- **Endpoint**: `GET /workouts`
- **Authentication**: Required
- **Query Parameters**:
  - `skip`: 0
  - `limit`: 20
  - `category`: "strength" (optional)
- **Response**:
```json
{
  "total": 50,
  "workouts": [
    {
      "id": "workout_123",
      "name": "Full Body Workout",
      "category": "strength",
      "duration": "30",
      "calories": 75.5,
      "exercises": [
        {
          "id": "exercise_1",
          "name": "Overhead Press",
          "reps": 15,
          "sets": 3
        }
      ],
      "createdAt": "2025-10-16T10:00:00Z"
    }
  ]
}
```

### 2. Create Workout
- **Endpoint**: `POST /workouts`
- **Authentication**: Required
- **Request Body**:
```json
{
  "name": "Full Body Workout",
  "category": "strength",
  "duration": "30",
  "calories": 75.5,
  "exercises": [
    {
      "name": "Overhead Press",
      "reps": 15,
      "sets": 3
    }
  ]
}
```

### 3. Update Workout
- **Endpoint**: `PUT /workouts/{workoutId}`
- **Authentication**: Required

### 4. Delete Workout
- **Endpoint**: `DELETE /workouts/{workoutId}`
- **Authentication**: Required

## Statistics Endpoints

### 1. Get Health Statistics
- **Endpoint**: `GET /statistics/health?period=week`
- **Authentication**: Required
- **Query Parameters**:
  - `period`: "day", "week", "month", "year"
- **Response**:
```json
{
  "averageCalories": 1250,
  "averageSteps": 5500,
  "averageSleep": 7.5,
  "averageBPM": 86,
  "weightTrend": "stable",
  "goalCompletionRate": 75
}
```

### 2. Get Calorie Statistics
- **Endpoint**: `GET /statistics/calories?period=week`
- **Response**:
```json
{
  "total": 8750,
  "average": 1250,
  "highest": 1500,
  "lowest": 900,
  "trend": "increasing"
}
```

### 3. Get Step Statistics
- **Endpoint**: `GET /statistics/steps?period=week`
- **Response**:
```json
{
  "total": 38500,
  "average": 5500,
  "highest": 8000,
  "lowest": 3000,
  "goalAchievementRate": 70
}
```

## Goals Endpoints

### 1. Get User Goals
- **Endpoint**: `GET /goals`
- **Authentication**: Required
- **Response**:
```json
[
  {
    "id": "goal_123",
    "type": "daily_steps",
    "target": 10000,
    "current": 5500,
    "deadline": "2025-12-31",
    "status": "in_progress"
  }
]
```

### 2. Create Goal
- **Endpoint**: `POST /goals`
- **Request Body**:
```json
{
  "type": "daily_steps",
  "target": 10000,
  "deadline": "2025-12-31"
}
```

## Social/Friend Endpoints

### 1. Get Friends List
- **Endpoint**: `GET /friends`
- **Authentication**: Required
- **Response**:
```json
[
  {
    "id": "friend_123",
    "fullName": "Peter Smith",
    "email": "peter@example.com",
    "avatar": "https://...",
    "status": "connected"
  }
]
```

### 2. Send Friend Request
- **Endpoint**: `POST /friends/request`
- **Request Body**:
```json
{
  "email": "friend@example.com"
}
```

### 3. Accept Friend Request
- **Endpoint**: `PUT /friends/request/{requestId}`
- **Request Body**:
```json
{
  "action": "accept"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Invalid request parameters",
  "error": {
    "code": "INVALID_INPUT",
    "details": ["Email is required", "Password must be at least 8 characters"]
  }
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Authentication required",
  "error": {
    "code": "UNAUTHORIZED",
    "details": "Invalid or expired token"
  }
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Resource not found",
  "error": {
    "code": "NOT_FOUND",
    "details": "User with ID 'user_123' not found"
  }
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Internal server error",
  "error": {
    "code": "SERVER_ERROR",
    "details": "Please try again later"
  }
}
```

## Rate Limiting

- **Rate Limit**: 100 requests per minute
- **Headers**:
  - `X-RateLimit-Limit`: 100
  - `X-RateLimit-Remaining`: 95
  - `X-RateLimit-Reset`: 1634412000

## Pagination

All list endpoints support pagination:

```
GET /endpoint?page=1&pageSize=20&sortBy=createdAt&sortOrder=desc
```

## WebSocket Events (Real-time Updates)

### Connect
```
wss://api.fitnesstracker.com/ws?token={token}
```

### Receive Events
```json
{
  "type": "fitness_update",
  "data": {
    "metric": "steps",
    "value": 5500
  }
}
```

## Implementation Notes

1. **Token Expiration**: Tokens expire after 24 hours
2. **Refresh Token**: Use refresh token endpoint to get new access token
3. **Data Sync**: Implement offline queue for failed requests
4. **Caching**: Cache responses locally for 5-10 minutes
5. **Error Handling**: Always handle network errors gracefully
6. **Security**: Never store sensitive data in SharedPreferences unencrypted

## Example API Client

```dart
class FitnessApiClient {
  static const String baseUrl = 'https://api.fitnesstracker.com/v1';
  
  Future<void> login(String email, String password) async {
    // Implementation
  }
  
  Future<FitnessData> getDailyData(DateTime date) async {
    // Implementation
  }
  
  Future<void> updateFitnessData(FitnessData data) async {
    // Implementation
  }
}
```

## Future Enhancements

- [ ] Push notifications
- [ ] Video streaming for workouts
- [ ] AI-powered workout recommendations
- [ ] Integration with wearable devices
- [ ] Social feed
- [ ] Achievement badges
- [ ] Leaderboards

---

**API Version**: 1.0
**Last Updated**: October 2025
