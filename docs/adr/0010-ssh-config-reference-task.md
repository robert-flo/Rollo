# Use SSH config as the administrative reference task

The first canonical administrative task will be the legacy SSH configuration task. It is a safe reference task because it is user-level, reversible, and has concrete postconditions while still exercising ownership of a managed section inside a shared configuration file. Its contract will become the template for later administrative migrations, without assuming that every system task has the same risk or activation behavior.
