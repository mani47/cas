class AddAuthenticationTokenToTicketGrantingTickets < ActiveRecord::Migration
  def change
    add_column :casino_ticket_granting_tickets, :acceptto_authentication_token, :string 
  end
end
