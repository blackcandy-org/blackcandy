json.version do
  json.major BlackCandy::Version::MAJOR
  json.minor BlackCandy::Version::MINOR
  json.patch BlackCandy::Version::PATCH
  json.pre BlackCandy::Version::PRE
end

json.min_app_version do
  json.major BlackCandy::MinAppVersion::MAJOR
  json.minor BlackCandy::MinAppVersion::MINOR
  json.patch BlackCandy::MinAppVersion::PATCH
end
