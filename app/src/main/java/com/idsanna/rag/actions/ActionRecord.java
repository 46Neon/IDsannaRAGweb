package com.idsanna.rag.actions;

import java.time.Instant;

/** Immutable audit record; never stores passwords, tokens or document contents. */
public record ActionRecord(String actionId, String kind, String target, boolean simulated, Instant createdAt) {}
