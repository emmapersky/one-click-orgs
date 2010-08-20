require 'digest/sha1'

class Member < ActiveRecord::Base
  belongs_to :organisation
  
  has_many :votes
  has_many :proposals, :foreign_key => 'proposer_member_id'
  belongs_to :member_class

  scope :active, where(["active = ? AND inducted_at IS NOT NULL", true])
  scope :pending, where("inducted_at IS NULL")

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

  def new_password!(n=6)
    raise ArgumentError, "password must have at least 6 characters" if n < 6
    chars = ["a".."z", "A".."Z", "0".."9"].map(&:to_a).flatten
    self.password = self.password_confirmation = (1..n).map { chars[rand(chars.size-1)] }.join
  end

  def self.create_member(params, send_welcome=false)
    member = Member.new(params)
    member.new_password!
    member.save!
    member.send_welcome if send_welcome
    member
  end

  def send_welcome
    MembersMailer.welcome_new_member(self, self.password).deliver
  end
  handle_asynchronously :send_welcome

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
end

