import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'fr.veratrade.app',
  appName: 'Vera Trade',
  webDir: 'public',

  // Point to the live site — the native shell wraps the web app
  server: {
    url: 'https://veratrade.fr',
    cleartext: false,
  },

  ios: {
    scheme: 'VeraTrade',
    contentInset: 'always',
    preferredContentMode: 'mobile',
    backgroundColor: '#0F172A',
  },

  android: {
    backgroundColor: '#0F172A',
    allowMixedContent: false,
    captureInput: true,
    webContentsDebuggingEnabled: false,
  },

  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      launchAutoHide: true,
      backgroundColor: '#0F172A',
      showSpinner: false,
      androidScaleType: 'CENTER_CROP',
      splashFullScreen: true,
      splashImmersive: true,
    },
    StatusBar: {
      style: 'DARK',
      backgroundColor: '#0F172A',
    },
    Keyboard: {
      resize: 'body',
      resizeOnFullScreen: true,
    },
    PushNotifications: {
      presentationOptions: ['badge', 'sound', 'alert'],
    },
  },
};

export default config;
