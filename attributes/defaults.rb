#
# Cookbook Name:: mysqld
# Attributes:: default
#
# Copyright 2013, Chris Aumann
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Attribute that defines whether MariaDB or MySQL should be used
default['mysqld']['use_mariadb'] = true

# Default packages to install
default['mysqld']['mysql_packages'] = %w(mysql-server)
default['mysqld']['mariadb_packages'] = %w(mariadb-server)
default['mysqld']['mariadb_galera_packages'] = %w(mariadb-galera-server)

default['mysqld']['repository']['version'] = '10.1'
default['mysqld']['repository']['mirror'] = 'http://ftp.hosteurope.de/mirror/mariadb.org/repo'

# Figure out architecture and major platform version for yum repositories
default['mysqld']['repository']['arch'] = node['kernel']['machine'] =~ /x86_64/ ? 'amd64' : 'x86'

case node['platform']
when 'redhat'
  default['mysqld']['repository']['platform'] = "rhel#{node['platform_version'].to_i}"
when 'centos'
  default['mysqld']['repository']['platform'] = "centos#{node['platform_version'].to_i}"
when 'fedora'
  default['mysqld']['repository']['platform'] = "fedora#{node['platform_version'].to_i}"
end

case node['platform_family']
when 'debian'
  default['mysqld']['my.cnf_path'] = '/etc/mysql/my.cnf'
  default['mysqld']['service_name'] = 'mysql'
  default['mysqld']['includedir'] = true
when 'rhel'
  default['mysqld']['my.cnf_path'] = '/etc/my.cnf'
  default['mysqld']['service_name'] = 'mysqld'
  default['mysqld']['includedir'] = false
end

# Root password, not set if nil
default['mysqld']['root_password'] = nil

# Default authentication method
if node['platform_family'] == 'debian'
  # Use defaults-file on Debian
  default['mysqld']['auth'] = '--defaults-file=/etc/mysql/debian.cnf'
else
  if node['mysqld']['root_password']
    # Use root with password, if password was set in the attribute
    default['mysqld']['auth'] = "--user=root --password=#{node['mysqld']['root_password']}"
  else
    # Use root without a password
    default['mysqld']['auth'] = '--user=root'
  end
end

# Options, only set by default/ available on MariaDB
if node['mysqld']['use_mariadb']
  # Charset options are only set on MariaDB by default
  default['mysqld']['my.cnf']['client']['default-character-set'] = 'utf8mb4'
  default['mysqld']['my.cnf']['mysql']['default-character-set'] = 'utf8mb4'

  default['mysqld']['my.cnf']['mysqld']['character-set-server'] = 'utf8mb4'
  default['mysqld']['my.cnf']['mysqld']['collation-server'] = 'utf8mb4_general_ci'

  # This option is not present on mysql-5.7
  default['mysqld']['my.cnf']['mysqld_safe']['skip_log_error'] = true
end

default['mysqld']['my.cnf']['mysqld']['user'] = 'mysql'
default['mysqld']['my.cnf']['mysqld']['port'] = 3306
default['mysqld']['my.cnf']['mysqld']['lc-messages-dir'] = '/usr/share/mysql'
default['mysqld']['my.cnf']['mysqld']['skip-external-locking'] = true
default['mysqld']['my.cnf']['mysqld']['bind-address'] = '127.0.0.1'
default['mysqld']['my.cnf']['mysqld']['key_buffer_size'] = '16M'
default['mysqld']['my.cnf']['mysqld']['max_allowed_packet'] = '16M'
default['mysqld']['my.cnf']['mysqld']['thread_stack'] = '192K'
default['mysqld']['my.cnf']['mysqld']['thread_cache_size'] = 8
default['mysqld']['my.cnf']['mysqld']['query_cache_limit'] = '1M'
default['mysqld']['my.cnf']['mysqld']['query_cache_size'] = '16M'
default['mysqld']['my.cnf']['mysqld']['log_error'] = '/var/log/mysql/error.log'
default['mysqld']['my.cnf']['mysqld']['expire_logs_days'] = 10
default['mysqld']['my.cnf']['mysqld']['max_binlog_size'] = '100M'
default['mysqld']['my.cnf']['mysqld']['myisam-recover-options'] = 'BACKUP'

case node['platform_family']
when 'debian'
  default['mysqld']['my.cnf']['mysqld_safe']['socket'] = '/var/run/mysqld/mysqld.sock'
  default['mysqld']['my.cnf']['mysqld_safe']['nice'] = 0
  default['mysqld']['my.cnf']['mysqld_safe']['syslog'] = true

  default['mysqld']['my.cnf']['mysqld']['pid-file'] = '/var/run/mysqld/mysqld.pid'
  default['mysqld']['my.cnf']['mysqld']['socket'] = '/var/run/mysqld/mysqld.sock'
  default['mysqld']['my.cnf']['mysqld']['basedir'] = '/usr'
  default['mysqld']['my.cnf']['mysqld']['datadir'] = '/var/lib/mysql'
  default['mysqld']['my.cnf']['mysqld']['tmpdir'] = '/tmp'

when 'rhel'
  default['mysqld']['my.cnf']['mysqld_safe']['log-error'] = '/var/log/mysqld.log'
  default['mysqld']['my.cnf']['mysqld_safe']['pid-file'] = '/var/run/mysqld/mysqld.pid'

  default['mysqld']['my.cnf']['mysqld']['datadir'] = '/var/lib/mysql'
  default['mysqld']['my.cnf']['mysqld']['socket'] = '/var/lib/mysql/mysql.sock'
end
