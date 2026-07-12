# Report activation boundaries explicitly

Administrative tasks may apply their changes successfully without those changes becoming effective immediately. The suite will distinguish applied state from active verified state, report activation boundaries such as reboot, relogin, daemon reload, or reconnection, and produce a reconciliation report describing attempted, verified, pending, failed, and unsupported outcomes. This prevents a technically successful write from being presented as a fully active system configuration.
