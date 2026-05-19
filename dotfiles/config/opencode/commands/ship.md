---
description: Push the current branch and open a PR on GitHub. Runs commit mode first if there are uncommitted changes.
agent: shipper
---

Run ship mode. Ticket ID (if provided): $ARGUMENTS

If there are uncommitted changes, run commit mode first (using the same ticket ID), then push and PR.
