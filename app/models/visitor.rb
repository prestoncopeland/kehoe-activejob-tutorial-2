class Visitor < ActiveRecord::Base
  validates_presence_of :email
  validates_format_of :email, :with=> /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i

  after_create :sign_up_for_mailing_list
  after_initialize :defaults

  def defaults
    self.affinity = 'NONE' unless self.affinity=='KITTENS'
  end

  def sign_up_for_mailing_list
    MailingListSignupJob.perform_later(self)
  end

  def subscribe
    mailchimp=Gibbon::API.new(Rails.application.secrets.mailchimp_api_key)
    result=mailchimp.lists.subscribe({
      :id=>Rails.application.secrets.mailchimp_list_id,
      :email=>{:email=>self.email},
      :merge_vars => {:referrer => self.referrer.truncate(252, omission: '...'), :groupings => [{:name => 'AFFINITY', :groups => [self.affinity.upcase]}]},
      :double_optin=>false,
      :update_existing => true,
      :send_welcome=>true
    })
    Rails.logger.info("Subscribed #{self.email} to MailChimp") if result
  end

end
