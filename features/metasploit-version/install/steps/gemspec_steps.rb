Then(/^metasploit\-version should be development dependency with semantic version restriction in "(.*?)"$/) do |gemspec_path|
  version_requirement = if defined? Metasploit::Version::Version::PRERELEASE
    # require exactly this pre-release in case there are multiple prereleases for the same
    # version number due to parallel branches.
    "= #{Metasploit::Version::GEM_VERSION}"
  elsif Metasploit::Version::Version::MAJOR < 1
    # can only allow the PATCH to wiggle pre-1.0.0
    "~> #{Metasploit::Version::Version::MAJOR}.#{Metasploit::Version::Version::MINOR}.#{Metasploit::Version::Version::PATCH}"
  else
    # can allow the MINOR to wiggle 1.0.0+
    "~> #{Metasploit::Version::Version::MAJOR}.#{Metasploit::Version::Version::MINOR}"
  end

  check_file_content(
      gemspec_path,
      %r{spec\.add_development_dependency\s*(?<quote>'|")metasploit-version\k<quote>,\s*\k<quote>#{version_requirement}\k<quote>},
      true
  )
end