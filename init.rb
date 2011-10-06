require 'has_fingerprints/active_record'
require 'has_fingerprints'
ActiveRecord::Base.class_eval { include ActiveRecord::HasFingerprints }
