# INF-001: Backend Server Dockerization Build and Run
**Module:** Backend Architecture
**Priority:** High

## Objective
Verify that the backend server initializes correctly within its Docker container and properly exposes the local port.

## Pre-conditions
* [ ] The Docker daemon is running on the local machine.
* [ ] The `.env` file is properly configured with the correct local database and environment variables.

## Test Steps
1. Open the terminal and navigate to the project root directory.
2. Run the command `docker build -t sphere-backend .` to build the container image.
3. Run the command `docker run -p 8080:8080 sphere-backend` to start the container.
4. Observe the terminal output logs for the server initialization message.

## Expected Result
The Docker image builds successfully without errors. The container spins up, and the terminal logs explicitly confirm the server is initialized and listening on the expected port.

---
## Execution Record
*Leave this section blank until you actually run the test.*
**Status:** [ ] Pass | [ ] Fail | [ ] Blocked
**Date Tested:** YYYY-MM-DD
**Tested Version/Commit:** [Commit Hash or Version Number]
**Actual Result / Notes:** > [Record what actually happened here. If it failed, link to the bug issue.]