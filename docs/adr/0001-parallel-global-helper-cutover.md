---
status: accepted
---

# Parallel global helper cutover

`Scripts/global_fn.sh` remains the untouched baseline while `Scripts/global_fn_new.sh` is built by combining its public behavior with the visual and structural design of `Configs/.local/bin/global_fn.sh`. The candidate must pass isolated API checks and real side-by-side copy-flow validation before replacing `Scripts/global_fn.sh`; the baseline then becomes `Scripts/global_fn_legacy.sh` for edge-case testing, because roughly forty consumers depend on the existing path and must remain unchanged.

## Consequences

- Consumer scripts keep sourcing `${scrDir}/global_fn.sh` without migration.
- Equivalence is semantic and filesystem-based, not byte-for-byte output equality.
- Visual output may modernize while public names, arguments, exports, statuses, and effects remain compatible.
