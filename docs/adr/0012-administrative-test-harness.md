# Build a separate administrative test harness

Administrative tasks will be validated through a dedicated `test-task-admin.sh` harness rather than extending the CLI/package Docker tester until it becomes ambiguous. The harness will default to isolated fixtures, support an explicitly authorized host mode with backups, and reserve VM execution for a future adapter. The first reference implementation is the SSH configuration task.
