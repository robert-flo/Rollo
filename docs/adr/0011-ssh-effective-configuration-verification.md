# Verify SSH configuration through the effective parser

The SSH configuration reference task will verify both its managed section and the effective configuration resolved by `ssh -G ravnvm`. It will not open a network connection during verification. This catches syntactically valid but semantically misplaced directives while keeping the test deterministic and safe.
