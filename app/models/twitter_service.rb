class TwitterService < Service

  # OK

  SERVICE_NAME = 'Twitter'
  SERVICE_ACTIONS = [Service::SERVICE_ACTION_POST]

  validates_presence_of :twitter_login, :icon_url, :profile_image_url

  settings_accessors(:twitter_login)

  # returns an array of twitter posts, newer posts first
  def fetch_entries(quantity=15)
    logger.info "#{SERVICE_NAME}: Fetching #{quantity} most recent tweets by #{self.twitter_login}"
    Twitter::Search.new.
      from(self.twitter_login).
      per_page(quantity).
      fetch.
      results
  rescue Timeout::Error => tme
    logger.warn "#{SERVICE_NAME}: Error fetching posts (timeout error): #{tme}"
    []
  rescue => e
    logger.warn "#{SERVICE_NAME}: Error fetching posts: #{e}"
    []
  end

  # returns an array of twitter posts, posted after the last_entry_id, newer
  # posts first
  def fetch_entries_since(last_entry_id, quantity=100)
    logger.info "#{SERVICE_NAME}: Fetching #{quantity} most recent tweets by #{self.twitter_login} since post id #{last_entry_id}"
    Twitter::Search.new.
      from(self.twitter_login).
      since(last_entry_id).
      per_page(quantity).
      fetch.
      results
  rescue Timeout::Error => tme
    logger.warn "#{SERVICE_NAME}: Error fetching posts (timeout error): #{tme}"
    []
  rescue => e
    logger.warn "#{SERVICE_NAME}: Error fetching posts: #{e}"
    []
  end

  # returns a Post object associated with this Service, with all relevant
  # attributes filled with the entry's content
  def build_post_from_entry(entry)
    self.posts.build(
      :service_action => Service::SERVICE_ACTION_POST,
      :identifier => entry.id.to_s,
      :title => entry.text,
      :markup => Post::HTML_MARKUP,
      :body => entry.text,
      :url => "#{self.profile_url}/status/#{entry.id}",
      :published_at => entry.created_at.to_time
    )
  end

  # returns the unique identifier of the last post associated with this service
  def last_post_identifier
    self.posts.
      find(:first, :order => 'published_at DESC, id DESC').
      try(:identifier)
  end

  # fetches recent entries since the last one (or the more recent ones if never
  # fetched), parses all of them into Post objects and saves all of them.
  # returns an array with the id's of the successfully saved posts and +nil+'s
  # representing the failed ones.
  def create_posts(quantity=15)
    entries = if self.last_post_identifier
      self.fetch_entries_since(last_post_identifier, quantity)
    else
      self.fetch_entries(quantity)
    end
    posts = self.build_posts_from_entries(entries)
    posts.map do |post|
      if post.save
        post.id
      else
        logger.warn "Error saving Post: #{post.service.try(:name)} - #{post.identifier} - #{post.errors.full_messages.to_sentence}"
        nil
      end
    end
  end

  protected

    # before_validation_on_create
    def set_url_attributes
      unless twitter_login.blank?
        tweet = Twitter::Search.new.from(twitter_login).per_page(1).fetch.results.first
        self.icon_url = "http://assets1.twitter.com/images/favicon.ico"
        self.profile_url = "http://twitter.com/#{twitter_login}"
        self.profile_image_url = tweet.profile_image_url unless tweet.nil?
      end
    end

end