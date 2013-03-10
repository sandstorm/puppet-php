require 'puppet/util/execution'

Puppet::Type.type(:php_version).provide(:php_source) do
  include Puppet::Util::Execution
  desc "Provides PHP versions compiled from the official source code repository"

  def create
    install "#{@resource[:version]}"
  end

  def destroy
    FileUtils.rm_rf("#{@resource[:phpenv_root]}/versions/#{@resource[:version]}")
  end

  def exists?
    File.directory?("#{@resource[:phpenv_root]}/versions/#{@resource[:version]}")
  end

  def install(version)

    # First check we have a cached copy of the source repository, with this version tag
    confirm_cached_source(version)

    raise "method 'install' not yet implemented. version #{version}"
  end


  private

  # Check that the cached repository is in place, and the version requested exists
  # as a tag in the repository
  #
  def confirm_cached_source(version)
    raise "Source repository is not present" if !File.directory?("#{@resource[:phpenv_root]}/php-src/.git")

    # Check if tag exists in current repo, if not fetch & recheck
    if !version_present_in_cache?(version)
      update_repository
      raise "Version #{version} not found in PHP source" if !version_present_in_cache?(version)
    end
  end

  # Update and fetch new tags from the remote repository
  #
  def update_repository
    %x( cd #{@resource[:phpenv_root]}/php-src/ && git fetch --tags )
  end

  # Check for a specific version within the PHP source repository
  #
  def version_present_in_cache?(version)
    tag = %x( cd #{@resource[:phpenv_root]}/php-src/ && git tag -l "php-#{version}" )
    tag.strip == "php-#{version}"
  end

end