# mmw-micro

A static micro site storm model.

### Requirements

* Vagrant 1.8+
* VirtualBox 4.3+
* Ansible 2.1+

### Quick setup

Clone the project, `cd` into the directory, then run `./scripts/setup.sh` to create the Vagrant VM and install npm dependencies.

To start the server during development:
```bash
$ vagrant ssh
$ ./scripts/server.sh
```

### Testing

To run linters and tests:

```bash
$ vagrant ssh
$ ./scripts/test.sh
```

### Scripts

| Name      | Description                                                   |
| --------- | ------------------------------------------------------------- |
| `bundle.sh`  | Bundle application assets into distribution directory      |
| `cibuild.sh` | Build application for staging or release                   |
| `server.sh`  | Run the development server                                 |
| `setup.sh`   | Bring up the VM, then install Node.js dependencies         |
| `infra.sh`   | Execute Terraform subcommands with remote state management |
| `test.sh`    | Run linters and tests                                      |
| `update.sh`  | Install local Node.js dependencies and bundle assets       |
