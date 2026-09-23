package com.idsanna.rag.actions;

/** Safety policy: no external-app automation without explicit user approval. */
public final class ActionPolicy {
    private boolean simulation = true;
    private boolean stopped = false;
    public boolean isSimulation() { return simulation; }
    public void setSimulation(boolean enabled) { simulation = enabled; }
    public void stop() { stopped = true; }
    public void resetAfterExplicitUserAction() { stopped = false; }
    public boolean canExecuteExternalAction(boolean userConfirmed, boolean allowlisted) {
        return !simulation && !stopped && userConfirmed && allowlisted;
    }
}
