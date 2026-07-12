# Normalize administrative outcomes

Administrative tasks will report more than binary success or failure. The runner will distinguish active verification, applied changes awaiting an activation boundary, partial verification, failure, unsupported verification, and work that did not run. These states make reconciliation honest when a reboot, relogin, daemon reload, or external system condition separates a successful write from an effective configuration.
