/**
 * Native Bridge JavaScript Interface
 * This file should be injected into the web app to enable communication with native Swift code
 */

(function() {
  // Create global namespace
  if (!window.NativeMessage) {
    window.NativeMessage = {};
  }

  // Store pending responses
  const pendingResponses = new Map();
  let messageId = 0;

  /**
   * Call a native feature from JavaScript
   * @param {string} method - The native method to call
   * @param {object} data - Optional data to send
   * @returns {Promise} Resolves with the native response
   */
  window.NativeMessage.call = function(method, data = {}) {
    return new Promise((resolve, reject) => {
      const id = String(++messageId);
      const timeout = setTimeout(() => {
        pendingResponses.delete(id);
        reject(new Error(`Native call to ${method} timed out`));
      }, 30000); // 30 second timeout

      pendingResponses.set(id, { resolve, reject, timeout });

      const messageData = { ...data, id };

      try {
        // Use webkit message handler if available (iOS 8.0+)
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers[method]) {
          window.webkit.messageHandlers[method].postMessage(messageData);
        } else {
          reject(new Error(`Native method ${method} not available`));
        }
      } catch (error) {
        pendingResponses.delete(id);
        reject(error);
      }
    });
  };

  /**
   * Handle native messages sent to JavaScript
   * @param {string} method - The method name
   * @param {object} data - The response data
   */
  window.NativeMessage.handleNativeMessage = function(method, data) {
    console.log('[NativeBridge] Received native message:', method, data);

    // Dispatch event for listening components
    const event = new CustomEvent('nativeMessage', {
      detail: { method, data }
    });
    window.dispatchEvent(event);

    // Call specific handlers
    if (typeof window.NativeMessage[`on${capitalize(method)}`] === 'function') {
      window.NativeMessage[`on${capitalize(method)}`](data);
    }
  };

  /**
   * Handle native responses to method calls
   */
  window.NativeMessage.onNativeResponse = function(data) {
    const { id, data: responseData } = data;
    if (pendingResponses.has(id)) {
      const { resolve, timeout } = pendingResponses.get(id);
      clearTimeout(timeout);
      resolve(responseData);
      pendingResponses.delete(id);
    }
  };

  /**
   * Handle native errors
   */
  window.NativeMessage.onNativeError = function(data) {
    const { id, error } = data;
    if (pendingResponses.has(id)) {
      const { reject, timeout } = pendingResponses.get(id);
      clearTimeout(timeout);
      reject(new Error(error));
      pendingResponses.delete(id);
    }
  };

  /**
   * Handle deep links from native code
   */
  window.NativeMessage.onDeepLink = function(data) {
    console.log('[NativeBridge] Deep link received:', data);
    
    // Dispatch event for components to listen to
    const event = new CustomEvent('deepLink', {
      detail: data
    });
    window.dispatchEvent(event);

    // Optional: Navigate based on screen in deep link
    if (data.screen) {
      if (typeof window.navigateToScreen === 'function') {
        window.navigateToScreen(data.screen, data.params);
      }
    }
  };

  // Convenience methods for common native features
  
  /**
   * Request camera permission
   */
  window.NativeMessage.requestCameraPermission = async function() {
    try {
      const result = await window.NativeMessage.call('requestCameraPermission', {});
      return result.granted || false;
    } catch (error) {
      console.error('[NativeBridge] Camera permission error:', error);
      return false;
    }
  };

  /**
   * Request location permission
   */
  window.NativeMessage.requestLocationPermission = async function() {
    try {
      const result = await window.NativeMessage.call('requestLocationPermission', {});
      return result.granted || false;
    } catch (error) {
      console.error('[NativeBridge] Location permission error:', error);
      return false;
    }
  };

  /**
   * Show a native notification
   */
  window.NativeMessage.showNotification = async function(title, message) {
    try {
      const result = await window.NativeMessage.call('showNativeNotification', {
        title,
        message
      });
      return result.success || false;
    } catch (error) {
      console.error('[NativeBridge] Show notification error:', error);
      return false;
    }
  };

  /**
   * Get device information
   */
  window.NativeMessage.getDeviceInfo = async function() {
    try {
      return await window.NativeMessage.call('getDeviceInfo', {});
    } catch (error) {
      console.error('[NativeBridge] Get device info error:', error);
      return null;
    }
  };

  /**
   * Request biometric authentication
   */
  window.NativeMessage.authenticateBiometric = async function() {
    try {
      const result = await window.NativeMessage.call('requestBiometric', {});
      return result.authenticated || false;
    } catch (error) {
      console.error('[NativeBridge] Biometric auth error:', error);
      return false;
    }
  };

  /**
   * Store value securely in Keychain
   */
  window.NativeMessage.storeSecurely = async function(key, value) {
    try {
      const result = await window.NativeMessage.call('storeSecurely', {
        key,
        value
      });
      return result.success || false;
    } catch (error) {
      console.error('[NativeBridge] Store secure error:', error);
      return false;
    }
  };

  /**
   * Retrieve value from Keychain
   */
  window.NativeMessage.retrieveSecure = async function(key) {
    try {
      const result = await window.NativeMessage.call('retrieveSecure', {
        key
      });
      return result.value || null;
    } catch (error) {
      console.error('[NativeBridge] Retrieve secure error:', error);
      return null;
    }
  };

  // Utility function
  function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }

  // Log that bridge is ready
  console.log('[NativeBridge] JavaScript bridge initialized successfully');
  
  // Dispatch ready event
  window.dispatchEvent(new CustomEvent('nativeBridgeReady'));
})();
