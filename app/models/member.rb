require 'digest/sha1'

class Member < ActiveRecord::Base
  has_many :votes
  has_many :proposals, :foreign_key => 'proposer_member_id'

  scope :active, where(:active => true, :inducted => true)

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
    proposal = Proposal.find(proposal_id)
    raise VoteError, "proposal with id #{proposal_id} not found" unless proposal
    raise VoteError, "Can not vote on proposals created before member created" if proposal.creation_date < self.created_at

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
    # TODO Convert to new background job system
    #async_job :send_new_member_email, self.id, self.password
    Member.send_new_member_email(self.id, self.password)
  end

  def self.send_new_member_email(member_id, password)
    member = Member.find(member_id)
    MembersMailer.welcome_new_member(member, password).deliver
  end

  def eject!
    self.active = false
    save
  end

  def to_event
    {:timestamp => self.created_at, :object => self, :kind => :new_member}
  end
end

