Then(/^metasploit\-version should be development dependency with semantic version restriction in "(.*?)"$/) do |gemspec_path|
  check_file_content(
      gemspec_path,
      %r{spec\.add_development_dependency\s*(?<quote>'|")metasploit-version\k<quote>,\s*\k<quote>~> #{Metasploit::Version::Version::MAJOR}\.#{Metasploit::Version::Version::MINOR}\.#{Metasploit::Version::Version::PATCH}\k<quote>},
      true
  )
end