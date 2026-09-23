package com.idsanna.rag;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import org.junit.Test;

public final class PublicConfigTest {
    @Test public void acceptsOnlyPublicHttpsConfiguration() {
        assertTrue(new PublicConfig("https://example.supabase.co", "public-key", "chat", "rag").isConfigured());
        assertFalse(new PublicConfig("http://example.supabase.co", "public-key", "chat", "rag").isConfigured());
        assertFalse(new PublicConfig("https://example.supabase.co", "", "chat", "rag").isConfigured());
    }
}
