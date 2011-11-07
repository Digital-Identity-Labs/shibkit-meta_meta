
default_source_object = Shibkit::MetaMeta::Source.new

TYPICAL_SOURCE_OBJECT = Shibkit::MetaMeta::Source.new do |s|
  s.name_uri   = ""
  s.name       = "Unnown"
  s.refresh_delay = 86400
  s.display_name = "Unknown"
  s.type      = "federation"
  s.countries = []
  s.metadata_source = nil
  s.certificate_source = nil
  s.fingerprint = nil
  s.refeds_url = nil
  s.homepage  = nil
  s.languages = []
  s.support_email = nil
  s.description = ""
  s.active = true
  s.trustiness = 1
  s.groups = []
  s.tags   = []
  
end
