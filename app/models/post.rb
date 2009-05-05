class Post < ActiveRecord::Base

  HTML_MARKUP = 'html'
  PLAIN_MARKUP = 'plain'
  TEXTILE_MARKUP = 'textile'

  acts_as_taggable

  acts_as_textiled :body

  serialize :extra_content, Hash

  belongs_to :service

  cattr_reader :per_page
  @@per_page = 12

  validates_presence_of :service_id, :service_action, :identifier, :title, :summary, :url, :published_at
  validates_presence_of :body, :if => :is_article?
  validates_uniqueness_of :identifier, :scope => :service_id

  before_create :slugify_if_article
  #before_create :summarize_if_article # TODO

  # returns true if this post is associated with a BlogService
  def is_article?
    self.service.class == BlogService
  end

  def to_param
    is_article? ? "#{self.id}-#{self.slug}" : "#{self.id}"
  end

  protected

    def slugify_if_article
      if is_article?
        self.slug = PermalinkFu.escape(self.title)[0..60]
      end
    end

end
