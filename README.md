# Database User Management Suite (dbusermgr)

A command-line tool for managing database users, designed with extensibility for multiple database types. Currently supports PostgreSQL via Docker container interaction.

## Overview

The `dbusermgr` tool provides a unified interface to perform common database user management tasks such as creating users, deleting users, listing users, altering users, and managing privileges. It operates by dispatching commands to database-specific handlers.

This suite is designed to interact with database instances running in Docker containers, identifying target containers by their base name.

## Project Structure

```
your-project-name/  (e.g., guepard-dbusermgr)
├── bin/
│   └── dbusermgr              # Main CLI executable script
├── lib/
│   └── dbusermgr/
│       ├── utils.sh           # Shared utility functions (logging, password prompt)
│       └── handlers/
│           └── postgres_handler.sh # Logic specific to PostgreSQL user management
├── config/
│   └── dbusermgr.conf.example # Example configuration file
├── systemd/
│   └── dbusermgr-task@.service.example # Example systemd template unit for running tasks
├── install.sh                 # Installation script to deploy the tool on a system
├── README.md                  # This file
└── .gitignore                 # Specifies intentionally untracked files for Git
```

## Features

* **Modular Design**: Easily extendable to support other database systems (e.g., MySQL, MongoDB) by adding new handler scripts.
* **Docker Integration**: Targets database instances running in Docker containers.
* **Command-Line Interface**: Clear and consistent CLI for all operations.
* **Password Management**: Secure password prompting and support for environment variable-based password provision.
* **Logging**: Operations are logged for auditing and debugging.
* **Systemd Integration (Optional)**: Includes an example systemd template unit for running `dbusermgr` commands as managed one-shot tasks.

## Prerequisites

* Bash (v4.0 or later recommended)
* Docker CLI installed and accessible by the user running `dbusermgr`.
* The target database client tools installed *within the Docker container* being managed (e.g., `psql` for PostgreSQL containers).

## Installation

1.  Clone your repository (or ensure files are present).
2.  Navigate to your project directory (e.g., `guepard-dbusermgr`).
3.  Make the installation script executable: `chmod +x install.sh`
4.  Run the installation script with root privileges: `sudo ./install.sh`

The script will install:
    * `dbusermgr` to `/usr/local/sbin/`
    * Helper scripts (`utils.sh`, handlers) to `/usr/local/lib/dbusermgr/`
    * Example configuration to `/etc/dbusermgr/dbusermgr.conf.example` (you'll need to copy and customize it to `dbusermgr.conf`).
    * Log directory `/var/log/dbusermgr/`.
    * Example systemd unit to `/etc/systemd/system/`.

## Configuration

After installation, copy the example configuration file:
```bash
sudo cp /etc/dbusermgr/dbusermgr.conf.example /etc/dbusermgr/dbusermgr.conf
```
Edit `/etc/dbusermgr/dbusermgr.conf` to set your desired `LOG_FILE` path and `LOG_LEVEL` (DEBUG, INFO, WARN, ERROR).

## Usage

The main command is `dbusermgr`. Run it with `sudo` if it requires Docker access that your current user doesn't have.

**Global Options:**
* `--db-type <type>`: Required. E.g., `postgres`.
* `--container-name <base_name>`: Required. Base name of the target Docker container. The script will find the full running container name.
* `--db-admin-user <user>`: Required. Admin user for database operations (e.g., `postgres`).
* `--db-admin-pass <pass>`: Optional. Password for the admin user.
* `--ask-admin-password`: Optional. Force prompt for the admin user's password.
* `--db-name <name>`: Optional. Database to connect to for operations (defaults vary by DB type, e.g., `postgres` for PostgreSQL).
* `--help, -h`: Show help.

**Environment Variable for Admin Password:**
You can set `DBMGR_ADMIN_PASS` to provide the admin password instead of using command-line options or interactive prompts.

**Example Commands (PostgreSQL):**

* **List Users:**
    ```bash
    sudo dbusermgr --db-type postgres --container-name my-pg-compute --db-admin-user postgres list-users
    ```

* **Create User (with password prompt for the new user):**
    ```bash
    sudo dbusermgr --db-type postgres --container-name my-pg-compute --db-admin-user postgres create-user --username newuser --ask-password
    ```

* **Create User (providing new user's password directly):**
    ```bash
    sudo dbusermgr --db-type postgres --container-name my-pg-compute --db-admin-user postgres create-user --username newuser --password "Str0ngP@ss!"
    ```

## Extending for Other Databases

1.  Create a new handler script in `lib/dbusermgr/handlers/` (e.g., `mysql_handler.sh`).
2.  Implement the required functions within this handler.
3.  Update the `case` statement in the main `dbusermgr` script (in `bin/`).
4.  Update the `install.sh` script to copy your new handler.

## Contributing

Contributions, issues, and feature requests are welcome.

## License

MIT
