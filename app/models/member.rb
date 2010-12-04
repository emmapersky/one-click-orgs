require 'digest/sha1'
require 'digest/md5'
require 'lib/vote_error'

class Member < ActiveRecord::Base
  belongs_to :organisation
  
  has_many :votes
  has_many :proposals, :foreign_key => 'proposer_member_id'
  belongs_to :member_class

  scope :active, where("active = 1 AND inducted_at IS NOT NULL")
  scope :pending, where("inducted_at IS NULL")
  
  validates_uniqueness_of :invitation_code, :scope => :organisation_id, :allow_nil => true
  
  validates_confirmation_of :password
  # validates_presence_of :password_confirmation, :if => :password_required?

  def proposals_count
    proposals.count
  end
  
  def succeeded_proposals_count
    proposals.where(:open => false, :accepted => true).count
  end
  
  def failed_proposals_count
    proposals.where(:open => false, :accepted => false).count
  end
  
  def votes_count
    votes.count
  end

  # AUTHENTICATION

  attr_accessor :password, :password_confirmation

  # Encrypts some data with the salt
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def self.authenticate(login, password)
    member = where(:email => login).first
    member && member.authenticated?(password) ? member : nil
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--:email--") if new_record?
    self.crypted_password = encrypt(password)
  end

  before_save :encrypt_password

  # END AUTHENTICATION

  def cast_vote(action, proposal_id)
    raise ArgumentError, "need action and proposal_id" unless action and proposal_id

    existing_vote = Vote.where(:member_id => self.id, :proposal_id => proposal_id).first
    raise VoteError, "Vote already exists for this proposal" if existing_vote

    # FIXME why not just pass the proposal in?
    proposal = organisation.proposals.find(proposal_id)
    raise VoteError, "proposal with id #{proposal_id} not found" unless proposal
    if !self.inducted? || proposal.creation_date < self.inducted_at
      raise VoteError, "Can not vote on proposals created before member inducted"
    end

    case action
    when :for
      Vote.create(:member => self, :proposal_id => proposal_id, :for => true)
    when :against
      Vote.create(:member => self, :proposal_id => proposal_id, :for => false)
    end
  end

  def self.create_member(params, send_welcome=false)
    member = Member.new(params)
    member.new_invitation_code!
    member.save!
    member.send_welcome if send_welcome
    member
  end

  def send_welcome
    MembersMailer.welcome_new_member(self).deliver
  end
  
  # only to be backwards compatible with systems running older versions of delayed job
  def self.send_new_member_email(member_id, password)
    Member.find(member_id).send_welcome_without_send_later
  end
    
  def eject!
    self.active = false
    save
  end

  def inducted?
    !inducted_at.nil?
  end

  def to_event
    if self.inducted?
      {:timestamp => self.inducted_at, :object => self, :kind => :new_member}
    end
  end
  
  def has_permission(type)
    member_class.has_permission(type)
  end
  
  def name
    full_name = [first_name, last_name].compact.join(' ')
    full_name.blank? ? nil : full_name
  end

  # INVITATION CODE
  
  def self.generate_invitation_code
    Digest::SHA1.hexdigest("#{Time.now}#{rand}")[0..9]
  end
  
  def new_invitation_code!
    self.invitation_code = self.class.generate_invitation_code
  end
  
  def clear_invitation_code!
    self.update_attribute(:invitation_code, nil)
  end
  
  # PASSWORD RESET CODE
  
  def self.generate_password_reset_code
    Digest::SHA1.hexdigest("#{Time.now}#{rand}")[0..9]
  end
  
  def new_password_reset_code!
    self.password_reset_code = self.class.generate_password_reset_code
  end
  
  def clear_password_reset_code!
    self.update_attribute(:password_reset_code, nil)
  end
  
  # GRAVATAR
  
  def gravatar_url
    hash = Digest::MD5.hexdigest(email.downcase)
    "http://www.gravatar.com/avatar/#{hash}?d=mm"
  end
end
