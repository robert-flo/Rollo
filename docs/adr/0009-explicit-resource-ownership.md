# Require explicit resource ownership

Canonical administrative tasks must declare the resources they own and the boundaries within those resources that they may change. The runner will detect incompatible claims before apply, preserve unrelated configuration, and use declared dependencies for ordering. Numeric filenames remain organizational, not a substitute for dependency or conflict semantics.
