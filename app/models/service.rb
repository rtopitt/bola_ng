class Service < ActiveRecord::Base

  SERVICE_NAME = nil
  SERVICE_ACTION_POST = 'posted'
  SERVICE_ACTION_FAVE = 'faved'
  SERVICE_ACTION_SHARE = 'shared'
  SERVICE_ACTION_BOOKMARK = 'bookmarked'

  has_many :posts

  serialize :settings, Hash

  named_scope :active, :conditions => {:active => true}
  named_scope :inactive, :conditions => {:active => false}

  validates_presence_of :type, :name, :profile_url
  validates_uniqueness_of :name, :profile_url

  def after_initialize
    self.name = self.class::SERVICE_NAME if self.new_record?
  end

  before_validation_on_create :set_url_attributes

  # Creates virtual attributes that are accessors (getters and setters) to the
  # keys in the settings hash.
  def self.settings_accessors(fields)
    [fields].flatten.each do |attr_name|
      methods = <<-EOF
        def #{attr_name}
          self.settings ||= {}
          self.settings[:#{attr_name}]
        end
        def #{attr_name}=(new_#{attr_name})
          self.settings ||= {}
          self.settings[:#{attr_name}] = new_#{attr_name}
        end
        def #{attr_name}_before_type_cast
          self.#{attr_name}
        end
      EOF
      eval(methods)
    end
  end
  
  def fetch_entries(quantity=15)
    # overwrite in the child services
  end
  
  def build_post_from_entry(entry)
    # overwrite in the child services
  end

  def build_posts_from_entries(entries)
    entries.map { |entry| self.build_post_from_entry(entry) }
  end

  def create_posts
    # overwrite in the child services
    # basic usage:
    # 
    # entries = self.fetch_entries
    # posts = self.build_posts_from_entries(entries)
    # posts.map do |post|
    #   if post.save
    #     post.id
    #   else
    #     logger.warn "Error saving Post: #{post.service.try(:name)} - #{post.identifier} - #{post.errors.full_messages}"
    #     nil
    #   end
    # end
  end

  protected

    def set_url_attributes
      # overwrite in the child services
    end

end