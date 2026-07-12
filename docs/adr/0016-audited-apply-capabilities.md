# Audit declared capabilities during apply

Administrative `apply()` operations will use declared capabilities and framework helpers where possible. Each mutation records its command or helper, arguments, target resource, privilege boundary, and result; opaque shell evaluation and undeclared elevation are prohibited. Task-specific shell hooks remain possible only when their capabilities, ownership, reversibility, and tests are explicit.
