# Installs a php extension for a specific version of php.
#
# Usage:
#
#     php::extension::yaml { 'yaml for 5.5.5':
#       php     => '5.5.5',
#       version => '1.1.1'
#     }
#
define php::extension::yaml(
  $php,
  $version = '1.1.1'
) {
  require php::config
  # Require php version eg. php::5_4_10
  # This will compile, install and set up config dirs if not present
  require join(['php', join(split($php, '[.]'), '_')], '::')
  

  $extension = 'yaml'
  $package_name = "yaml-${version}"
  $url = "http://pecl.php.net/get/yaml-${version}.tgz"

  # Final module install path
  $module_path = "${php::config::root}/versions/${php}/modules/${extension}.so"

  package { 'libyaml': }
  ->
  php_extension { $name:
    extension      => $extension,
    version        => $version,
    package_name   => $package_name,
    package_url    => $url,
    homebrew_path  => $boxen::config::homebrewdir,
    phpenv_root    => $php::config::root,
    php_version    => $php,
    cache_dir      => $php::config::extensioncachedir,
  }

  # Add config file once extension is installed

  file { "${php::config::configdir}/${php}/conf.d/${extension}.ini":
    content => template('php/extensions/generic.ini.erb'),
    require => Php_extension[$name],
  }
}
