Please process Linear issues using the following procedure.

Use the MCP tool `mcp__linear-server__list_issues` to retrieve Todo issues.

Target the following statuses:

- Backlog
- Todo
- In Progress
- Blocked (only if the blocking factor can be resolved)

Sort the issues by priority in the following order:

Urgent → High → Medium → Low

Within the same priority, process them in the following status order:

In Progress → Todo → Backlog

Termination conditions:

- The Linear issue content has been understood
- The required implementation or investigation has been completed
- The required verification has been completed
- The changes have been reflected in GitHub
- The Linear status has been updated or a comment has been added
- It can be determined that continuing further will not produce any new results
- If the task failed, the cause, unfinished items, and next required work have been recorded in logs or Linear

Once any of the above completion or failure conditions can be determined, terminate the process.

Waiting for interaction, waiting for additional instructions, infinite loops, and waiting for confirmation to continue are prohibited.

When completed or failed, output a brief final result and terminate with `exit 0` or `exit 1`.
