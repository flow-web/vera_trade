/**
 * Capacitor bridge — native plugin integration for the PWA/native shell.
 * Only activates when running inside Capacitor (iOS/Android app).
 */

import { Capacitor } from '@capacitor/core';

const isNative = Capacitor.isNativePlatform();

export async function initCapacitor() {
  if (!isNative) return;

  await setupStatusBar();
  await setupKeyboard();
  await setupPushNotifications();

  console.log('[Capacitor] Native bridge initialized');
}

async function setupStatusBar() {
  try {
    const { StatusBar, Style } = await import('@capacitor/status-bar');
    await StatusBar.setStyle({ style: Style.Dark });
    await StatusBar.setBackgroundColor({ color: '#0F172A' });
  } catch (e) {
    console.warn('[Capacitor] StatusBar not available:', e);
  }
}

async function setupKeyboard() {
  try {
    const { Keyboard } = await import('@capacitor/keyboard');
    Keyboard.addListener('keyboardWillShow', () => {
      document.body.classList.add('keyboard-open');
    });
    Keyboard.addListener('keyboardWillHide', () => {
      document.body.classList.remove('keyboard-open');
    });
  } catch (e) {
    console.warn('[Capacitor] Keyboard not available:', e);
  }
}

async function setupPushNotifications() {
  try {
    const { PushNotifications } = await import('@capacitor/push-notifications');
    const permission = await PushNotifications.requestPermissions();
    if (permission.receive === 'granted') {
      await PushNotifications.register();
    }

    PushNotifications.addListener('registration', (token) => {
      console.log('[Capacitor] Push token:', token.value);
      // TODO: send token to Rails backend for push delivery
    });

    PushNotifications.addListener('pushNotificationReceived', (notification) => {
      console.log('[Capacitor] Push received:', notification);
    });

    PushNotifications.addListener('pushNotificationActionPerformed', (action) => {
      const path = action.notification?.data?.path;
      if (path) window.location.href = path;
    });
  } catch (e) {
    console.warn('[Capacitor] PushNotifications not available:', e);
  }
}

/**
 * Trigger haptic feedback — call from Stimulus controllers for tactile UX.
 */
export async function hapticImpact(style = 'Medium') {
  if (!isNative) return;
  try {
    const { Haptics, ImpactStyle } = await import('@capacitor/haptics');
    await Haptics.impact({ style: ImpactStyle[style] });
  } catch { /* noop on web */ }
}
