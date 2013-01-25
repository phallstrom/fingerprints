# Fingerprints

[![Gem Version](https://badge.fury.io/rb/fingerprints.png)](http://badge.fury.io/rb/fingerprints)

Make it easy to track who created/updated your models.

## Installation

Add this line to your application's Gemfile:

    gem 'fingerprints'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fingerprints

## Usage


Example
=======

    # Widget Schema...
    create_table :widgets do |t|
      t.string :name
      t.fingerprints # creates integer fields for created_by and updated_by
    end

    # User model...
    class User < ActiveRecord::Base
      has_fingerprints
    end

    # Widget model...
    class Widget < ActiveRecord::Base
      leaves_fingerprints

      # If your 'user' is really a Person you could do this:
      #
      # leaves_fingerprints :class_name => 'Person'
    end

Now, some how, some way you need to set User.fingerprint to either the User instance
or User 'id' of the "currently logged in user".  One way to do this would be to put
this in your controller assuming your controller has a `:current_user` method that will
return the current user.

    before_filter { |c| User.fingerprint = c.send(:current_user) }

At this point if you create/update a Widget it will set the `created_by/updated_by` attributes
automatically.  You can also do this:

    @widget.creator => User instance...
    @widget.updator => User instance...

The default `:class_name` is 'User' and can be overridden like this:

    HasFingerprints::OPTIONS.merge!(:class_name => 'Person')

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
