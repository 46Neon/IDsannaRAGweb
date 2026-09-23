package com.idsanna.rag;

import android.accessibilityservice.AccessibilityService;
import android.view.accessibility.AccessibilityEvent;

/**
 * Optional browser-only assistive bridge.
 *
 * The service observes only allowlisted browser packages. It does not control
 * messaging, banking, system settings, or arbitrary applications. Any future
 * click/navigation action must be initiated by the user and pass the same policy.
 */
public final class IdsannaAccessibilityService extends AccessibilityService {
    @Override public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event == null || !BrowserAutomationPolicy.isAllowedBrowser(
                event.getPackageName() == null ? null : event.getPackageName().toString())) {
            return;
        }
        // Browser event handling is intentionally read-only until the user
        // explicitly enables a single approved action in the app UI.
    }

    @Override public void onInterrupt() {
        // Cancels the current assistive session; no autonomous action is queued.
    }
}
