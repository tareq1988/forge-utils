# Forge Utils

Makes easy to download a full WordPress site from a [Forge](https://forge.laravel.com/), and restore the site, maybe to another server.

## Installation

Clone the repository to a suitable directory.

```sh
cd ~/Downloads
git clone git@github.com:tareq1988/forge-utils.git
```

### Symlink the scripts

To easily access the scripts from anywhere, you need to symlink the scripts.

Create the `~/bin` folder if not exists, and make sure you have the `~/bin` in your `$PATH`.

```bash
ln -s ~/Downloads/forge-utils/wp-backup-to-local.sh ~/bin/forge-wp-to-local

ln -s ~/Downloads/forge-utils/wp-restore-remote.sh ~/bin/forge-wp-restore
```

## Usage

### Backup

```bash
forge-wp-to-local <user> <ip> <domain>

# Example
forge-wp-to-local forge 174.138.25.55 wpexample.com
```

To take a backup, enter to your preffered directory in your machine. It'll create a directory automatically with your domain name inside it.

### Restore

```bash
forge-wp-restore <user> <ip> <domain>

# Example
forge-wp-restore forge 174.138.25.55 wpexample.com
```

To restore the backup, enter to your directory where your backup folder exists. It has to be the parent folder of your `wpexample.com` backup.
