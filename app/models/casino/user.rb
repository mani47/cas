
class CASino::User < ActiveRecord::Base
  serialize :extra_attributes, Hash

  has_many :ticket_granting_tickets
  has_many :two_factor_authenticators
  has_many :acceptto_authenticators

  def active_two_factor_authenticator
    self.two_factor_authenticators.where(active: true).first
  end
  
  def active_acceptto_authenticator
    self.acceptto_authenticators.first
  end
  
  def acceptto_token
    self.acceptto_authenticators.first.nil? ? '' : self.acceptto_authenticators.first.token
  end
end
