## Version 1.1.0 - Biometric Authentication Update

### New Features
- **Biometric Authentication**:
  - Added fingerprint/face ID authentication as an alternative to PIN
  - Dedicated biometric authentication screen with modern design
  - Automatic authentication on app launch when enabled
  - Fallback to PIN authentication option
- **Enhanced Feedback**:
  - Visual fingerprint animation during authentication
  - Success and failure sound effects
  - Haptic feedback (vibration) for authentication events
- **Profile Settings**:
  - New toggle to enable/disable biometric authentication
  - Settings persist between app sessions

### Improvements
- **Security**:
  - PIN length strictly enforced to 4 digits
  - Improved PIN input screen with auto-focus and better spacing
- **User Experience**:
  - Multi-sensory feedback for authentication events
  - Clear status messages throughout authentication flow
  - Improved error handling

### Technical Changes
- Added dependencies: 
  - `local_auth: ^2.1.5`
  - `audioplayers: ^6.4.0`
  - `vibration: ^2.0.0`
- Created new screens:
  - `BiometricAuthScreen`
- Created utility class: `BiometricHelper`

### Notes
- Replace placeholder sound files in `assets/sounds/` with your preferred audio
- Test on various devices to ensure biometric compatibility
