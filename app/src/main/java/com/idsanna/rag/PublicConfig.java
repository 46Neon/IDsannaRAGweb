package com.idsanna.rag;

/** Public configuration only. Private provider keys must never be bundled in an APK. */
public record PublicConfig(String supabaseUrl, String publishableKey, String chatFunction, String ragFunction) {
    public boolean isConfigured() { return supabaseUrl != null && supabaseUrl.startsWith("https://") && publishableKey != null && !publishableKey.isBlank(); }
}
