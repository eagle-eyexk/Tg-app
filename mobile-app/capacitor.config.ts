import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.tiligo.tilgo',
  appName: 'TiliGo',
  webDir: 'www',
  server: {
    url: 'https://tiligo-delivery-flow.base44.app',
    cleartext: false,
  },
  ios: {
    contentInset: 'automatic',
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 1500,
      backgroundColor: '#39ff6b',
      showSpinner: false,
    },
  },
};

export default config;
