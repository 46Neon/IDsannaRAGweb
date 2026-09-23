package com.idsanna.rag;

import android.net.Uri;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

/** Safety boundary for optional browser assistance. */
public final class BrowserAutomationPolicy {
    private static final Set<String> BROWSER_PACKAGES = new HashSet<>(Arrays.asList(
            "com.android.chrome",
            "org.mozilla.firefox",
            "com.microsoft.emmx",
            "com.brave.browser",
            "com.opera.browser"
    ));

    private BrowserAutomationPolicy() {}

    public static boolean isAllowedBrowser(String packageName) {
        return packageName != null && BROWSER_PACKAGES.contains(packageName);
    }

    /**
     * Rejects opaque or non-web targets. A production allowlist may be supplied
     * by the signed user configuration; no arbitrary application package is accepted.
     */
    public static boolean isAllowedWebUri(Uri uri) {
        if (uri == null) return false;
        String scheme = uri.getScheme();
        return ("https".equalsIgnoreCase(scheme) || "http".equalsIgnoreCase(scheme))
                && uri.getHost() != null
                && !uri.getHost().isEmpty();
    }

    public static String normalizedHost(Uri uri) {
        return uri == null || uri.getHost() == null
                ? "" : uri.getHost().toLowerCase(Locale.ROOT);
    }
}
